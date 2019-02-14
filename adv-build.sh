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
ver=0.1

###############
#             #
#  FUNCTIONS  #
#             #
###############

function wc() {
cat << EOF

**************************************************
*        ADVANCED TREBLE ROM BUILD SCRIPT        *
**************************************************
*                                                *
* ! Welcome To Advanced Treble OS Build Script ! *
*                                                *
**************************************************
*      Created By SaMad SegMane (svoboda18)      *
**************************************************

EOF
read -p "Press any key to continue.."
}

function prepre_env() {
if [ -z "$USER" ];then
	export USER="$(id -un)"
fi

export LC_ALL=C

rom_fp="$(date +%y%m%d)"
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

  $myname [-j 2] <rom type> <variant>...

Options:

  -j   number of parallel make workers (defaults to $jobs)

ROM types:

  aosp81
  aosp90
  aospa81
  aospa90
  carbon81
  carbon90
  e-1.0
  e-0.2
  lineage151
  lineage160
  rr81
  rr90
  dot81
  dot90
  du81
  du90
  bliss81
  bliss90
  xpe81
  xpe90
  pixel81
  pixel90
  crdroid81
  crdroid90
  mokee81
  mokee90
  aicp81
  aicp90
  aokp81
  aokp90
  aex90
  aex81
  slim81
  slim90
  havoc81
  havoc90

Variants are dash-joined combinations of (in order):
- Processor type
  * "arm" for ARM 32 bit
  * "arm64" for ARM 64 bit
- A or A/B partition layout ("aonly" or "ab")
- GApps selection
  * "vanilla" to not include GApps
  * "gapps" to include opengapps
  * "go" to include gapps go
  * "floss" to include floss
- SU selection ("su" or "nosu")
- Build variant selection (optional)
  * "eng" for eng build
  * "user" for prod build
  * "userdebug" for debug build (default)

Examples:
- Treble ROM For ARM-A Without Gapps And SU:
  * arm-aonly-vanilla-nosu-user
- Treble ROM For ARM64-AB With Gapps And SU:
  * arm64-ab-gapps-su
EOF
}

function get_rom_type() {
        case "$1" in
            aosp81)
                mainrepo="https://android.googlesource.com/platform/manifest.git"
                mainbranch="android-8.1.0_r48"
                localManifestBranch="android-8.1"
                treble_generate=""
                extra_make_options=""
                ;;
            aosp90)
                mainrepo="https://android.googlesource.com/platform/manifest.git"
                mainbranch="android-9.0.0_r21"
                localManifestBranch="android-9.0"
                treble_generate=""
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
	    e-1.0)
		mainrepo="https://gitlab.e.foundation/e/os/android/"
		mainbranch="v1-oreo"
		localManifestBranch="android-8.1"
		treble_generate="lineage"
		extra_make_options="WITHOUT_CHECK_API=true"
		;;
            e-0.2)
                mainrepo="https://gitlab.e.foundation/e/os/android/"
                mainbranch="eelo-0.2"
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
		gen_sepolicy=""
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
		gen_sepolicy=""
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
		mainbranch="o-8.1"
		localManifestBranch="android-8.1"
		treble_generate="bliss"
		extra_make_options="WITHOUT_CHECK_API=true"
		;;
	    bliss90)
		mainrepo="https://github.com/BlissRoms/platform_manifest.git"
		mainbranch="p-9.0"
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
		mainbranch="9.0"
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

function parse_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -j)
                jobs="$2";
                shift;
                ;;
        esac
        shift
    done
}

declare -A partition_layout_map
partition_layout_map[aonly]=a
partition_layout_map[ab]=b

