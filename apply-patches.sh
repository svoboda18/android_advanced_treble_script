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
    echo -e "\n${BLD}OVERVIEW:${RST} Merges full GSI changes from phhusson into a ROM set of repos\n"
    echo -e "${BLD}USAGE:${RST} bash apply_patches.sh <source_dir> <branch_name>\n"
    echo -e "${BLD}EXAMPLE:${RST} bash apply_patches.sh ~/Android/Lineage android-10.0\n"
    echo -e "${BLD}Required options:${RST}"
    echo -e "       source_dir: Location of the ROM tree; this needs to exist for the script to properly proceed\n"
    echo -e "       branch_name: Android version, a string that starts with \"android-\" and followed by version:"
    echo -e "       8.1, 9.0, 10.0, 11.0, 12.1\n"
}

# CREATES A NEW LINE IN TERMINAL
function newLine() {
    echo -e ""
}

###############
#             #
#  VARIABLES  #
#             #
###############
BASE_REPOS="external/selinux frameworks/base frameworks/native frameworks/av frameworks/opt/telephony system/bt system/core system/netd system/vold"
COMMON_REPOS="bionic packages/apps/Settings"
EXTRA_REPOS="bootable/recovery"
NEW_REPOS="packages/apps/Bluetooth system/extras system/linkerconfig system/nfc"

