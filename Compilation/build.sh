#!/bin/bash

# original script taken from iTransmission project
# (https://github.com/ccp0101/iTransmission/blob/master/make_depend/build.sh)

#########################
#Space-seperated list of archs e.g export ARCHS=("armv7 armv7s arm64 i386 x86_64")
export ARCH=x86_64
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export DEVFOLDER="/Applications/Xcode.app/Contents/Developer"
# an SDK prior to 6.0 is required if the target ARCH is armv6
SDK_VERSION=“10.3”
PARALLEL_NUM=4

CURL_VERSION=7.54.0
ZLIB_VERSION=1.2.11
LIBEVENT_VERSION="2.1.8-stable"
OPENSSL_VERSION=1.0.2k
TRANSMISSION_VERSION=2.92
#########################

if [ -z ${ARCH} ]; then ARCH="system"; fi

export TEMP_DIR="$PWD/temp"
export PATCH_DIR="$PWD/patches"
export DEPENDENCY_DIR="$PWD/dependency"
export BUILD_FILTER="ssl,curl,trans,libev"
export TOOL_DIR="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
export Min_IPHONE_OS=9.0

function do_abort {
	echo $1 >&2
	exit 1
}

function do_loadenv {
	export BUILD_DIR="$PWD/out/${ARCH}"
	export TRANS_LINKER_FLAGS="-framework CoreFoundation "

	if [ ${ARCH} = "i386" ]
		then
		PLATFORM="iPhoneSimulator"
	elif [ ${ARCH} = "x86_64" ]
		then
		PLATFORM="iPhoneSimulator"
	elif [ ${ARCH} = "armv7" ]
		then
		PLATFORM="iPhoneOS"
	elif [ ${ARCH} = "armv7s" ]
		then
		PLATFORM="iPhoneOS"
	elif [ ${ARCH} = "arm64" ]
		then
		PLATFORM="iPhoneOS"
	elif [ ${ARCH} = "armv6" ]
		then
		PLATFORM="iPhoneOS"
	elif [ ${ARCH} = "system" ]
		then
		PLATFORM="none"
	else
		do_abort "invalid arch ${ARCH} specified"
	fi
}

function do_export {
	unset CFLAGS
	if [[ ${ARCH} != "system" ]]; then
		export DEVROOT="${DEVELOPER_DIR}/Platforms/${PLATFORM}.platform/Developer"
		export SDKROOT="${DEVELOPER_DIR}/Platforms/${PLATFORM}.platform/Developer/SDKs/$PLATFORM.sdk"
		export LD=${DEVROOT}/usr/bin/ld
		#export CPP="${TOOL_DIR}/cpp"
        export CXX="${TOOL_DIR}/clang++"
        #export CXX="${GCC_DIR}/c++-4.8" 
		unset AR
		unset AS
		export NM=${DEVROOT}/usr/bin/nm
		#export CXXCPP="${TOOL_DIR}/cpp"
		export RANLIB="${TOOL_DIR}/ranlib"
		#export RANLIB="${GCC_DIR}/gcc-ranlib-4.8"
        export CFLAGS="-arch ${ARCH} -isysroot ${SDKROOT} -miphoneos-version-min=${Min_IPHONE_OS}"
		export CPPFLAGS="-arch ${ARCH} -isysroot ${SDKROOT} -miphoneos-version-min=${Min_IPHONE_OS}"
		export LDFLAGS="-L${SDKROOT}/usr/lib -isysroot ${SDKROOT} -Wl,-syslibroot $SDKROOT"
		export HAVE_CXX="yes"
	fi
	export CC="${TOOL_DIR}/clang"
    export CXX="${TOOL_DIR}/clang++"
	#export CC="${GCC_DIR}/gcc-4.8"
    export CFLAGS="${CPPFLAGS} -I${BUILD_DIR}/include -I${SDKROOT}/usr/include -pipe -no-cpp-precomp"
	export CPPFLAGS="${CPPFLAGS} -I${BUILD_DIR}/include -I${SDKROOT}/usr/include -pipe -no-cpp-precomp"
	export CXXFLAGS="${CPPFLAGS}"
	export LDFLAGS="-L${SDKROOT}/usr/lib -L${BUILD_DIR}/lib -pipe -no-cpp-precomp ${LDFLAGS}"
	export COMMON_OPTIONS="--disable-shared --enable-static --disable-ipv6 --disable-manual "
	export HAVE_CXX="yes"
	
	if [ ${PLATFORM} = "iPhoneOS" ]
		then
		COMMON_OPTIONS="--host arm-apple-darwin ${COMMON_OPTIONS}"
	elif [ ${PLATFORM} = "iPhoneSimulator" ]
		then
			if [[ $ARCH == "x86_64" ]]; then
				COMMON_OPTIONS="--host x86_64-apple-darwin ${COMMON_OPTIONS}"
			elif [[ $ARCH == "i386" ]]; then
				COMMON_OPTIONS="--host i386-apple-darwin ${COMMON_OPTIONS}"
			fi
	fi	

	export PKG_CONFIG_PATH="${SDKROOT}/usr/lib/pkgconfig:${BUILD_DIR}/lib/pkgconfig"
}

