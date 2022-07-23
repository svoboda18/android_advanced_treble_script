#!/bin/bash

#
# Copyright (C) 2019 by SaMad SegMane (svoboda18)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses
#

set -e -E
trap 'reportError "An unexpected error occurred!"' ERR

###############
#             #
#  VARIABLES  #
#             #
###############

myname="$(basename "$0")"
BLD="\033[1m"
GRN="\033[01;32m"
RED="\033[01;31m"
YLW="\033[01;33m"
RST="\033[0m"
VER=2

###############
#             #
#  FUNCTIONS  #
#             #
###############

function printText() {
	echo -e "${GRN}==$( for i in $( seq ${#1} ); do echo -e "=\c"; done )=="
	echo -e "= $( for i in $( seq ${#1} ); do echo -e " \c"; done ) ="
	echo -e "= ${RST}${1}${GRN} ="
	echo -e "= $( for i in $( seq ${#1} ); do echo -e " \c"; done ) ="
	echo -e "==$( for i in $( seq ${#1} ); do echo -e "=\c"; done )=="
	echo -e ${RST}
}

function reportError() {
	echo -e ""
	echo -e ${RED}"${1}"${RST} 
	echo -e ""
	echo -e ${GRN}"Run \"bash $myname --help\" for usage information."${RST} 
	echo -e ""
	trap - ERR
	exit 1
}

function reportWarning() {
	echo -e ${YLW}"${1}"${RST}
}

function say_welcome() {

printText "× ADVANCED GSI IMAGE BUILD SCRIPT $VER ×"

sleep 0.8s
}

function prepre_env() {
set -e
if [ -z "$USER" ];then
	export USER="$(id -un)"
fi

export LC_ALL=C

rom_fp="$(date +%Y%m%d%M-adv)"

if [[ $(uname -s) = "Darwin" ]];then
	jobs=$(sysctl -n hw.ncpu)
elif [[ $(uname -s) = "Linux" ]];then
	jobs=$(nproc --all)
fi
}

function help() {
cat <<EOF
Advanced GSI ROM Builder Script v$VER by SaMad SegMane (svoboda18)

Usage Help:

Syntax:

  bash $myname [-j <number of threads>] <rom type> <variant> [<variant2> <variant3>..]
  []: that options are optional.
  <>: that options are required.

Options:

  -j number of parallel make workers (defaults to $jobs)

ROM types:

  aosp81
  aosp90
  aosp100
  aosp110
  aosp121
  aospa81
  aospa90
  aosip81
  aosip90
  aicp81
  aicp90
  aokp81
  aokp90
  aex81
  aex90
  bliss81
  bliss90
  carbon81
  carbon90
  crdroid81
  crdroid90
  dot81
  dot90
  du81
  du90
  e-pie
  e-oreo
  evox90
  havoc81
  havoc90
  lineage151
  lineage160
  mokee81
  mokee90
  pixel81
  pixel90
  rr81
  rr90
  slim81
  slim90
  xpe81
  xpe90

Variants are dash-joined combinations of (in order):
- Processor type
  * "arm" for ARM 32 bit
  * "arm64" for ARM 64 bit
  * "a64" for ARM 32 bit system with 64 bit binder
- A or A/B partition layout ("aonly" or "ab")
- GApps selection
  * "vanilla" to not include GApps
  * "gapps" to include opengapps
- SU selection 
  * "su" with root permissions
  * "nosu" without root permissions
- Build variant selection (optional)
  * "eng" for eng build
  * "user" for prod build (some errors are expected)
  * "userdebug" for debug build (default)

Examples:
- GSI ROM for ARM-A without Gapps and SU:
  * arm-aonly-vanilla-nosu
EOF
}

