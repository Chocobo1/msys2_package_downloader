# msys2_package_downloader


### Prerequisite
Install [`MSYS2`](https://msys2.github.io/)


### Usage
```shell
$ ./msys2_dl.sh --help
Fetch MSYS2 pre-built package and dependencies
MSYS2 package list: https://github.com/Alexpux/MINGW-packages
Usage: ./msys2_dl.sh [--exe-only] PACKAGE

  --exe-only 	 only executables and its dependencies (dlls) are included in the final package
```


### Example
  ```shell
$ ./msys2_dl.sh --exe-only mingw-w64-x86_64-optipng
    # make sure you have enough free space!
    # this will generate a new file: mingw-w64-x86_64-optipng.tar.xz

$ tar -tf mingw-w64-x86_64-optipng.tar.xz  # let's examine the contents
bin/
bin/libatomic-1.dll  # dll dependencies (as specified in PKGBUILD)
bin/libbz2-1.dll
bin/libgcc_s_seh-1.dll
bin/libgfortran-3.dll
bin/libgmp-10.dll
bin/libgmpxx-4.dll
bin/libgomp-1.dll
bin/libminizip-1.dll
bin/libpng16-16.dll
bin/libquadmath-0.dll
bin/libssp-0.dll
bin/libstdc++-6.dll
bin/libwinpthread-1.dll
bin/optipng.exe  # the target executable
bin/zlib1.dll
```


### Package naming
* mingw package list: https://github.com/Alexpux/MINGW-packages

  For example you want the package `mingw-w64-optipng`:
    * x64 package name: `mingw-w64-x86_64-optipng`
    * x86 package name: `mingw-w64-i686-optipng`

* MSYS2 package list: https://github.com/Alexpux/MSYS2-packages

  *Normally, you'll want the above mingw package*
