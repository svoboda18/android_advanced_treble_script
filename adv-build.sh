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

###############
#             #
#  VARIABLES  #
#             #
###############

set -e
ver=1

###############
#             #
#  FUNCTIONS  #
#             #
###############

function say_welcome() {
cat << EOF

**************************************************
*      × ADVANCED TREBLE ROM BUILD SCRIPT ×      *
*                    VERSION $ver			 *
**************************************************
*                                                *
* ! Welcome To Advanced Treble OS Build Script ! *
*                                                *
**************************************************
*      Created By SaMad SegMane (svoboda18)      *
**************************************************
EOF
read
}

function prepre_env() {
if [ -z "$USER" ];then
	export USER="$(id -un)"
fi

export LC_ALL=C

rom_fp="$(date +%y%m%d%S)"
myname="$(basename "$0")"

if [[ $(uname -s) = "Darwin" ]];then
	jobs=$(sysctl -n hw.ncpu)
elif [[ $(uname -s) = "Linux" ]];then
	jobs=$(nproc --all)
fi
}

function help() {
cat <<EOF
Advanced Treble ROM Builder Script v$ver by SaMad SegMane (svoboda18)

Usage Help:

Syntax:

  $myname [-j 2] <rom type> <variant> [<variant2> <variant3>..]
  []: that options are optimal.
  <>: that options are required.

Options:

  -j   number of parallel make workers (defaults to $jobs)

ROM types:

  aosp81
  aosp90
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
- SU selection ("su" or "nosu")
- Build variant selection (optional)
  * "eng" for eng build
  * "user" for prod build
  * "userdebug" for debug build (default)

Examples:
- GSI ROM For ARM-A Without Gapps And SU:
  * arm-aonly-vanilla-nosu-user
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
                mainbranch="android-9.0.0_r47"
                localManifestBranch="android-9.0"
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
                mainrepo="https://github.com/PixelExperience/manifest.git"
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
		echo -e "\nUnknown ROM type: $1\n" ; help ; exit 1
		;;
        esac
}

declare -A partition_layout_map
partition_layout_map[aonly]=a
partition_layout_map[ab]=b

declare -A gapps_selection_map
gapps_selection_map[vanilla]=v
gapps_selection_map[gapps]=g
#gapps_selection_map[go]=o
#gapps_selection_map[floss]=f

declare -A su_selection_map
su_selection_map[su]=S
su_selection_map[nosu]=N
function parse_variant() {
    local -a pieces
    IFS=- pieces=( $1 )

    local processor_type=${pieces[0]}
    local partition_layout=${partition_layout_map[${pieces[1]}]}
    local gapps_selection=${gapps_selection_map[${pieces[2]}]}
    local su_selection=${su_selection_map[${pieces[3]}]}
    local build_type_selection=${pieces[4]}

    if [[ -z "$processor_type" || -z "$partition_layout" || -z "$gapps_selection" || -z "$su_selection" ]]; then
        >&2 echo -e "\nInvalid defined variant: $1 \n"
        >&2 help
        exit 2
    fi

    echo "treble_${processor_type}_${partition_layout}${gapps_selection}${su_selection}-${build_type_selection}"
}