function get_rom_type() {
	case "$1" in
		aosp81)
	            mainrepo="https://android.googlesource.com/platform/manifest.git"
	            mainbranch="android-8.1.0_r65"
	            localManifestBranch="android-8.1"
	            treble_generate=""
	            extra_make_options=""
	            ;;
	        aosp90)
	            mainrepo="https://android.googlesource.com/platform/manifest.git"
	            mainbranch="android-9.0.0_r53"
	            localManifestBranch="android-9.0"
	            treble_generate=""
	            extra_make_options=""
	            ;;
	        aosp100)
	            mainrepo="https://android.googlesource.com/platform/manifest.git"
	            mainbranch="android-10.0.0_r41"
	            localManifestBranch="android-10.0"
	            treble_generate=""
	            extra_make_options=""
	            ;;
	        aosp110)
	            mainrepo="https://android.googlesource.com/platform/manifest.git"
	            mainbranch="android-11.0.0_r48"
	            localManifestBranch="android-11.0"
	            treble_generate=""
	            extra_make_options=""
	            ;;
	        aosp121)
	            mainrepo="https://android.googlesource.com/platform/manifest.git"
	            mainbranch="android-12.1.0_r11"
	            localManifestBranch="android-12.1"
	            treble_generate=""
	            extra_make_options=""
	            ;;
		evox90)
	            mainrepo="https://github.com/Evolution-X/platform_manifest.git"
	            mainbranch="pie"
	            localManifestBranch="android-9.0"
	            treble_generate=""
	            extra_make_options=""
	            ;;
		aosip81)
		    mainrepo="https://github.com/AOSiP/platform_manifest.git"
		    mainbranch="oreo-mr1"
		    localManifestBranch="android-8.1"
		    treble_generate="aosip"
		    extra_make_options=""
		    ;;
		aosip90)
		    mainrepo="https://github.com/AOSiP/platform_manifest.git"
		    mainbranch="pie"
		    localManifestBranch="android-9.0"
		    treble_generate="aosip"
		    extra_make_options=""
	            ;;
		ces100)
	            mainrepo="https://github.com/CesiumOS/manifest"
	            mainbranch="ten"
	            localManifestBranch="android-10.0"
	            treble_generate=""
		    gen_mk="cesuim"
		    gen_target="treble"
		    gen_config='$(call inherit-product, vendor/aosp/config/common_full_phone.mk)'
		    gen_sepolicy=''
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		carbon81)
	            mainrepo="https://github.com/CarbonROM/android.git"
	            mainbranch="cr-6.1"
	            localManifestBranch="android-8.1"
	            treble_generate="carbon"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		carbon90)
		    mainrepo="https://github.com/CarbonROM/android.git"
		    mainbranch="cr-7.0"
		    localManifestBranch="android-9.0"
		    treble_generate="carbon"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		e-oreo)
		    mainrepo="https://gitlab.e.foundation/e/os/android/"
		    mainbranch="v1-oreo"
		    localManifestBranch="android-8.1"
		    treble_generate="lineage"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
	        e-pie)
	            mainrepo="https://gitlab.e.foundation/e/os/android/"
	            mainbranch="v1-pie"
	            localManifestBranch="android-9.0"
	            treble_generate="lineage"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		lineage151)
	            mainrepo="https://github.com/LineageOS/android.git"
	            mainbranch="lineage-15.1"
	            localManifestBranch="android-8.1"
	            treble_generate="lineage"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		lineage160)
	            mainrepo="https://github.com/LineageOS/android.git"
	            mainbranch="lineage-16.0"
	            localManifestBranch="android-9.0"
	            treble_generate="lineage"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		rr81)
	            mainrepo="https://github.com/ResurrectionRemix/platform_manifest.git"
	            mainbranch="oreo"
	            localManifestBranch="android-8.1"
	            treble_generate="rr"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		rr90)
		    mainrepo="https://github.com/ResurrectionRemix/platform_manifest.git"
		    mainbranch="pie"
		    localManifestBranch="android-9.0"
		    treble_generate="rr"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		dot81)
		    mainrepo="https://github.com/DotOS/manifest.git"
		    mainbranch="dot-o"
		    localManifestBranch="android-8.1"
		    treble_generate=""
		    gen_mk="dot"
		    gen_target="treble"
		    gen_config='$(call inherit-product, vendor/dot/config/common.mk)'
		    gen_sepolicy='$(call inherit-product, device/aosp/sepolicy/common/sepolicy.mk)'
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		dot90)
		    mainrepo="https://github.com/DotOS/manifest.git"
		    mainbranch="dot-p"
		    localManifestBranch="android-9.0"
		    treble_generate=""
		    gen_mk="dot"
		    gen_target="treble"
		    gen_config='$(call inherit-product, vendor/dot/config/common.mk)'
		    gen_sepolicy=''
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aospa81)
		    mainrepo="https://github.com/AOSPA/manifest.git"
		    mainbranch="oreo-mr1"
		    localManifestBranch="android-8.1"
		    treble_generate="aospa"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aospa90)
		    mainrepo="https://github.com/AOSPA/manifest.git"
		    mainbranch="pie"
		    localManifestBranch="android-9.0"
		    treble_generate="aospa"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		du81)
		    mainrepo="https://github.com/DirtyUnicorns/android_manifest.git"
		    mainbranch="o8x"
		    localManifestBranch="android-8.1"
		    treble_generate="du"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		du90)
		    mainrepo="https://github.com/DirtyUnicorns/android_manifest.git"
		    mainbranch="p9x"
		    localManifestBranch="android-9.0"
		    treble_generate="du"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		bliss81)
		    mainrepo="https://github.com/BlissRoms/platform_manifest.git"
		    mainbranch="o8.1"
		    localManifestBranch="android-8.1"
		    treble_generate="bliss"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		bliss90)
		    mainrepo="https://github.com/BlissRoms/platform_manifest.git"
		    mainbranch="p9.0"
		    localManifestBranch="android-9.0"
		    treble_generate="bliss"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		xpe81)
		    mainrepo="https://github.com/TheXPerienceProject/Manifest.git"
		    mainbranch="xpe-12.1"
		    localManifestBranch="android-8.1"
		    treble_generate="xpe"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		xpe90)
		    mainrepo="https://github.com/TheXPerienceProject/Manifest.git"
		    mainbranch="xpe-13.0"
		    localManifestBranch="android-9.0"
		    treble_generate="xpe"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		pixel81)
	            mainrepo="https://github.com/PixelExperience/manifest.git"
	            mainbranch="oreo-mr1"
	            localManifestBranch="android-8.1"
	            treble_generate="pixel"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		pixel90)
	            mainrepo="https://github.com/PixelExperience-P/manifest.git"
	            mainbranch="pie"
	            localManifestBranch="android-9.0"
	            treble_generate="pixel"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		crdroid81)
	            mainrepo="https://github.com/crdroidandroid/android.git"
	            mainbranch="8.1"
	            localManifestBranch="android-8.1"
	            treble_generate="lineage"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		crdroid90)
		    mainrepo="https://github.com/crdroidandroid/android.git"
		    mainbranch="9.0"
		    localManifestBranch="android-9.0"
		    treble_generate="lineage"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		mokee81)
	            mainrepo="https://github.com/MoKee/android.git"
	            mainbranch="mko-mr1"
	            localManifestBranch="android-8.1"
	            treble_generate="mokee"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		mokee90)
		    mainrepo="https://github.com/MoKee/android.git"
		    mainbranch="mkp"
		    localManifestBranch="android-9.0"
		    treble_generate="mokee"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aicp81)
	            mainrepo="https://github.com/AICP/platform_manifest.git"
	            mainbranch="o8.1"
	            localManifestBranch="android-8.1"
	            treble_generate="aicp"
	            extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aicp90)
		    mainrepo="https://github.com/AICP/platform_manifest.git"
		    mainbranch="p9.0"
		    localManifestBranch="android-9.0"
		    treble_generate="aicp"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aokp81)
	            mainrepo="https://github.com/AOKP/platform_manifest.git"
	            mainbranch="oreo"
	            localManifestBranch="android-8.1"
	            treble_generate="aokp"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		aokp90)
		    mainrepo="https://github.com/AOKP/platform_manifest.git"
		    mainbranch="9.0"
		    localManifestBranch="android-9.0"
		    treble_generate="aokp"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		aex90)
	            mainrepo="https://github.com/AospExtended/manifest.git"
	            mainbranch="9.x"
	            localManifestBranch="android-9.0"
	            treble_generate="aex"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		aex81)
	            mainrepo="https://github.com/AospExtended/manifest.git"
	            mainbranch="8.1.x"
	            localManifestBranch="android-8.1"
	            treble_generate="aex"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		slim81)
	            mainrepo="https://github.com/SlimRoms/platform_manifest.git"
	            mainbranch="or8.1"
	            localManifestBranch="android-8.1"
	            treble_generate="slim"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		slim90)
		    mainrepo="https://github.com/SlimRoms/platform_manifest.git"
		    mainbranch="9.0"
		    localManifestBranch="android-9.0"
		    treble_generate="slim"
		    extra_make_options="WITHOUT_CHECK_API=true"
		    ;;
		havoc81)
		    mainrepo="https://github.com/Havoc-OS/android_manifest.git"
		    mainbranch="oreo"
		    localManifestBranch="android-8.1"
		    treble_generate="havoc"
		    extra_make_options="WITHOUT_CHECK_API=true"
		   ;;
		havoc90)
	            mainrepo="https://github.com/Havoc-OS/android_manifest.git"
	            mainbranch="pie"
	            localManifestBranch="android-9.0"
	            treble_generate="havoc"
	            extra_make_options="WITHOUT_CHECK_API=true"
	            ;;
		*)
		    reportError "Unknown ROM type: $([ -z $1 ] && echo \(null\) || echo $1)"
		    ;;
	    esac
}

