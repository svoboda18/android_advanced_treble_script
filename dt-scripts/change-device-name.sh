#!/system/bin/sh

if grep -q system.device.namechanged /system/build.prop;then
    exit 0
fi

if [ ! -f /vendor/build.prop ]; then
    exit 0
fi

VENDOR_FINGERPRINT="$(grep ro.vendor.build.fingerprint /vendor/build.prop | cut -d'=' -f 2)"
[ -z "$VENDOR_FINGERPRINT" ] && VENDOR_FINGERPRINT="$(grep ro.build.fingerprint /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_DESCRIPTION="$(grep ro.vendor.build.description /vendor/build.prop | cut -d'=' -f 2)"
[ -z "$VENDOR_DESCRIPTION" ] && VENDOR_DESCRIPTION="$(grep ro.build.description /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_BRAND="$(grep ro.vendor.product.brand /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_MODEL="$(grep ro.vendor.product.model /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_NAME="$(grep ro.vendor.product.name /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_DEVICE="$(grep ro.vendor.product.device /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_MANUFACTURER="$(grep ro.vendor.product.manufacturer /vendor/build.prop | cut -d'=' -f 2)"
[ -z "$VENDOR_MANUFACTURER" ] && VENDOR_MANUFACTURER="$VENDOR_BRAND"

TYPETXT=user
TAGSTXT=release-keys
SELINUXTXT=0
DEBUGGABLETXT=0
SECURETXT=1

modify_on_match() {
    brand="$1"
    model="$2"
    name="$3"
    device="$4"

    sed -i \
        -e "s/ro.product.brand=.*/ro.product.brand=${brand}/" \
	-e "s/ro.product.manufacturer=.*/ro.product.manufacturer=${VENDOR_MANUFACTURER}/" \
        -e "s/ro.product.model=.*/ro.product.model=${model}/" \
        -e "s/ro.product.name=.*/ro.product.name=${name}/" \
        -e "s/ro.product.device=.*/ro.product.device=${device}/" \
        -e "s@ro.build.fingerprint=.*@ro.build.fingerprint=${VENDOR_FINGERPRINT}@" \
	-e "s@ro.build.description=.*@ro.build.description=${VENDOR_DESCRIPTION}@" \
        -e "s/ro.build.type=.*/ro.build.type=${TYPETXT}/" \
        -e "s/ro.build.tags=.*/ro.build.tags=${TAGSTXT}/" \
        -e "s/ro.build.selinux=.*/ro.build.selinux=${SELINUXTXT}/" \
        -e "s/ro.debuggable=.*/ro.debuggable=${DEBUGGABLETXT}/" \
        -e "s/ro.secure=.*/ro.secure=${SECURETXT}/" \
    /system/build.prop
}

mount -o remount,rw /system

if [ -n "${VENDOR_BRAND}" ] && [ -n "${VENDOR_MODEL}" ] && [ -n "${VENDOR_NAME}" ] && [ -n "${VENDOR_DEVICE}" ]; then
    modify_on_match "${VENDOR_BRAND}" "${VENDOR_MODEL}" "${VENDOR_NAME}" "${VENDOR_DEVICE}"
fi

if [ -z "$(grep system.device.namechanged /system/build.prop)" ]; then
    echo -e "\nsystem.device.namechanged=true\n" >> /system/build.prop
fi

mount -o remount,ro /system
