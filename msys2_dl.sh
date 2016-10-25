#!/bin/sh


# vars
COLOR_RED="$(tput setaf 1)"
COLOR_GREEN="$(tput setaf 2)"
COLOR_NORMAL="$(tput sgr0)"


# helpers
print_help()
{
	printf "Fetch MSYS2 pre-built package and dependencies\n"
	printf "MSYS2 package list: https://github.com/Alexpux/MINGW-packages \n"
	printf "Usage: %s [--exe-only] PACKAGE\n\n" "$0"
	printf "  --exe-only \t only executables and its dependencies (dlls) are included in the final package\n"
	printf "\n"
}

substr()
{
	string="$1"
	substring="$2"
	if test "${string#*$substring}" != "$string"; then
		return 0	# $substring is in $string
	fi
	return 1	# $substring is not in $string
}


# parse args
# check if getopt is available
getopt --test > /dev/null
if [ $? != 4 ]; then
	printf "%s \`getopt --test\` failed in this environment. %s\n" "$COLOR_RED" "$COLOR_NORMAL"
	exit 1
fi

SHORT_OPTS="h"
LONG_OPTS="exe-only, help"
# -temporarily store output to be able to check for errors
PARSED="$(getopt --options "$SHORT_OPTS" --longoptions "$LONG_OPTS" --name "$0" -- "$@")"
if [ "$?" != "0" ]; then
	# getopt has complained about wrong arguments to stdout
	exit 2
fi

# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"
# now enjoy the options in order and nicely split until we see --
while true; do
	case "$1" in
		-h|--help)
			print_help
			exit 0
			;;
		--exe-only)
			if [ -z "$only_mode" ]; then only_mode="exe"; fi
			shift
			;;
		--)
			shift
			break
			;;
		*)
			printf "%s Programming error %s\n" "$COLOR_RED" "$COLOR_NORMAL"
			exit 3
			;;
	esac
done

# handle non-option arguments
if [ $# != 1 ]; then
	print_help
	exit 4
fi


# vars
tmp_path="$(mktemp -d --tmpdir="$(pwd)")"
db_path="$tmp_path/db"
root_path="$tmp_path/root"


# check package type
package_name="$1"
package_type="msys"
if substr "$package_name" "mingw-w64-cross"; then
	package_type="msys"
elif substr "$package_name" "mingw-w64"; then
	package_type="mingw"
fi


# download & extract
printf "%s Syncing... %s\n" "$COLOR_GREEN" "$COLOR_NORMAL"
mkdir "$db_path" "$root_path"
pacman -Suy --noprogressbar -b "$db_path"
pacman -S --noconfirm --noprogressbar -b "$db_path" -r "$root_path" "$package_name"
if [ "$?" != "0" ]; then
	rm -rf "$tmp_path"
	exit 5
fi

if [ "$package_type" = "msys" ]; then
	package_root_path="$root_path"
else
	package_root_path="$root_path/$(ls "$root_path")"
fi

if [ "$only_mode" = "exe" ]; then  # leave only exe files
	if [ "$package_type" = "msys" ]; then
		package_root_path="$root_path/usr"
	fi

	find "$package_root_path/bin" -type f ! -name '*.dll' -delete
	pacman -S --noconfirm --noprogressbar -b "$db_path" -r "$root_path" "$package_name"
fi


# repack
printf "%s Repacking... %s\n" "$COLOR_GREEN" "$COLOR_NORMAL"
files_list="$(ls "$package_root_path")"
if [ "$only_mode" = "exe" ]; then
	files_list="bin"
fi
XZ_OPT=-9e tar -acf "$package_name.tar.xz" -C "$package_root_path" $files_list


# cleanup
printf "%s Cleanup... %s\n" "$COLOR_GREEN" "$COLOR_NORMAL"
rm -rf "$tmp_path"

printf "%s All Done! %s\n" "$COLOR_GREEN" "$COLOR_NORMAL"
