#!/bin/bash

#
# Copyright (C) 2019-2022 by SaMad SegMane (svoboda18)
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
set -eE
trap 'reportError "An unexpected error occurred!" _' ERR
shopt -s extglob

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
YES=false

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
	trap - ERR
	[ -n "$2" ] && exit 1
	echo -e ${GRN}"Run \"bash $myname --help\" for usage information."${RST} 
	echo -e ""
	exit 1
}

function reportWarning() {
	echo -e ${YLW}"${1}"${RST}
}

function reportMessage() {
	read -t 10 -ep "$1";
	[[ "$REPLY" =~ ^(y|Y).?.?$ ]] && YES=true || YES=false
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
echo -e "${BLD}Advanced GSI ROM Builder Script v$VER by SaMad SegMane (svoboda18)\n
Syntax:
  $myname${RST} [options..] <rom type> <variant> [<variant2>...]

  Symbol [...] signify optional arguments, and <...> signifies required ones.
  
  Each variant will be built respectivly to the arguments order, with unique fingerprint, variant duplications are ignored and the output is set inside "release" folder created in the working directory.
${BLD}
Options:
${RST}
  -j <N>,--jobs <N>,j=N,--jobs=N\t\tnumber of threads used. (defaults to $jobs)
${BLD}
ROM types:
${RST}
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
${BLD}
Variants syntax:
${RST}
Variants are dash-joined combinations of (in order):
- Processor type
  * "arm" for ARM 32 bit (android 11 and below)
  * "arm64" for ARM 64 bit
  * "a64" for ARM 32 bit system with 64 bit binder
- A or A/B partition layout ("aonly" or "ab")
  * "aonly" only available for android 10 and below.
- GApps selection
  * "vanilla" to not include GApps.
  * "gapps" to include gapps.
  * "gappsgo" to include go gapps.
  * "foss" to include foss apps.
! SU selection (android 9 and below)
  * "su" with root permissions
  * "nosu" without root permissions
- Build variant selection (optional)
  * "eng" for eng build.
  * "user" for prod build (some errors are expected).
  * "userdebug" for debug build (default).
${BLD}
Note:
${RST}
* For secure, vndk-lite and a-only builds for andorid 11, use scripts
located in repo "sas-creator" folder.

Examples:
- GSI ROM for ARM-A without Gapps and SU:
  * arm-aonly-vanilla-nosu"
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
		    reportError "Unknown ROM type: $1"
		    ;;
	    esac
}

function parse_variant() {
	local -A partition_layout_map
	partition_layout_map[aonly]=a
	partition_layout_map[ab]=b

	local -A apps_selection_map
	apps_selection_map[vanilla]=v
	apps_selection_map[gapps]=g
	apps_selection_map[gappsgo]=o
	apps_selection_map[foss]=f

	local -A su_selection_map
	su_selection_map[su]=S
	su_selection_map[nosu]=N

	IFS=-
	local -a pieces=( $1 )
	local nb_pieces=(${#pieces[*]}-1)
	local processor_type=${pieces[0]}
	local partition_layout=${partition_layout_map[${pieces[1]}]}

	local apps_selection=${apps_selection_map[${pieces[2]}]}
	local su_selection=${su_selection_map[${pieces[3]}]}
	local build_type_selection=${pieces[$nb_pieces]}

	if [[ -z "$processor_type" || -z "$partition_layout" || -z "$apps_selection" ]] ||
	   [[ $(get_android_version) -gt 10 && "$partition_layout" == "a" ]] ||
	   [[ $(get_android_version) -gt 11 && "$processor_type" == "arm" ]] ||
	   [[ $(get_android_version) -gt 9 && -n "$su_selection" ]] ||
	   [[ $(get_android_version) -le 9 && -z "$su_selection" ]]; then
		>&2 reportError "Invalid defined variant: $1 (android version $(get_android_version))"
	fi

	[[ $(get_android_version) -gt 9 ]] && su_selection="S"

	echo "treble_${processor_type}_${partition_layout}${apps_selection}${su_selection}-${build_type_selection}"
}

function get_variants() {
	declare -a -g variant_codes
	declare -a -g variant_names
	declare -A -g variants_map
	    
	local -A build_map
	build_map[android-12.1]=squeak
	build_map[android-11.0]=roar
	build_map[android-10.0]=quack
	build_map[android-9.0]=pie
	build_map[android-8.1]=oreo

	local idx=${#variant_codes[*]}

	variant_names[$idx]="${build_map[$localManifestBranch]}-$1"
	variants_map["$1"]=$idx

	case "$1" in
	    *-*-*-*-*|*-*-*-[ue]*)
		variant_codes[$idx]=$(parse_variant "$1");;
	    *-*-*-*|*-*-*)
		variant_codes[$idx]=$(parse_variant "$1-userdebug");;
	    *) reportError "Invalid defined variant: $1";;
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

	[ -d "$dir" ] && rm -rf "$dir"
	git -c advice.detachedHead=false clone --depth=1 $([ -n "$brn" ] && echo "--branch $brn") "$repo" "$dir"
	[ "$(get_android_version)" -le 9 ] && (cd "$dir"; git lfs fetch && git lfs checkout)
}

