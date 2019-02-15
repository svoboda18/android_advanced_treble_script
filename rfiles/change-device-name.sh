#!/system/bin/sh

if grep -q phh.device.namechanged /system/build.prop;then
    exit 0
fi

if [ ! -f /vendor/build.prop ]; then
    exit 0
fi

VENDOR_FINGERPRINT="$(grep ro.vendor.build.fingerprint /vendor/build.prop | cut -d'=' -f 2)"
#SYSTEM_FINGERPRINT="$(cat /system/build.prop | grep "ro.build.fingerprint=" | dd bs=1 skip=21)"
VENDOR_BRAND="$(grep ro.vendor.product.brand /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_MODEL="$(grep ro.vendor.product.model /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_NAME="$(grep ro.vendor.product.name /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_DEVICE="$(grep ro.vendor.product.device /vendor/build.prop | cut -d'=' -f 2)"
TYPETXT=user
TAGSTXT=release-keys
SELINUXTXT=0
DEBUGGABLETXT=0
SECURETXT=1

modify_on_match() {
    match_result=`echo "${VENDOR_FINGERPRINT}" | grep "$1"`
    brand="$2"
    model="$3"
    name="$4"
    device="$5"

    if [ -n "${match_result}" ]; then
        sed -i \
        -e "s/ro.product.brand=.*/ro.product.brand=${brand}/" \
        -e "s/ro.product.model=.*/ro.product.model=${model}/" \
        -e "s/ro.product.name=.*/ro.product.name=${name}/" \
        -e "s/ro.product.device=.*/ro.product.device=${device}/" \
        -e "s/ro.lineage.device=.*/ro.lineage.device=${device}/" \
        -e "s/ro.aicp.device=.*/ro.aicp.device=${device}/" \
        -e "s@ro.build.fingerprint=.*@ro.build.fingerprint=${VENDOR_FINGERPRINT}@" \
        -e "s/ro.build.type=.*/ro.build.type=${TYPETXT}/" \
        -e "s/ro.build.tags=.*/ro.build.tags=${TAGSTXT}/" \
        -e "s/ro.build.selinux=.*/ro.build.selinux=${SELINUXTXT}/" \
        -e "s/ro.debuggable=.*/ro.debuggable=${DEBUGGABLETXT}/" \
        -e "s/ro.secure=.*/ro.secure=${SECURETXT}/" \
        /system/build.prop
    elif [ "$1" = "use_vendor_prop" ]; then
        sed -i \
        -e "s/ro.product.brand=.*/ro.product.brand=${brand}/" \
        -e "s/ro.product.model=.*/ro.product.model=${model}/" \
        -e "s/ro.product.name=.*/ro.product.name=${name}/" \
        -e "s/ro.product.device=.*/ro.product.device=${device}/" \
        -e "s/ro.lineage.device=.*/ro.lineage.device=${device}/" \
        -e "s/ro.aicp.device=.*/ro.aicp.device=${device}/" \
        -e "s@ro.build.fingerprint=.*@ro.build.fingerprint=${VENDOR_FINGERPRINT}@" \
        -e "s/ro.build.type=.*/ro.build.type=${TYPETXT}/" \
        -e "s/ro.build.tags=.*/ro.build.tags=${TAGSTXT}/" \
        -e "s/ro.build.selinux=.*/ro.build.selinux=${SELINUXTXT}/" \
        -e "s/ro.debuggable=.*/ro.debuggable=${DEBUGGABLETXT}/" \
        -e "s/ro.secure=.*/ro.secure=${SECURETXT}/" \
        /system/build.prop
    fi
}

mount -o remount,rw /system

if [ -n "${VENDOR_BRAND}" ] && [ -n "${VENDOR_MODEL}" ] && [ -n "${VENDOR_NAME}" ] && [ -n "${VENDOR_DEVICE}" ]; then
    modify_on_match "use_vendor_prop" "${VENDOR_BRAND}" "${VENDOR_MODEL}" "${VENDOR_NAME}" "${VENDOR_DEVICE}"
fi

if [ -z "$(grep phh.device.namechanged /system/build.prop)" ]; then
    echo -e "\nphh.device.namechanged=true\n" >> /system/build.prop
fi

mount -o remount,ro /system