function do_openssl {
	export PACKAGE_NAME="openssl-${OPENSSL_VERSION}"
	pushd ${TEMP_DIR}
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
	  /usr/bin/curl -O -L "http://www.openssl.org/source/${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: fetch failed "
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar zxvf "${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: unpack failed "
	
	pushd ${PACKAGE_NAME}
	
do_export
	if [[ "${ARCH}" == "x86_64" ]]; then
./Configure darwin64-x86_64-cc --prefix=${BUILD_DIR} --openssldir=${BUILD_DIR} || do_abort "$FUNCNAME: configure failed "
	else
		./Configure iphoneos-cross enable-base64 --openssldir=${BUILD_DIR} || do_abort "$FUNCNAME: configure failed "
	fi
	
	# Patch for iOS, taken from https://github.com/st3fan/ios-openssl/blame/master/build.sh
	perl -i -pe "s|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|" ./crypto/ui/ui_openssl.c
	perl -i -pe "s|^CC= gcc|CC= ${CC}|g" Makefile
	perl -i -pe "s|^CFLAG= (.*)|CFLAG= ${CFLAGS} $1|g" Makefile
	
	if [ ${PLATFORM} = "iPhoneSimulator" ]
		then
		pushd crypto/bn
		rm -f bn_prime.h
		perl bn_prime.pl >bn_prime.h
		popd
	fi

    make clean
	make -j ${PARALLEL_NUM} || do_abort "$FUNCNAME: make failed "
	make install || do_abort "$FUNCNAME: install failed "
	
	rm -rf ${BUILD_DIR}/share/man
	
	popd
	popd
}

function do_zlib {
    export PACKAGE_NAME="zlib-${ZLIB_VERSION}"
    pushd ${TEMP_DIR}
    if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
    then
        /usr/bin/curl -O -L "http://zlib.net/${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: fetch failed "
    fi

    if [[ -z $DONT_OVERWRITE ]]; then
        rm -rf "${PACKAGE_NAME}"
        tar zxvf "${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: unpack failed "
    fi

    pushd ${PACKAGE_NAME}

    do_export

    ./configure --prefix="${BUILD_DIR}" --static

    make -j ${PARALLEL_NUM} || do_abort "$FUNCNAME: make failed "
    make install || do_abort "$FUNCNAME: install failed "

    popd
    popd
}

function do_curl {
	export PACKAGE_NAME="curl-${CURL_VERSION}"
	pushd ${TEMP_DIR}
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
        /usr/bin/curl -O -L "https://curl.haxx.se/download/${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: fetch failed "
	fi
	
	if [[ -z $DONT_OVERWRITE ]]; then
		rm -rf "${PACKAGE_NAME}"
		tar zxvf "${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: unpack failed "
	fi
	
	pushd ${PACKAGE_NAME}
	
	do_export

	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS} --with-random=/dev/urandom --with-ssl --with-zlib --disable-ldap --without-libidn LDFLAGS="${LDFLAGS}" || do_abort "$FUNCNAME: configure failed "
	
	make -j ${PARALLEL_NUM} || do_abort "$FUNCNAME: make failed "
	make install || do_abort "$FUNCNAME: install failed "
	
	popd
	popd
}