declare -a variant_codes
declare -a variant_names
function get_variants() {
        case "$1" in
            *-*-*-*-*)
                variant_codes[${#variant_codes[*]}]=$(parse_variant "$1")
                variant_names[${#variant_names[*]}]="$1"
                ;;
            *-*-*-*)
                variant_codes[${#variant_codes[*]}]=$(parse_variant "$1-userdebug")
                variant_names[${#variant_names[*]}]="$1"
                ;;
        esac
        shift
}

function init_release() {
	mkdir -p release/"$rom_fp"
}

function init_main_repo() {
	repo init -u "$mainrepo" -b "$mainbranch"
}

function force_clone() {
	local dir="$1"
	local repo="$2"
        localManifestBranch_old="$localManifestBranch"
	[ -z "$3" ] || localManifestBranch="$3"
	
	[ -d "$dir" ] && rm -rf "$dir"
	git clone https://github.com/phhusson/"$repo" "$dir" -b "$localManifestBranch"
	
	localManifestBranch="$localManifestBranch_old"
}

function g_clone() {
	[ -d "$2" ] && rm -rf $2
	git clone --depth=1 $1 $2 $(echo $3)
}

function init_local_manifest() {
	force_clone device/phh/treble device_phh_treble
        force_clone vendor/vndk vendor_vndk master
	if [[ "$localManifestBranch" = *"9"* ]]; then
		force_clone vendor/interfaces vendor_interfaces pie
		force_clone vendor/hardware_overlay vendor_hardware_overlay pie
	else
        	force_clone vendor/interfaces vendor_interfaces master
		force_clone vendor/hardware_overlay vendor_hardware_overlay master
	fi
	force_clone vendor/vndk-tests vendor_vndk-tests master
	
	read -p "- Do you want to sync gapps packages? (y/N) " g
        if [[ $g == *"y"* ]];then
		g_clone https://github.com/opengapps/aosp_build vendor/opengapps/build
		g_clone https://gitlab.opengapps.org/opengapps/all vendor/opengapps/sources/all
		g_clone https://gitlab.opengapps.org/opengapps/arm vendor/opengapps/sources/arm
		g_clone https://gitlab.opengapps.org/opengapps/arm64 vendor/opengapps/sources/arm64
	fi
}

function sync_repo() {
        repo sync -c -j"$jobs" --force-broken --no-clone-bundle --no-tags
}

function clean_repo_folder() {
	rm -rf .repo *
}

function add_mks() {
	cp -r $(dirname "$0")/mks/* device/phh/treble
}

function fix_missings() {
	if [[ "$localManifestBranch" == *"9"* ]]; then
		# fix kernel source missing (on pie)
		sed 's;.*KERNEL_;//&;' -i vendor/*/build/soong/Android.bp 2>/dev/null || true
		rm -rf vendor/*/packages/overlays/NoCutout*
	fi
	mkdir -p device/sample/etc
	wget --output-document=device/sample/etc/apns-full-conf.xml https://github.com/LineageOS/android_vendor_lineage/raw/lineage-16.0/prebuilt/common/etc/apns-conf.xml 2>/dev/null

}

function patch_things() {
   	repodir="${PWD}"
    	rm -f device/*/sepolicy/common/private/genfs_contexts
	cd device/phh/treble
	git clean -fdx
	[ -n "$treble_generate" ] && bash generate.sh "$treble_generate" || bash generate.sh
	cd ../../..
	bash "$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch" | tee -a release/"$rom_fp"/patch-"$rom_fp".log
}

function gen_mk() {
	if [[ -n "$gen_mk" ]]; then
		ldir=${PWD}
		gen_lunch=${gen_mk}_${gen_target}
		[ "$localManifestBranch" = *"9"* ] && gen_mk=$gen_lunch
		cd device/phh/treble
		cp $target_name.mk $gen_mk.mk
		sed "s@PRODUCT_NAME.*@PRODUCT_NAME := ${gen_lunch}@" -i $gen_mk.mk
		sed "s@PRODUCT_MODEL.*@PRODUCT_MODEL := ${gen_lunch}@" -i $gen_mk.mk
		[ ! -z "$gen_sepolicy" ] && {
			(echo "$gen_sepolicy" ; cat $gen_mk.mk) | cat - >> $gen_mk.mk2
			rm -f $gen_mk.mk ; mv $gen_mk.mk2 $gen_mk.mk
		}
		[ ! -z "$gen_config" ] && {
			(echo "$gen_config" ; cat $gen_mk.mk) | cat - >> $gen_mk.mk2
			rm -f $gen_mk.mk ; mv $gen_mk.mk2 $gen_mk.mk
		}
		cd $ldir
	fi
}

function check_dex() {
	read -p "* Do you want to disable pre-opt rom apps? (y/N) " dexa
	if [[ "$dexa" == *"y"* ]]; then
		echo "WITH_DEXPREOPT := false" >> device/phh/treble/board-base.mk
		echo "DISABLE_DEXPREOPT := true" >> device/phh/treble/board-base.mk
		echo "DONT_DEXPREOPT_PREBUILTS := true" >> device/phh/treble/board-base.mk
		echo "LOCAL_DEX_PREOPT := false" >> device/phh/treble/board-base.mk
	else
		sed 's;.*PREOPT.*;#&;' -i device/phh/treble/board-base.mk
	fi
}

function build_variant() {
    read -p "* Do you want to clean before starting build? (y/N) " choicer
    if [[ $choicer == *"y"* ]];then
    	make installclean
    fi
    [[ -n "$gen_lunch" ]] && lunch "$gen_lunch" || lunch "$1"
    make $extra_make_options BUILD_NUMBER="$rom_fp" -j "$jobs" systemimage
    make $extra_make_options BUILD_NUMBER="$rom_fp" vndk-test-sepolicy
    [ -f "$OUT"/system.img ] && {
    	echo -e "* ROM built sucessfully (release/$rom_fp)"
    	cp "$OUT"/system.img release/"$rom_fp"/$rom_type-system-"$2".img 

    	read -p "* Do you want to compress the built gsi? (y/N) " zipch
    		if [[ $zipch == *"y"* ]]; then
    			cd r*/"$rom_fp" ; zip -r9 $rom_type-$target_name-adv.zip $rom_type-*.img 2>/dev/null
	    	fi
    	read -p "* Do you want to upload the built gsi? (y/N) " up
    		if [[ $up == *"y"* ]]; then
			gdrive upload --share $rom_type-$target_name-adv.zip || echo "Please, install gdrive tool!"
    		fi
    } || echo -e "\nBUILD ERROR ! \n"
}

function jack_env() {
    RAM=$(free | awk '/^Mem:/{ printf("%0.f", $2/(1024^2))}') #calculating how much RAM (wow, such ram)
    if [[ "$RAM" -lt 16 ]];then #if we're poor guys with less than 16gb
	export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx"$((RAM -1))"G"
    fi
}

################
#              #
# SCRIPT START #
#              #
################

prepre_env

if [[ $1 == "-j" ]]; then
	re='^[0-9]+$'
	if [[ $2 =~ $re ]] ; then
		jobs="$2"
		rom_type="$3"
		targets="$(($#-3))"
		start='3'
	else
		echo -e "\nNot a jobs number: $2\n" ; help ; exit 1
	fi
else
	rom_type="$1"
	targets="$(($#-1))"
	start='1'
fi

get_rom_type "$rom_type"

count=0
while [[ "$count" != "$targets" ]]; do
	count="$(($count+1))"
	variant="$(($count+$start))"
	get_variants "${!variant}"
done


if [[ -z "$mainrepo" || ${#variant_codes[*]} -eq 0 || "$1" == "--help" ]]; then
	>&2 help
	exit 1
else
	say_welcome
fi

python=$(python -V 2>&1 || true)
if [[ "$python" == *"3."* ]]; then
	if [ ! -d .venv ]; then
		virtualenv2 .venv
	fi
	. .venv/bin/activate
fi

init_release

read -p "- Do you want to sync? (y/N) " choice
if [[ "$choice" == *"y"* ]];then
	read -p "* Do you want to clean before sync? (y/N) " choicec
	if [[ $choicec == *"y"* ]];then
		clean_repo_folder
	fi
	init_main_repo
	sync_repo
	init_local_manifest
fi

read -p "- Do you want to patch? (y/N) " choice2
if [[ $choice2 == *"y"* ]];then
	fix_missings
	patch_things
fi

add_mks

read -p "- Do you want to start build now? (y/N) " choice3
if [[ $choice3 == *"y"* ]];then
	check_dex
	jack_env
        . build/envsetup.sh
	for (( idx=0; idx < ${#variant_codes[*]}; idx++ )); do
		target_name=$(echo "${variant_codes[$idx]}" | sed 's@-.*@@')
		gen_mk
		build_variant "${variant_codes[$idx]}" "${variant_names[$idx]}"
	done
fi
