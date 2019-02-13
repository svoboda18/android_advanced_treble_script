#!/system/bin/sh

if grep -q phh.device.namechanged /system/build.prop;then
    exit 0
fi

if [ ! -f /vendor/build.prop ]; then
    exit 0
fi

VENDOR_FINGERPRINT="$(grep ro.vendor.build.fingerprint /vendor/build.prop | cut -d'=' -f 2)"
SYSTEM_FINGERPRINT="$(cat /system/build.prop | grep "ro.build.fingerprint=" | dd bs=1 skip=21)"
echo "Vendor fingerprint: ${VENDOR_FINGERPRINT}"

VENDOR_BRAND="$(grep ro.vendor.product.brand /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_MODEL="$(grep ro.vendor.product.model /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_NAME="$(grep ro.vendor.product.name /vendor/build.prop | cut -d'=' -f 2)"
VENDOR_DEVICE="$(grep ro.vendor.product.device /vendor/build.prop | cut -d'=' -f 2)"
TYPETXT=user
TAGSTXT=release-keys
SELINUXTXT=0
DEBUGGABLETXT=0
SECURETXT=1
echo "Product brand: ${VENDOR_BRAND}"
echo "Product model: ${VENDOR_MODEL}"
echo "Product name: ${VENDOR_NAME}"
echo "Product device: ${VENDOR_DEVICE}"

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
        -e "s@ro.build.fingerprint=${SYSTEM_FINGERPRINT}@ro.build.fingerprint=${VENDOR_FINGERPRINT}@" \
        -e "s/ro.build.type=.*/ro.build.type=${TYPETXT}/" \
        -e "s/ro.build.tags=.*/ro.build.tags=${TAGSTXT}/" \
        -e "s/ro.build.selinux=.*/ro.build.selinux=${SELINUXTXT}/" \
        -e "s/ro.debuggable=.*/ro.debuggable=${DEBUGGABLETXT}/" \
        -e "s/ro.secure=.*/ro.secure=${SECURETXT}/" \
        /system/build.prop

        echo "Device name changed! Match: $2 $3 $4 $5"
    elif [ "$1" = "use_vendor_prop" ]; then
        sed -i \
        -e "s/ro.product.brand=.*/ro.product.brand=${brand}/" \
        -e "s/ro.product.model=.*/ro.product.model=${model}/" \
        -e "s/ro.product.name=.*/ro.product.name=${name}/" \
        -e "s/ro.product.device=.*/ro.product.device=${device}/" \
        -e "s/ro.lineage.device=.*/ro.lineage.device=${device}/" \
        -e "s/ro.aicp.device=.*/ro.aicp.device=${device}/" \
        -e "s@ro.build.fingerprint=${SYSTEM_FINGERPRINT}@ro.build.fingerprint=${VENDOR_FINGERPRINT}@" \
        -e "s/ro.build.type=.*/ro.build.type=${TYPETXT}/" \
        -e "s/ro.build.tags=.*/ro.build.tags=${TAGSTXT}/" \
        -e "s/ro.build.selinux=.*/ro.build.selinux=${SELINUXTXT}/" \
        -e "s/ro.debuggable=.*/ro.debuggable=${DEBUGGABLETXT}/" \
        -e "s/ro.secure=.*/ro.secure=${SECURETXT}/" \
        /system/build.prop

        echo "Device name changed! Match: $2 $3 $4 $5"
    fi
}

mount -o remount,rw /system

if [ -n "${VENDOR_BRAND}" ] && [ -n "${VENDOR_MODEL}" ] && [ -n "${VENDOR_NAME}" ] && [ -n "${VENDOR_DEVICE}" ]; then
    modify_on_match "use_vendor_prop" "${VENDOR_BRAND}" "${VENDOR_MODEL}" "${VENDOR_NAME}" "${VENDOR_DEVICE}"
fi

# Add devices here, e.g.
# modify_on_match <pattern> <brand> <model> <name> <device>
#
# or you could just leave it as is. This script will try to read existing props from vendor/build.prop (and of course, if it exists)
#
# example:
# modify_on_match "FIH/SAT_.*" "SHARP" "AQUOS S2" "SS2" "SS2"
# modify_on_match "Xiaomi/riva/riva.*" "Xiaomi" "Redmi 5A" "riva" "riva"
# modify_on_match "Xiaomi/rolex/rolex.*" "Xiaomi" "Redmi 4A" "rolex" "rolex"

# End of devices

if [ -z "$(grep phh.device.namechanged /system/build.prop)" ]; then
    echo -e "\nphh.device.namechanged=true\n" >> /system/build.prop
fi

mount -o remount,ro /system