function do_libevent {

	export PACKAGE_NAME="libevent-${LIBEVENT_VERSION}"
	pushd ${TEMP_DIR}
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
	  /usr/bin/curl -O -L "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: fetch failed "
	fi
	
    if [[ -z $DONT_OVERWRITE ]]; then
        rm -rf "${PACKAGE_NAME}"
        tar zxvf "${PACKAGE_NAME}.tar.gz" || do_abort "$FUNCNAME: unpack failed "
    fi

	pushd ${PACKAGE_NAME}
	
	# libevent patch to hardcode google public dns servers for iOS
	# as there is no /etc/resolv.conf in iOS
	# (TODO... it properly.. XD)
#patch -N < ${PATCH_DIR}/libevent-nameservers.patch
	
	do_export

	if [[ ! -z $DONT_OVERWRITE ]]; then
		make clean
	fi
	
	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS} || do_abort "$FUNCNAME: configure failed "
	
	make -j ${PARALLEL_NUM} || do_abort "$FUNCNAME: make failed "
	make install || do_abort "$FUNCNAME: install failed "
	
	popd
	popd
}

function do_transmission {	
	export PACKAGE_NAME="transmission-${TRANSMISSION_VERSION}"
	pushd ${TEMP_DIR}
	if [ ! -e "${PACKAGE_NAME}.tar.xz" ]
	then
	  /usr/bin/curl -O -L "https://github.com/transmission/transmission-releases/raw/master/${PACKAGE_NAME}.tar.xz" || do_abort "$FUNCNAME: fetch failed "
	fi
	
	if [[ -z $DONT_OVERWRITE ]]; then
		rm -rf "${PACKAGE_NAME}"
		tar xvfJ "${PACKAGE_NAME}.tar.xz" || do_abort "$FUNCNAME: unpack failed "
	fi
	
	pushd ${PACKAGE_NAME}
	
	#apply whitelist patch (to allow LAN clients by default)
	pushd libtransmission
	patch -N < ${PATCH_DIR}/rpc_lan_whitelist.patch
	popd
	
	do_export

	if [[ ! -z $DONT_OVERWRITE ]]; then
		make clean
	fi

	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS} --enable-utp --enable-largefile --disable-nls --enable-lightweight --enable-cli --enable-daemon --disable-mac --with-kqueue --with-gtk=no || do_abort "$FUNCNAME: configure failed "
	
	mkdir -p ${BUILD_DIR}/include/net
	cp "${DEPENDENCY_DIR}/route.h" "${BUILD_DIR}/include/net/route.h"

	make -j ${PARALLEL_NUM} || do_abort "$FUNCNAME: make failed "
	make install || do_abort "$FUNCNAME: install failed "
	
	# Default installation doesn't copy library and header files
	mkdir -p ${BUILD_DIR}/include/libtransmission
	mkdir -p ${BUILD_DIR}/lib
	find ./libtransmission -name "*.h" -exec cp "{}" ${BUILD_DIR}/include/libtransmission \;
	find . -name "*.a" -exec cp "{}" ${BUILD_DIR}/lib \;
	
	popd
	popd
}

function do_libb64
{
    pushd ${TEMP_DIR}

    if [ ! -e "libb64-git" ]
    then
        git clone git://git.code.sf.net/p/libb64/git libb64-git
    fi

    pushd libb64-git

    do_export

    make clean
    make

    pushd src
    cp libb64.a ../../../out/${ARCH}/lib
    popd
    pushd include
    cp -R b64 ../../../out/${ARCH}/include
    popd

    popd
    popd
}

do_loadenv

while getopts ":o:a:ne" opt; do
  	case $opt in
		a)
		  export ARCH="$OPTARG"
		  do_loadenv
		  ;;
	    o)
	      export BUILD_FILTER="$OPTARG"
	      ;;
		n)
		  export DONT_OVERWRITE="YES"
		  ;;
		e)
		  export BUILD_FILTER=""
		  do_export
		  ;;
	    ?)
	      do_abort "Invalid option: -$OPTARG"
	      ;;
	    :)
	      do_abort "Option -$OPTARG requires an argument."
	      ;;
	esac
done

mkdir -p ${TEMP_DIR}
do_openssl
do_zlib
do_curl
do_libevent
do_transmission
#do_libb64
