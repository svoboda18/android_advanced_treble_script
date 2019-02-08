#!/bin/bash
set -e

repo="$(readlink -f -- $1)"
patches="$(readlink -f -- $0 |sed -e 's/apply-patches.sh//g')patches"

for project in $(cd $patches; echo *);do
	p="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
	[ "$p" == build ] && p=build/make
	cd $repo
	repo sync -l --force-sync $p
	pushd $p
	git clean -fdx; git reset --hard
	for patch in $patches/$project/*.patch ;do
		#Check if patch is already applied
		if patch -f -p1 --dry-run -R < $patch > /dev/null;then
			continue
		fi

		#if git apply --check $patch;then
		#	git am $patch
		if patch -f -p1 --dry-run < $patch > /dev/null;then
			#This will fail
		#	git am $patch || true
			patch -f -p1 < $patch
		#	git add -u
		#	git am --continue
		else
			echo "Failed applying $patch"
		fi
	done
	popd
done