function get_android_version() {
	awk -F'[-.]' '{ print $2 }' <<< $localManifestBranch
} 

function init_local_manifest() {
	local overlay_branch="master"
	local interfaces_branch="master"
	local device_branch="${localManifestBranch}"
	local vndk_branch="master"
	local magisk_branch="master"
	local vndk_path="vendor/vndk"
	local sas_target=false
	local magisk_target=false
	local lptools_target=false
	local android_version=$(get_android_version)

	if [[ "${android_version}" -ge 9 ]]; then
	     overlay_branch="pie"
	     interfaces_branch="pie"
	     magisk_target=true
	     if [[ "${android_version}" -ge 10 ]]; then
	        vndk_branch="android-10.0"
		magisk_branch="android-10.0"
	        if [[ "${android_version}" -ge 11 ]]; then
	           sas_target=true
	           vndk_path=phh_sas
	           interfaces_branch="android-11.0"
	         
	           if [[ "${android_version}" -eq 12 ]]; then
	              device_branch="android-12.0"
		      lptools_target=true
		   fi
		fi
	     fi
	fi
	force_clone device/phh/treble device_phh_treble ${device_branch}
	force_clone vendor/hardware_overlay vendor_hardware_overlay ${overlay_branch}

	force_clone vendor/interfaces vendor_interfaces ${interfaces_branch}
	force_clone vendor/vndk-tests vendor_vndk-tests master
	force_clone vendor/gapps-go gapps-go master
	force_clone vendor/foss vendor_foss master
	force_clone ${vndk_path} vendor_vndk ${vndk_branch}
	g_clone https://gitlab.com/fdroid/privileged-extension.git packages/apps/FDroidPrivilegedExtension 0.2.7 || true
	$sas_target && force_clone phh_sas sas-creator master
	$magisk_target && force_clone vendor/magisk vendor_magisk ${magisk_branch}
	$lptools_target && force_clone vendor/lptools vendor_lptools master

	reportMessage "- Do you want to sync gapps packages? (y/N) "
	if $YES;then
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
	(cd device/phh/treble; git clean -fdx; bash generate.sh "$treble_generate")
	. ./"$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch" | tee -a release/"$rom_fp"/patch-"$rom_fp".log || false
}

function check_dex() {
	reportMessage "* Do you want to disable pre-opt rom apps? (y/N) "
	if $YES; then
	        reportWarning "! Disabling pre-opt results in slower first boot"
		echo -e "
WITH_DEXPREOPT := false 
DISABLE_DEXPREOPT := true
DONT_DEXPREOPT_PREBUILTS := true
LOCAL_DEX_PREOPT := false" >> device/phh/treble/board-base.mk
	else
		(cd device/phh/treble; git checkout -- board-base.mk)
	fi
}

