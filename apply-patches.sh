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

# Get full dirs locations, else patches wont be found
repo="$(readlink -f -- $1)"

# Decide to use msm or mtk patches?
case "$2" in
	msm) patches="$(readlink -f -- $0 |sed -e 's/apply-patches.sh//g')patches_msm" ;;
	mtk) patches="$(readlink -f -- $0 |sed -e 's/apply-patches.sh//g')patches_mtk" ;;
esac

# Decide to use pie or oreo patches?
case "$3" in
	android-8.1) patches="$patches/oreo" ;;
	android-9.0) patches="$patches/pie" ;;
esac

# Now start patching
for project in $(cd $patches; echo *);do
	# Get every patch target folder dir, then navigate to it
	patch_target="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
	[ "$patch_target" == build ] && patch_target=build/make
	cd $repo
	repo sync -l --force-sync $patch_target
	pushd $patch_target
	git clean -fdx; git reset --hard

	# Apply patch one by one
	for patch in $patches/$project/*.patch ;do
		# First use patch, if failling fallback to am
		if patch -f -p1 --dry-run < $patch > /dev/null;then
			patch -f -p1 < $patch
		else
			echo Failed applying $(echo $patch |sed -e "s@$patches/@@")
		fi

	done
	popd
done