if [[ ! $# -ge 2 ]]; then
    reportError "Source directory/Branch not specified!"
fi

while [[ $# -ge 2 ]]; do
    case "$1" in
        "-h"|"--help")
            help_menu && exit ;;
        *)
            SOURCE_DIR=${1}
            BRANCH_VERSION=${2}
            if [[ ! -d ${SOURCE_DIR} ]]; then
                reportError "Source directory not found!"
            elif [[ ! -d ${SOURCE_DIR}/.repo ]]; then
                reportError "This is not a valid Android source folder as there is no .repo folder!"
            fi ;;
    esac

    case "${BRANCH_VERSION}" in
        android-8.1) REPOS="build system/libvintf system/sepolicy ${BASE_REPOS}";;
        android-9.0) REPOS="build frameworks/opt/net/wifi packages/services/Telephony system/sepolicy system/libvintf ${BASE_REPOS} ${COMMON_REPOS}";;
        android-10.0) REPOS="build packages/services/Telephony external/skia frameworks/opt/net/wifi system/bpf system/sepolicy ${BASE_REPOS} ${COMMON_REPOS} ${EXTRA_REPOS}";;
        android-11.0) REPOS="external/skia frameworks/opt/net/wifi packages/services/Telephony system/memory/lmkd ${BASE_REPOS} ${COMMON_REPOS} ${EXTRA_REPOS} ${NEW_REPOS}";;
        android-12.1) REPOS="frameworks/opt/net/ims hardware/interfaces packages/modules/Wifi system/bpf system/security ${BASE_REPOS} ${COMMON_REPOS} ${EXTRA_REPOS} ${NEW_REPOS}";;
        *) reportError "Unknown android tag ($2)";;
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
# SET BRANCH NAME (might break in future android sources :0)
BRANCH=$( git ls-remote https://github.com/phhusson/platform_frameworks_base | awk -F'/' "(match(\$3, /^${BRANCH_VERSION}.0_r([0-9]+)(-r[0-9]+)?-phh$/, r) && r[1]>m) { m=r[1]; l=\$3 } END { print l }" )
# ABORT IF NO BRANCHE WAS MATCHED
[ -z "$BRANCH" ] && reportError "Failed to fetch upstream branch!"

echo -e "Targeting: \n\t  ${YLW}$(echo ${REPOS} | sed -e 's/\(\w\+\)\s/\1\n\t  /g') ${RST}\nfrom branch: \n\t  ${GRN}${BRANCH}${RST}"
for FOLDER in ${REPOS}; do
    # GIT LOG QUERY OPTIONS
    GIT_OPTIONS="--format=%H --committer=\"Pierre-Hugues\" --invert-grep -E --grep=\"^(Merge tag|Update SPL)\" FETCH_HEAD"
    # PRINT TO THE USER WHAT WE ARE DOING
    newLine; printText "Merging ${FOLDER}"
    
    # SHIFT TO PROPER FOLDER
    cd ${SOURCE_DIR}

    if [[ ${FOLDER} = "build" ]]; then
        # build is build/make
	echo cd ${FOLDER}/make
    else
        echo cd ${FOLDER}
    fi

    # SET PROPER URL
    URL=platform_$( echo ${FOLDER} | sed "s/\//_/g" )

    # FETCH THE REPO
    newLine; echo "Fetching phh HEAD..."
    git fetch https://github.com/phhusson/${URL} ${BRANCH} >/dev/null 2>&1 || reportError "! Failed to fetch ${URL} branch ${BRANCH}"

    # GIT GYMNASTICS (GETS MESSY, BEWARE)
    # HEAD HASH WILL ALWAYS BE THE FETCH HEAD (LATEST COMMIT)
    HEAD_HASH=$( eval git log -1 ${GIT_OPTIONS} )

    # TAIL HASH WILL BE THE **FIRST** THING PHH COMMITTED
    # NO NEED TO MINUS 1
    NUMBER_OF_COMMITS=$( eval git log ${GIT_OPTIONS} | wc -l )
    
    if [[ "${NUMBER_OF_COMMITS}" -eq 0 ]]; then
         newLine; reportWarning "SKKIPED ${FOLDER}"
         RESULT_STRING+="${FOLDER}: ${YLW}SKIPPED${RST}\n"
         continue
    fi
  
    # NOW, SET TAIL_HASH WITH POSITIVE ${NUMBER_OF_COMMITS}
    TAIL_HASH=$( eval git log ${GIT_OPTIONS}~${NUMBER_OF_COMMITS}^..FETCH_HEAD~${NUMBER_OF_COMMITS} )
    
    # TAIL HASH CRYING?
    [ -z "${TAIL_HASH}" ] && TAIL_HASH=$( eval git log ${GIT_OPTIONS} | tail -1 )
    
    # RESET ANY LOCAL CHANGES
    git reset --hard HEAD

    LAST_COMMIT_MSG=$(git show -s --format=%s $HEAD_HASH)
    FIRST_COMMIT_MSG=$(git show -s --format=%s $TAIL_HASH)
    echo -e "${GRN}Applying ${NUMBER_OF_COMMITS} patch(es)${RST}:\n from: ${FIRST_COMMIT_MSG}\n to:   ${LAST_COMMIT_MSG}"

    # PICK THE COMMITS
    CHERRY_PICK="${TAIL_HASH}^..${HEAD_HASH}"
    [  "${TAIL_HASH}" == "${HEAD_HASH}" ] && CHERRY_PICK="${TAIL_HASH}"
    eval git cherry-pick --allow-empty-message --keep-redundant-commits -X thiers ${CHERRY_PICK}

    # ADD TO RESULT STRING
    if [[ $? -ne 0 ]]; then
        RESULT_STRING+="${FOLDER}: ${RED}FAILED${RST}\n"
        CLR="${RED}" 
    else
        RESULT_STRING+="${FOLDER}: ${GRN}SUCCESS${RST}\n"
        CLR="${GRN}"
    fi
    
    newLine; printText "DONE ${FOLDER}" ${CLR}
done

# SHIFT BACK TO THE TOP OF THE REPO
cd ${SOURCE_DIR}

# PRINT RESULTS
printText "RESULTS"
echo -e ${RESULT_STRING}

# STOP TRACKING TIME
END=$( date +%s )

# PRINT RESULT TO USER
printText "SCRIPT COMPLETED!"
echo -e ${RED}"TIME: $(format_time ${END} ${START})"${RST}; newLine
