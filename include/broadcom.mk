PKG_BUILD_DEPENDS += DEFAULT_bcmkernel:bcmkernel

ifeq ($(CONFIG_DEFAULT_bcmkernel),y)
	LINUX_DIR := $(BUILD_DIR)/bcmkernel/bcm963xx/kernel/linux-4.19
	LINUX_VERSION := $(shell cat $(LINUX_DIR)/include/config/kernel.release)
	PKG_CONFIG_DEPENDS+= bcmkernel-$(LINUX_VERSION)
	export CROSS_COMPILE=/opt/toolchains/crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/bin/arm-buildroot-linux-gnueabi-
	export ARCH=arm
	KBUILD_CPPFLAGS:="-D__KERNEL__ -mlittle-endian -I$(LINUX_DIR)/arch/arm/mach-bcm963xx/include/  -I$(LINUX_DIR)/../bcmkernel/bcm963xx/kernel/bcmkernel/include/ -I$(LINUX_DIR)/arch/arm/mach-bcm963xx/include/ -I$(LINUX_DIR)/../bcmkernel/include/"
	KERNEL_MAKEOPTS := -C $(LINUX_DIR) KBUILD_CPPFLAGS=$(KBUILD_CPPFLAGS) CROSS_COMPILE=/opt/toolchains/crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/bin/arm-buildroot-linux-gnueabi- ARCH=arm
	TARGET_CROSS:=/opt/toolchains/crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/bin/arm-buildroot-linux-gnueabi-
	EXTRA_CFLAGS+=-I$(LINUX_DIR)/arch/arm/mach-bcm963xx/include/ -I$(LINUX_DIR)/../kernel/bcmkernel/include/
	MODULES_SUBDIR:=lib/modules/$(LINUX_VERSION)
	TARGET_MODULES_DIR:=$(LINUX_TARGET_DIR)/$(MODULES_SUBDIR)
	KERNEL_MAKE := $(MAKE) $(KERNEL_MAKEOPTS)
	DEPENDS+=bcmkernel
	export CURRENT_ARCH=arm
endif