declare -A gapps_selection_map
gapps_selection_map[vanilla]=v
gapps_selection_map[gapps]=g
gapps_selection_map[go]=o
gapps_selection_map[floss]=f

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
    while [[ $# -gt 0 ]]; do
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
    done
}

function init_release() {
	mkdir -p release/"$rom_fp"
}

function init_main_repo() {
	repo init --depth=1 -u "$mainrepo" -b "$mainbranch"
}

function clone_or_checkout() {
	local dir="$1"
	local repo="$2"
        localManifestBranch_old="$localManifestBranch"
	[ -z "$3" ] || localManifestBranch="$3"
	
	if [[ -d "$dir" ]];then
		(
			cd "$dir"
			git reset --hard
			git checkout origin/"$localManifestBranch"
		)
	else
		git clone https://github.com/phhusson/"$repo" "$dir" -b "$localManifestBranch"
	fi
	
	localManifestBranch="$localManifestBranch_old"
}

function init_local_manifest() {
	clone_or_checkout device/phh/treble device_phh_treble
        clone_or_checkout vendor/vndk vendor_vndk master
        sed '/hardware_overlay/d' -i device/phh/treble/base.mk
}

function sync_repo() {
        repo sync -c -j"$jobs" --no-clone-bundle --no-tags
}

function clean_repo_folder() {
	rm -rf .repo *
}

function add_mks() {
	cp -r $(dirname "$0")/mks/. device/phh/treble
}

function add_files() {
	if [[ "$localManifestBranch" == *"9"* ]]; then
		rm -r device/phh/treble/cmds/Android.bp
		cp -r $(dirname "$0")/rfiles/cmdsbp device/phh/treble/cmds/Android.bp

		# fix kernel source missing (on pie)
		sed 's;.*KERNEL_;//&;' -i vendor/$treble_generate/build/soong/Android.bp
	fi
	find $(dirname "$0")/rfiles/ -name '*.rc' -exec cp -prv '{}' 'device/phh/treble/' ';' &> /dev/null
	find $(dirname "$0")/rfiles/ -name '*.sh' -exec cp -prv '{}' 'device/phh/treble/' ';' &> /dev/null

	# add change_device_name to build
	if ! grep -Eq 'change-device-name.sh' device/phh/treble/base.mk; then
		(cat device/phh/treble/base.mk ; echo '
PRODUCT_COPY_FILES += \
	device/phh/treble/device.rc:system/etc/init/device.rc \
	device/phh/treble/change-device-name.sh:system/bin/change-device-name.sh') | cat - >> device/phh/treble/base.mk2
		rm -f device/phh/treble/base.mk ; mv device/phh/treble/base.mk2 device/phh/treble/base.mk
	fi
}

function fix_missings() {
	wget -O apns-full-conf.xml https://github.com/LineageOS/android_vendor_lineage/raw/lineage-16.0/prebuilt/common/etc/apns-conf.xml 2>/dev/null
	mkdir -p device/sample/etc
       	cp -r apns-full-conf.xml device/sample/etc/
	rm -rf apns*.xml
}
 
function patch_things() {
	if [[ -n "$treble_generate" ]]; then
		repodir="${PWD}"
		rm -f device/*/sepolicy/common/private/genfs_contexts
			(
				cd device/phh/treble
			        git clean -fdx
				bash generate.sh "$treble_generate"
				cd ../../..
			)
		bash "$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch"
	else
		repodir="${PWD}"
		cd device/phh/treble
		bash generate.sh
		cd ../../..
		bash "$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch"
	fi
}

function gen_mk() {
	if [[ -n "$gen_mk" ]]; then
		ldir=${PWD}
		cd device/phh/treble
		cp $treble_var.mk $gen_mk.mk
		sed '/PRODUCT_NAME/d' -i $gen_mk.mk
		echo "PRODUCT_NAME := ${gen_mk}_$gen_target" >> $gen_mk.mk
		lunch_mk=${gen_mk}_${gen_target}
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
		if ! grep -Eq 'DEXPREOPT' device/phh/treble/board-base.mk; then
			echo "WITH_DEXPREOPT := false" >> device/phh/treble/board-base.mk
			echo "DISABLE_DEXPREOPT := true" >> device/phh/treble/board-base.mk
			echo "DONT_DEXPREOPT_PREBUILTS := true" >> device/phh/treble/board-base.mk
			echo "LOCAL_DEX_PREOPT := false" >> device/phh/treble/board-base.mk
		fi
	else
		wget -O board-base.mk.bak https://github.com/phhusson/device_phh_treble/raw/$localManifestBranch/board-base.mk 2>/dev/null
		rm -f device/phh/treble/board-base.mk ; cp -r board-base.mk.bak device/phh/treble/board-base.mk
	fi
}

function build_variant() {
    read -p "* Do you want to clean before starting build? (y/N) " choicer
    if [[ $choicer == *"y"* ]];then
     make installclean
    fi
    [[ -n "$lunch_mk" ]] && lunch "$lunch_mk" || lunch "$1"
    make $extra_make_options ANDROID_COMPILE_WITH_JACK:=false  BUILD_NUMBER="$rom_fp" -j "$jobs" systemimage
    [ -f "$OUT"/system.img ] && cp "$OUT"/system.img release/"$rom_fp"/system-"$2".img || echo -e "\nBUILD ERROR ! \n"
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

parse_options "$@"
get_rom_type "$@"
get_variants "$@"


if [[ -z "$mainrepo" || ${#variant_codes[*]} -eq 0 || "$1" == "--help" ]]; then
	>&2 help
	exit 1
else
	wc
fi

treble_var=$(echo "$variant_codes[${#variant_codes}]" | sed 's@-.*@@')

python=$(python -V 2>&1)
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
	init_local_manifest
	sync_repo
fi

read -p "- Do you want to patch? (y/N) " choice2
if [[ $choice2 == *"y"* ]];then
	patch_things
fi

fix_missings
add_mks
add_files

read -p "- Do you want to start build now? (y/N) " choice3
if [[ $choice3 == *"y"* ]];then
	gen_mk
	check_dex
	jack_env
        . build/envsetup.sh
	for (( idx=0; idx < ${#variant_codes[*]}; idx++ )); do
		build_variant "${variant_codes[$idx]}" "${variant_names[$idx]}"
	done
fi