function parse_variant() {
	local -A partition_layout_map
	partition_layout_map[aonly]=a
	partition_layout_map[ab]=b

	local -A gapps_selection_map
	gapps_selection_map[vanilla]=v
	gapps_selection_map[gapps]=g

	local -A su_selection_map
	su_selection_map[su]=S
	su_selection_map[nosu]=N
	
	local -a pieces
	IFS=- pieces=( $1 )

	local processor_type=${pieces[0]}
	local partition_layout=${partition_layout_map[${pieces[1]}]}
	local gapps_selection=${gapps_selection_map[${pieces[2]}]}
	local su_selection=${su_selection_map[${pieces[3]}]}
	local build_type_selection=${pieces[4]}
	
	if [[ -z "$processor_type" || -z "$partition_layout" || -z "$gapps_selection" || -z "$su_selection" ]]; then
	   >&2 reportError "Invalid defined variant: $1"
	fi

	echo "treble_${processor_type}_${partition_layout}${gapps_selection}${su_selection}-${build_type_selection}"
}

function get_variants() {
	declare -a -g variant_codes
	declare -a -g variant_names
	    
	case "$1" in
	    *-*-*-*-*)
		variant_codes[${#variant_codes[*]}]=$(parse_variant "$1")
		variant_names[${#variant_names[*]}]="$1"
	        ;;
	    *-*-*-*)
		variant_codes[${#variant_codes[*]}]=$(parse_variant "$1-userdebug")
	        variant_names[${#variant_names[*]}]="$1"
	        ;;
	    *) reportError "Invalid defined variant: $1"
	        ;;
	esac
}

function init_release() {
	[ ! -d release/"$rom_fp" ] && mkdir -p release/"$rom_fp"
}

function init_main_repo() {
	repo init -u "$mainrepo" -b "$mainbranch"
}

function force_clone() {
	local dir="$1"
	local repo="$2"
	
	[ -d "$dir" ] && rm -rf "$dir"
	git clone https://github.com/phhusson/"$repo" "$dir" -b "$( ([[ -z $3 ]] && echo $localManifestBranch) || echo $3)"
}

function g_clone() {
	local brn="$3"
	local dir="$2"
	local repo="$1"
	local lfs=$( [[ "$(get_android_version)" -le 9 ]] && echo true || echo false )
	
	[ -d "$dir" ] && rm -rf "$dir"
	git clone --depth=1 "$repo" "$dir" "$brn"
	$lfs && (cd "$dir"; git lfs fetch && git lfs checkout)
}

function get_android_version() {
	awk -F'[-.]' '{ print $2 }' <<< $localManifestBranch
} 

function init_local_manifest() {
	local overlay_branch="master"
	local interfaces_branch="master"
	local device_branch="${localManifestBranch}"
	local vndk_branch="master"
	local magsik_branch="master"
	local magisk_target=false
	local vndk_target=true
	local lptools_target=false
	local android_version=$(get_android_version)
	
	if [[ "${android_version}" -ge 9 ]]; then
	     overlay_branch="pie"
	     interfaces_branch="pie"
	     magsik_target=true
	     if [[ "${android_version}" -eq 10 ]]; then
	        vndk_branch="android-10.0"
		magsik_branch="android-10.0"
	     elif [[ "${android_version}" -ge 11 ]]; then
	         # no vndk here
	         vndk_target=false
	         interfaces_branch="android-11.0"
	         
	         if [[ "${android_version}" -eq 12 ]]; then
	            device_branch="android-12.0"
		    lptools_target=true
	         fi 
	     fi
	fi
	force_clone device/phh/treble device_phh_treble ${device_branch}
	$vndk_target && force_clone vendor/vndk vendor_vndk ${vndk_branch}
	force_clone vendor/hardware_overlay vendor_hardware_overlay ${overlay_branch}

	force_clone vendor/interfaces vendor_interfaces ${interfaces_branch}
	force_clone vendor/vndk-tests vendor_vndk-tests master
	$magisk_target && force_clone vendor/magsik vendor_magisk ${magisk_branch}
	$lptools_target && force_clone vendor/lptools vendor_lptools master
	read -p "- Do you want to sync gapps packages? (y/N) " g
	if [[ $g == *"y"* ]];then
	    if [[ "${android_version}" -le 9 ]]; then
		g_clone https://github.com/opengapps/aosp_build vendor/opengapps/build
		g_clone https://gitlab.opengapps.org/opengapps/all vendor/opengapps/sources/all
		g_clone https://gitlab.opengapps.org/opengapps/arm vendor/opengapps/sources/arm
		g_clone https://gitlab.opengapps.org/opengapps/arm64 vendor/opengapps/sources/arm64
	    elif [[ "${android_version}" -eq 10 ]]; then
		g_clone https://gitlab.com/gms-mirror/gmsexpress vendor/google
		rm -f vendor/gapps/interfaces/wifi_ext/Android.bp || true
	    elif [[ "${android_version}" -eq 11 ]]; then
		g_clone https://gitlab.com/00p513-dev/partner_gms vendor/partner_gms 11
	    elif [[ "${android_version}" -eq 12 ]]; then
		g_clone https://gitlab.com/davi.sh/gms-android-12 vendor/partner_gms
		# add revision
	    fi
	fi
}

function sync_repo() {
	repo sync -c -j"$jobs" --no-clone-bundle --no-tags
}

function clean_repo_folder() {
	rm -rf .repo *
}

function add_mks() {
	cp -r $(dirname "$0")/mks/* device/phh/treble
}

function fix_missings() {
	if [[ "${android_version}" -gt 8 ]]; then
		# fix kernel source missing
		sed 's;.*KERNEL_;//&;' -i vendor/*/build/soong/Android.bp 2>/dev/null || true
		rm -rf vendor/*/packages/overlays/NoCutout*
	fi
	mkdir -p device/sample/etc
	wget --output-document=device/sample/etc/apns-full-conf.xml https://github.com/LineageOS/android_vendor_lineage/raw/lineage-17.0/prebuilt/common/etc/apns-conf.xml 2>/dev/null

	mkdir -p device/generic/common/nfc
	wget --output-document=device/generic/common/nfc/libnfc-nci.conf https://android.googlesource.com/device/generic/common/+/master/nfc/libnfc-nci.conf?format=TEXT 2>/dev/null
}

function patch_things() {
	repodir="${PWD}"
	rm -f device/*/sepolicy/common/private/genfs_contexts
	if [ "${android_version}" -eq 12 ] && grep -q lottie packages/apps/Launcher3/Android.bp; then
	    [ -d vendor/partner_gms ] && (cd vendor/partner_gms; wget --output-document=search.patch https://github.com/phhusson/treble_experimentations/raw/master/0001-Fix-SearchLauncher-for-Android-12.1.patch; git am search.patch || true)
	fi
	cd device/phh/treble
	git clean -fdx
	[ -n "$treble_generate" ] && bash generate.sh "$treble_generate" || bash generate.sh
	cd ../../..
	. ./"$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch" | tee -a release/"$rom_fp"/patch-"$rom_fp".log || false
}

function check_dex() {
	read -p "* Do you want to disable pre-opt rom apps? (y/N) " dexa
	if [[ "$dexa" == *"y"* ]]; then
	        reportWarning "! Some roms, will not boot/built when pre-opt is disabled."
		echo -e "
WITH_DEXPREOPT := false 
DISABLE_DEXPREOPT := true
DONT_DEXPREOPT_PREBUILTS := true
LOCAL_DEX_PREOPT := false" >> device/phh/treble/board-base.mk
	else
		cd device/phh/treble
		git checkout -- board-base.mk
		cd ../../..
	fi
}

function gen_mk() {
	if [[ -n "$gen_mk" ]]; then
	repo="${PWD}"
	gen_lunch="${gen_mk}_${gen_target}"
	[ "$localManifestBranch" != *"8"* ] && gen_mk="$gen_lunch"
	cd device/phh/treble
	rm -rf "$gen_mk.mk"
	    cat << EOF >> $gen_mk.mk
`[ -n "$gen_config" ] && echo "$gen_config"`
`[ -n "$gen_sepolicy" ] && echo "$gen_sepolicy"`
`cat $target_name.mk`
EOF
	    sed "s@PRODUCT_NAME.*@PRODUCT_NAME := ${gen_lunch}@" -i $gen_mk.mk
	    sed "s@PRODUCT_MODEL.*@PRODUCT_MODEL := ${gen_lunch}@" -i $gen_mk.mk
	    sed "s@${target_name}@${gen_lunch}@" -i AndroidProducts.mk
	cd "$repo"
	fi
}

function build_variant() {
	read -p "* Do you want to clean before starting build? (y/N) " choicer
	if [[ $choicer == *"y"* ]];then
	    make installclean
	fi
	[[ -n "$gen_lunch" ]] && lunch "$gen_lunch"-userdebug || lunch "$1"
	make $extra_make_options BUILD_NUMBER="$rom_fp" -j "$jobs" systemimage
	make $extra_make_options BUILD_NUMBER="$rom_fp" vndk-test-sepolicy
	
	[ -f "$OUT"/system.img ] && {
		echo -e "* ROM built sucessfully (release/$rom_fp)"
		cp "$OUT"/system.img release/"$rom_fp"/$rom_type-system-"$2".img 

		read -p "* Do you want to compress the built gsi? (y/N) " zipch
			if [[ $zipch == *"y"* ]]; then
				cd r*/"$rom_fp" ; zip -r9 $rom_type-$target_name-"$rom_fp".zip $rom_type-*.img 2>/dev/null
	    	fi
		read -p "* Do you want to upload the built gsi? (y/N) " up
			if [[ $up == *"y"* ]]; then
			gdrive upload --share $rom_type-$target_name-"$rom_fp".zip || echo "Please, install gdrive tool!"
			fi
	} || reportError "BUILD HAS FAILED !"
}

function jack_env() {
	RAM=$(free | awk '/^Mem:/{ printf("%0.f", $2/(1024^2))}')
	if [[ "$RAM" -lt 16 ]]; then
	    export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$(($RAM-1))G"
	fi
}

################
#              #
# SCRIPT START #
#              #
################

prepre_env

if [[ "$1" == "-j" ]]; then
	re='^[0-9]+$'
	if [[ "$2" =~ "$re" ]] ; then
		jobs="$2"
		rom_type="$3"
		targets="$(($#-3))"
		start=3
	else
		reportError "Not a jobs number: $([[ -z $2 ]] && echo \(null\) || echo $2)"
	fi
else
	rom_type="$1"
	targets="$(($#-1))"
	start=1
fi

if [[ "$1" == "--help" ]]; then
	help
	exit 1
fi

get_rom_type "$rom_type"

count=0
while [[ "$count" != "$targets" ]]; do
	count="$((count+1))"
	variant="$((count+start))"
	bvariant="$((variant-1))"
	[ "${!variant}" != "${!bvariant}" ] && get_variants "${!variant}"
done

[[ -z "$variant" ]] && reportError "Invalid defined variant: (null)"

if [[ -n "$mainrepo" && ! ("${#variant_codes[*]}" -eq 0) ]]; then
	say_welcome
fi

read -p "- Do you want to sync? (y/N) " choice
if [[ "$choice" == *"y"* ]]; then
	read -p "* Do you want to clean before sync? (y/N) " choicec
	if [[ $choicec == *"y"* ]]; then
		clean_repo_folder
	fi
	init_main_repo
	init_release
	sync_repo
	init_local_manifest
else
	[ ! -d ".repo" ] && reportWarning "! ROM sources cannot be found. Unexpected errors can be."
fi

read -p "- Do you want to patch? (y/N) " choice2
if [[ $choice2 == *"y"* ]]; then
	fix_missings
	add_mks
	patch_things
else
	reportWarning "! Without patching, ROM will not work."
fi

read -p "- Do you want to start build now? (y/N) " choice3
if [[ $choice3 == *"y"* ]]; then
	check_dex
	jack_env
	init_release
	source build/envsetup.sh 2>&1
	for (( idx=0; idx < ${#variant_codes[*]}; idx++ )); do
	    target_name=$(echo "${variant_codes[$idx]}" | sed 's@-.*@@')
	    gen_mk	
	    printText "Building process started ($((1+$idx))/${#variant_codes[*]})"
	    build_variant "${variant_codes[$idx]}" "${variant_names[$idx]}"
	done
fi
