#!/bin/bash

# Export custom User and Host
KBUILD_BUILD_USER=idkwhoiam322
KBUILD_BUILD_HOST=raphielgang_ci
export KBUILD_BUILD_USER KBUILD_BUILD_HOST

# Get CI environment
if [ -d "/home/runner/" ]; then
	CI_ENVIRONMENT="SEMAPHORE_CI"
	PROJECT_DIR=/home/runner/${SEMAPHORE_PROJECT_NAME}
	CUR_BUILD_NUM="${SEMAPHORE_BUILD_NUMBER}"
fi
export CI_ENVIRONMENT PROJECT_DIR CUR_BUILD_NUM

cd ${PROJECT_DIR} || exit

# AnyKernel3
ANYKERNEL_DIR="${PROJECT_DIR}/anykernel3"
export ANYKERNEL_DIR

if [[ ${COMPILER} == *"GCC"* ]]; then
	CROSS_COMPILE="${PROJECT_DIR}/gcc/bin/aarch64-elf-"
	CROSS_COMPILE_ARM32="${PROJECT_DIR}/gcc32/bin/arm-eabi-"
else
	KBUILD_COMPILER_STRING="$(${PROJECT_DIR}/clang/clang-r370808/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')";
	CC="${PROJECT_DIR}/clang/clang-r370808/bin/clang"
	CLANG_TRIPLE="aarch64-linux-gnu-"
	CROSS_COMPILE="${PROJECT_DIR}/gcc/bin/aarch64-linux-android-"
	CROSS_COMPILE_ARM32="${PROJECT_DIR}/gcc32/bin/arm-linux-androideabi-"
	export KBUILD_COMPILER_STRING CC CLANG_TRIPLE
fi
export COMPILER CROSS_COMPILE CROSS_COMPILE_ARM32

# get current branch and kernel patch level
CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
KER_PATCH_LEVEL=$(grep "SUBLEVEL =" < Makefile | awk '{print $3}')$(grep "EXTRAVERSION =" < Makefile | awk '{print $3}')
export CUR_BRANCH

# Release type
if [[ ${KERNEL_BUILD_TYPE} == *"BETA"* ]]; then
	KERNEL_BUILD_TYPE="beta"
	VERA="Hentai-o-W-o"
	MIN_HEAD=$(git rev-parse HEAD)
	VERB="$(date +%Y%m%d)-$(echo ${MIN_HEAD:0:4})"
	VERSION="${VERA}-${VERB}-${BUILDFOR}-r${CUR_BUILD_NUM}"
	ZIPNAME="${BUILDFOR}-${KERNEL_BUILD_TYPE}-r${CUR_BUILD_NUM}-${CUR_BRANCH}-${KER_PATCH_LEVEL}.zip"
elif [[ ${KERNEL_BUILD_TYPE} == *"STABLE"* ]]; then
	KERNEL_BUILD_TYPE="Stable"
	VERA="Weeb-Kernel"
	VERSION="${VERA}-${BUILDFOR}-v${RELEASE_VERSION}-${RELEASE_CODENAME}"
	ZIPNAME="${VERSION}.zip"
fi
export LOCALVERSION=$(echo "-${VERSION}")
export ZIPNAME KERNEL_BUILD_TYPE

export OUT_IMAGE_DIR="${PROJECT_DIR}/out/arch/arm64/boot/Image.gz-dtb"

#export defconfig
DEFCONFIG="weeb_defconfig"
export DEFCONFIG