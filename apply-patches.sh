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
patches="$repo/patches/patches"

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
		# First use patch tool, it is the best!
		patch -f -p1 < $patch || echo "WARNING:`echo $patch |sed -e "s@$patches/@@"` may conflict, conflicts have to be manually fixed! (at $patch_target)" && true
	done
	popd
done

