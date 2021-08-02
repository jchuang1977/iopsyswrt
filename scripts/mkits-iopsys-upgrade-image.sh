#!/bin/sh
#
# Generate FIT source for IOPSYSWRT upgrade image

usage() {
	echo "Usage: `basename $0` output img0_name img0_file [[img1_name img1_file] ...]"
	exit 1
}

# We need at least 3 arguments
[ "$#" -lt 3 ] && usage

# Target output file
OUTPUT="$1"; shift

# Create a default, fully populated DTS file
echo "\
/dts-v1/;

/ {
	description = \"IOPSYSWRT FIT upgrade image\";
	#address-cells = <1>;

	id = \"IOPSYS\";
	created = \"${CREATION_DATE}\";
	model = \"${MODEL}\";
	iopsys_version = \"${IOPSYS_VERSION}\";

	images {" > ${OUTPUT}

while [ -n "$1" -a -n "$2" ]; do
	[ -f "$2" ] || usage

	name="$1"; shift
	file="$1"; shift

	echo \
"		${name} {
			description = \"${name}\";
			data = /incbin/(\"${file}\");
			type = \"Firmware\";
			arch = \"ARM\";
			compression = \"none\";
			hash@1 {
				algo = \"sha256\";
			};
		};" >> ${OUTPUT}
done

echo \
"	};
};" >> ${OUTPUT}
