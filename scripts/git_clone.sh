#! /bin/bash

URL="$1"
SUBDIR="$2"
if [ $# -eq 4 ]; then
	MIRROR="$3"
	VERSION="$4"
elif [ $# -eq 5 ]; then
	MIRROR="$3"
	VERSION="$4"
	REWRITE="$5"
else
	echo "$0: Error, invalid number of arguments"
	exit 1
fi

IOPSYS_URL="dev.iopsys.eu"
IOPSYS_HTTP_URL="https://"${IOPSYS_URL}

#first try to use mirror
# is this an inteno server ? in that case do not use the mirror
if [ -n "${MIRROR}" ] && [[ $URL != *${IOPSYS_URL}* ]]; then

	repo=$(basename $URL)
	MIRROR_URL=${MIRROR}/${repo}

	echo "trying to clone from mirror ${MIRROR_URL}"
	if git clone ${MIRROR_URL} ${SUBDIR} --recursive; then
	    old="$PWD"
	    cd ${SUBDIR}
	    if git checkout ${VERSION}; then
			exit 0
	    fi
	    # checkout failed mirror is not correct
	    cd $old
	    rm -rf cd ${SUBDIR}
	fi
fi

if [ "$REWRITE" = y ] && [[ $URL == ${IOPSYS_HTTP_URL}* ]]; then
	# clone with ssh
	repo=$(echo $URL | sed "s ${IOPSYS_HTTP_URL}/  g")
	URL="git@"${IOPSYS_URL}:${repo}
fi

#if not try the original
echo "No working mirror cloning from ${URL}"
git clone ${URL} ${SUBDIR} --recursive
