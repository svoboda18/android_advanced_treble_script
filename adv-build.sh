#!/bin/bash
set -e
## welcome
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
}

wc
read -p "Press any key to continue.."

if [ -z "$USER" ];then
	    export USER="$(id -un)"
    fi
    export LC_ALL=C

    ## set defaults

    rom_fp="$(date +%y%m%d)"

    myname="$(basename "$0")"
    if [[ $(uname -s) = "Darwin" ]];then
	        jobs=$(sysctl -n hw.ncpu)
	elif [[ $(uname -s) = "Linux" ]];then
		    jobs=$(nproc --all)
	    fi

	    ## handle command line arguments
	    read -p "- Do you want to sync? (y/N) " choice

	    function help() {
		        cat <<EOF
Syntax:

  $myname [-j 2] <rom type> <variant>...

Options:

  -j   number of parallel make workers (defaults to $jobs)

ROM types:

  aosp81
  aosp90
  carbon
  e-0.2
  lineage151
  lineage160
  rr
  bliss81
  bliss90
  xpe81
  xpe90
  pixel81
  pixel90
  crdroid
  mokee
  aicp
  aokp
  aex90
  aex81
  slim
  havoc

Variants are dash-joined combinations of (in order):
* processor type
  * "arm" for ARM 32 bit
  * "arm64" for ARM 64 bit
* A or A/B partition layout ("aonly" or "ab")
* GApps selection
  * "vanilla" to not include GApps
  * "gapps" to include opengapps
  * "go" to include gapps go
  * "floss" to include floss
* SU selection ("su" or "nosu")
* Build variant selection (optional)
  * "eng" for eng build
  * "user" for prod build
  * "userdebug" for debug build (default)

for example:

* arm-aonly-vanilla-nosu-user
* arm64-ab-gapps-su
EOF
}

function get_rom_type() {
    while [[ $# -gt 0 ]]; do
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
            carbon)
                mainrepo="https://github.com/CarbonROM/android.git"
                mainbranch="cr-6.1"
                localManifestBranch="android-8.1"
                treble_generate="carbon"
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
            rr)
                mainrepo="https://github.com/ResurrectionRemix/platform_manifest.git"
                mainbranch="oreo"
                localManifestBranch="android-8.1"
                treble_generate="rr"
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
            crdroid)
                mainrepo="https://github.com/crdroidandroid/android.git"
                mainbranch="8.1"
                localManifestBranch="android-8.1"
                treble_generate="crdroid"
                extra_make_options="WITHOUT_CHECK_API=true"
                ;;
            mokee)
                mainrepo="https://github.com/MoKee/android.git"
                mainbranch="mko-mr1"
                localManifestBranch="android-8.1"
                treble_generate="mokee"
                extra_make_options="WITHOUT_CHECK_API=true"
                ;;
            aicp)
                mainrepo="https://github.com/AICP/platform_manifest.git"
                mainbranch="o8.1"
                localManifestBranch="android-8.1"
                treble_generate="aicp"
                extra_make_options="WITHOUT_CHECK_API=true"
                ;;
            aokp)
                mainrepo="https://github.com/AOKP/platform_manifest.git"
                mainbranch="oreo"
                localManifestBranch="android-8.1"
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
            slim)
                mainrepo="https://github.com/SlimRoms/platform_manifest.git"
                mainbranch="or8.1"
                localManifestBranch="android-8.1"
                treble_generate="slim"
                extra_make_options="WITHOUT_CHECK_API=true"
                ;;
	   havoc)
                mainrepo="https://github.com/Havoc-OS/android_manifest.git"
                mainbranch="pie"
                localManifestBranch="android-9.0"
                treble_generate="havoc"
                extra_make_options="WITHOUT_CHECK_API=true"
                ;;
        esac
        shift
    done
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
        >&2 echo "Invalid variant '$1'"
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
## function that actually do things

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
	clone_or_checkout vendor/hardware_overlay vendor_hardware_overlay master
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

function fix_missings() {
	wget -O apns-full-conf.xml https://github.com/LineageOS/android_vendor_lineage/raw/lineage-16.0/prebuilt/common/etc/apns-conf.xml
	mkdir -p device/sample/etc
       	cp -r apns-full-conf.xml device/sample/etc/
}
 
function patch_things() {
	if [[ -n "$treble_generate" ]]; then
		repodir="${PWD}"
		rm -f device/*/sepolicy/common/private/genfs_contexts
			(
				cd device/phh/treble
				    if [[ $choice == *"y"* ]];then
			        git clean -fdx
					fi
				bash generate.sh "$treble_generate"
			)
		bash "$(dirname "$0")/apply-patches.sh" "$repodir" "$localManifestBranch"
	else
		(
			cd device/phh/treble
			git clean -fdx
			bash generate.sh
		)
	repo manifest -r > release/"$rom_fp"/manifest.xml
	zip -r9 patches.zip "$(dirname "$0")/patches"
	cp patches.zip release/"$rom_fp"/patches.zip
	fi
}

function build_variant() {
#    read -p "* Do you want to clean before starting build? (y/N) " choicer
#    if [[ $choicer == *"y"* ]];then
#    make installclean
#    make clean
#    fi
    lunch "$1"
    make $extra_make_options BUILD_NUMBER="$rom_fp" -j "$jobs" systemimage
    cp "$OUT"/system.img release/"$rom_fp"/system-"$2".img
}

function jack_env() {
    RAM=$(free | awk '/^Mem:/{ printf("%0.f", $2/(1024^2))}') #calculating how much RAM (wow, such ram)
    if [[ "$RAM" -lt 16 ]];then #if we're poor guys with less than 16gb
	export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx"$((RAM -1))"G"
    fi
}

parse_options "$@"
get_rom_type "$@"
get_variants "$@"

if [[ -z "$mainrepo" || ${#variant_codes[*]} -eq 0 ]]; then
    >&2 help
    exit 1
fi    

python=$(python -V 2>&1)
if [[ "$python" == *"3."* ]]; then
	if [ ! -d .venv ]; then
		virtualenv2 .venv
	fi
	. .venv/bin/activate
fi

init_release

if [[ $choice == *"y"* ]];then
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

read -p "- Do you want to start build now? (y/N) " choice3
if [[ $choice3 == *"y"* ]];then
	jack_env
	source build/envsetup.sh
	for (( idx=0; idx < ${#variant_codes[*]}; idx++ )); do
		build_variant "${variant_codes[$idx]}" "${variant_names[$idx]}"
	done
fi
