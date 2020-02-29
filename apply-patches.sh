#!/bin/bash
#
# Copyright (C) 2017 Nathan Chancellor
# Copyright (C) 2019 SaMad SegMne
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>


###########
#         #
#  USAGE  #
#         #
###########

# PURPOSE: Merge GSI patches and changes from phhusson git into your rom repos
#
# USAGE: $ bash apply_patches.sh -h


############
#          #
#  COLORS  #
#          #
############

BOLD="\033[1m"
GREEN="\033[01;32m"
RED="\033[01;31m"
RESTORE="\033[0m"


###############
#             #
#  FUNCTIONS  #
#             #
###############

# PRINTS A FORMATTED HEADER TO POINT OUT WHAT IS BEING DONE TO THE USER
function echoText() {
    echo -e ${RED}
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e "==  ${1}  =="
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e ${RESTORE}
}

# FORMATS THE TIME
function format_time() {
    MINS=$(((${1}-${2})/60))
    SECS=$(((${1}-${2})%60))
    if [[ ${MINS} -ge 60 ]]; then
        HOURS=$((${MINS}/60))
        MINS=$((${MINS}%60))
    fi

    if [[ ${HOURS} -eq 1 ]]; then
        TIME_STRING+="1 HOUR, "
    elif [[ ${HOURS} -ge 2 ]]; then
        TIME_STRING+="${HOURS} HOURS, "
    fi

    if [[ ${MINS} -eq 1 ]]; then
        TIME_STRING+="1 MINUTE"
    else
        TIME_STRING+="${MINS} MINUTES"
    fi

    if [[ ${SECS} -eq 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND 1 SECOND"
    elif [[ ${SECS} -eq 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND 1 SECOND"
    elif [[ ${SECS} -ne 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND ${SECS} SECONDS"
    elif [[ ${SECS} -ne 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND ${SECS} SECONDS"
    fi

    echo ${TIME_STRING}
}

# PRINTS A HELP MENU
function help_menu() {
    echo -e "\n${BOLD}OVERVIEW:${RESTORE} Merges full GSI changes from phhusson into a ROM set of repos\n"
    echo -e "${BOLD}USAGE:${RESTORE} bash apply_patches.sh <source_dir> <branch_name>\n"
    echo -e "${BOLD}EXAMPLE:${RESTORE} bash apply_patches.sh ~/Android/Lineage android-10.0-r14\n"
    echo -e "${BOLD}Required options:${RESTORE}"
    echo -e "       source_dir: Location of the ROM tree; this needs to exist for the script to properly proceed\n"
    echo -e "       branch_name: what commits need be pulled. Oreo or pie? \n"
}

# CREATES A NEW LINE IN TERMINAL
function newLine() {
    echo -e ""
}

# PRINTS AN ERROR IN BOLD RED
function reportError() {
    RED="\033[01;31m"
    RESTORE="\033[0m"

    echo -e ""
    echo -e ${RED}"${1}"${RESTORE}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}

# PRINTS AN WARNING IN BOLD YELLOW
function reportWarning() {
    YELLOW="\033[01;33m"
    RESTORE="\033[0m"

    echo -e ""
    echo -e ${YELLOW}"${1}"${RESTORE}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}

###############
#             #
#  VARIABLES  #
#             #
###############

if [[ ! $# -ge 2 ]]; then
    reportError "Source directory/Branch not specified!" -c; help_menu && exit
fi

while [[ $# -ge 2 ]]; do
    case "$1" in
        "-h"|"--help")
            help_menu && exit ;;
        *)
            SOURCE_DIR=${1}
            if [[ ! -d ${SOURCE_DIR} ]]; then
                reportError "Source directory not found!" && exit
            elif [[ ! -d ${SOURCE_DIR}/.repo ]]; then
                reportError "This is not a valid Android source folder as there is no .repo folder!" && exit
            fi ;;
    esac

    # variants
    PIE=false
    Q=false
    
    case "$2" in
        android-8.1)
            BRANCH=android-8.1.0_r65-phh
SUBS_REPOS="
build
external/selinux
frameworks/av
frameworks/base
frameworks/native
frameworks/opt/telephony
system/bt
system/core
system/libvintf
system/netd
system/vold"
;;
        android-9.0)
            PIE=true
            BRANCH=android-9.0.0_r47-phh
SUBS_REPOS="
build
external/selinux
frameworks/av
frameworks/base
frameworks/native
frameworks/opt/net/wifi
frameworks/opt/telephony
packages/apps/Settings
packages/services/Telephony
system/bt
system/core
system/netd
system/sepolicy
system/vold"
;;
    android-10.0)
       Q=true
       BRANCH=android-10.0.0_r29-phh
SUBS_REPOS="
bionic
bootable/recovery
build
external/selinux
external/skia
frameworks/av
frameworks/base
frameworks/native
frameworks/opt/net/wifi
frameworks/opt/telephony
packages/apps/Settings
packages/services/Telephony
system/bpf
system/bt
system/core
system/netd
system/sepolicy
system/vold"
;;
    esac

    shift
done

unset RESULT_STRING

################
#              #
# SCRIPT START #
#              #
################

# START TRACKING TIME
START=$( date +%s )

for FOLDER in ${SUBS_REPOS}; do
    # PRINT TO THE USER WHAT WE ARE DOING
    newLine; echoText "Merging ${FOLDER}"
    
    # SHIFT TO PROPER FOLDER
    cd ${SOURCE_DIR}
   
    if [[ ${FOLDER} = "build" ]]; then
        # build is build/make
	cd ${FOLDER}/make
    else
        cd ${FOLDER}
    fi

    # SET PROPER URL
    URL=platform_$( echo ${FOLDER} | sed "s/\//_/g" )

    # FETCH THE REPO
    git fetch https://github.com/phhusson/${URL} ${BRANCH}

    # GIT GYMNASTICS (GETS MESSY, BEWARE)
    # FIRST HASH WILL ALWAYS BE THE FETCH HEAD
    FIRST_HASH=$( git log --format=%H -1 FETCH_HEAD)

    # SECOND HASH WILL BE THE LAST THING I COMMITTED
    NUMBER_OF_COMMITS=$(( $( git log --format=%H --committer="Pierre-Hugues" FETCH_HEAD | wc -l ) - 1 ))
    SECOND_HASH=$( git log --format=%H --committer="Pierre-Hugues" FETCH_HEAD~${NUMBER_OF_COMMITS}^..FETCH_HEAD~${NUMBER_OF_COMMITS} )

    # RESET ANY LOCAL CHANGES SO THAT CHERRY-PICK DOES NOT FAIL
    git reset --hard HEAD

    # PICK THE COMMITS IF EVERYTHING CHECKS OUT
      [ ${FOLDER} = "system/vold" ] && {
        $PIE && git cherry-pick --allow-empty-message --keep-redundant-commits -X 13a34a80c433dd2a5a2c195b3c568990ef9908fd^..${FIRST_HASH}^..${FIRST_HASH} || $Q && git cherry-pick --allow-empty-message --keep-redundant-commits -X thiers 979b8f32401ca344283337b23438c19199d9bfd7^..${FIRST_HASH}
      } || git cherry-pick --allow-empty-message --keep-redundant-commits -X thiers ${SECOND_HASH}^..${FIRST_HASH}
    
    # ADD TO RESULT STRING
    if [[ $? -ne 0 ]]; then
        RESULT_STRING+="${FOLDER}: ${RED}FAILED${RESTORE}\n"
    else
        RESULT_STRING+="${FOLDER}: ${GREEN}SUCCESS${RESTORE}\n"
    fi
done

# SHIFT BACK TO THE TOP OF THE REPO
cd ${SOURCE_DIR}

# PRINT RESULTS
echoText "RESULTS"
echo -e ${RESULT_STRING}

# STOP TRACKING TIME
END=$( date +%s )

# PRINT RESULT TO USER
echoText "SCRIPT COMPLETED!"
echo -e ${RED}"TIME: $(format_time ${END} ${START})"${RESTORE}; newLine
