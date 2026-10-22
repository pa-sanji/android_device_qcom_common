#
# SPDX-FileCopyrightText: Paranoid Android
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_SOONG_NAMESPACES += \
    device/qcom/common/vendor/usb

# Inherit from the USB product definition.
$(call inherit-product, vendor/qcom/opensource/usb/vendor_product.mk)

# vendor_product.mk disables FFS-based MTP for 4.19 kernels. That is a legacy
# heuristic for old msm-4.19 targets without configfs FFS/MTP support; this
# tree's kernel has CONFIG_USB_CONFIGFS_F_FS, CONFIG_USB_F_FS and
# CONFIG_USB_F_MTP all enabled.
#
# It matters because vendor.usb.use_gadget_hal=1 means the AIDL gadget HAL
# owns the config, and with use_ffs_mtp=0 the 'sys.usb.config=mtp' trigger in
# init.qcom.usb.rc only writes idVendor/idProduct - it never symlinks
# functions/ffs.mtp into configs/b.1, so no MTP interface is ever exposed and
# "File transfer" does nothing on the PC side.
#
# Replace the value instead of appending a second one: post_process_props
# rejects duplicate props that disagree (only BUILD_BROKEN_DUP_SYSPROP would
# paper over it).
PRODUCT_PROPERTY_OVERRIDES := \
    $(filter-out vendor.usb.use_ffs_mtp=0,$(PRODUCT_PROPERTY_OVERRIDES)) \
    vendor.usb.use_ffs_mtp=1 \
    sys.usb.mtp.batchcancel=1

ifeq (,$(filter 4.14 4.19, $(TARGET_KERNEL_VERSION)))
TARGET_HAS_DIAG_ROUTER := true
endif

ifneq (,$(filter 4.14, $(TARGET_KERNEL_VERSION)))
PRODUCT_PACKAGES += android.hardware.usb@1.0-service
endif

ifeq (,$(filter 4.14 4.19 5.4, $(TARGET_KERNEL_VERSION)))
PRODUCT_HAS_GADGET_HAL := true
endif

ifeq ($(PRODUCT_HAS_GADGET_HAL),true)
PRODUCT_PACKAGES += \
    NcmTetheringOverlay \
    NcmTetheringOverlayMainline
endif

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

PRODUCT_PACKAGES += \
    init.aospa.usb.rc