function gen_mk() {
	if [[ -n "$gen_mk" ]]; then
	   declare -g gen_lunch="${gen_mk}_${gen_target}"
	   local gen="${gen_mk}"
	   [ $(get_android_version) -gt 8 ] && gen="$gen_lunch"
	   (cd device/phh/treble;
	   cat << EOF > $gen.mk
$gen_config
$gen_sepolicy
`cat $target_name.mk`
EOF
	   cat << EOF >> AndroidProducts.mk
PRODUCT_MAKEFILES += \\
	\$(LOCAL_DIR)/$gen.mk
COMMON_LUNCH_CHOICES := \\
	${gen_lunch}-${build_type}
EOF
           sed "s@PRODUCT_NAME.*@PRODUCT_NAME := ${gen_lunch}@" -i $gen.mk)
	   #sed "s@PRODUCT_MODEL.*@PRODUCT_MODEL := ${gen_lunch}@" -i $gen.mk
	fi
}

function build_variant() {
	reportMessage "* Do you want to clean before starting build? (y/N) "
	if $YES; then
	    make installclean
	fi
	[[ -n "$gen_lunch" ]] && lunch "$gen_lunch"-"$build_type" || lunch "$1"
	make $extra_make_options BUILD_NUMBER="$rom_fp" -j "$jobs" systemimage
	make $extra_make_options BUILD_NUMBER="$rom_fp" vndk-test-sepolicy

	[ ! -f "$OUT"/system.img ] && reportError "! BUILD FAILED" _

	echo -e "* ROM built sucessfully (release/$rom_fp)"

	# TO-DO
	#reportMessage "* Do you want to securize the built gsi? (y/N) "
	#if $YES; then
	#	(cd phh-sas; bash securize.sh "$OUT"/system.img)
	#fi

	cp "$OUT"/system.img release/"$rom_fp"/"$rom_type"-system-"$2".img

	reportMessage "* Do you want to compress the built gsi? (y/N) "
	if $YES; then
	    cd release/"$rom_fp"; zip -r9 $rom_type-$target_name-"$rom_fp".zip $rom_type-*.img 2>/dev/null
	fi

	reportMessage "* Do you want to upload the built gsi? (y/N) "
	if $YES; then
	    gdrive upload --share $rom_type-$target_name-"$rom_fp".zip || echo "Please, install gdrive tool!"
	fi
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

function set_jobs_number() {
    [[ "$1" =~ ^[0-9]+$ ]] && jobs=$1 || reportError "Not a jobs number: $([[ -z $1 ]] && echo "(null)" || echo $1)"
}

prepre_env

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) help; exit 1 ;;
        -j|--jobs) shift; set_jobs_number "$1";;
	-j=*|--jobs=*) set_jobs_number "${1#*=}";;
        *-*) [ -z "${variants_map["$1"]}" ] && get_variants "$1";;
        *) [ -z "$mainrepo" ] && get_rom_type "$1";;
    esac
    shift
done

if [ -z "$mainrepo" ]; then
    reportError "Unknown ROM type: (null)"
elif [[ "${#variant_codes[*]}" -eq 0 ]]; then
    reportError "Invalid defined variant: (null)"
fi

echo "Using jobs: $jobs"

say_welcome

reportMessage "- Do you want to sync? (y/N) "
if $YES; then
	reportMessage "* Do you want to clean before sync? (y/N) "
	if $YES; then
	    clean_repo_folder
	fi
	init_main_repo
	init_release
	sync_repo
	init_local_manifest
else
	[ ! -d ".repo" ] && reportWarning "! ROM sources cannot be found."
fi

reportMessage "- Do you want to patch? (y/N) "
if $YES; then
	fix_missings
	add_mks
	patch_things
else
	reportWarning "! Patching is required, if this is the first time build."
fi

reportMessage "- Do you want to start build now? (y/N) "
if $YES; then
	check_dex
	jack_env
	init_release
	source build/envsetup.sh 2>&1 || false
	for (( idx=0; idx < ${#variant_codes[*]}; idx++ )); do
	    declare -g target_name=${variant_codes[$idx]%-*}
	    declare -g build_type=${variant_codes[$idx]#*-}
	    gen_mk

	    printText "Building process started ($((1+$idx))/${#variant_codes[*]})"
	    build_variant "${variant_codes[$idx]}" "${variant_names[$idx]}"
	done
fi
