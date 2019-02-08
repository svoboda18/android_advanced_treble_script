$(call inherit-product, vendor/bliss/config/common.mk)

PRODUCT_COPY_FILES += \
      	vendor/bliss/prebuilt/common/etc/init.bliss.rc:system/etc/init/init.bliss.rc
