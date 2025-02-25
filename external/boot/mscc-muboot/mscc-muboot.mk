################################################################################
#
# mscc-muboot (Multiple U-Boot)
#
################################################################################

MSCC_MUBOOT_VERSION       = $(call qstrip,$(BR2_MSCC_MUBOOT_VERSION))
MSCC_MUBOOT_SITE          = $(call qstrip,$(BR2_MSCC_MUBOOT_REPO))
MSCC_MUBOOT_SOURCE        = ${MSCC_MUBOOT_VERSION}.tar.gz
MSCC_MUBOOT_LICENSE       = GPL-2.0+
MSCC_MUBOOT_LICENSE_FILES = Licenses/gpl-2.0.txt

MSCC_MUBOOT_INSTALL_TARGET = NO
MSCC_MUBOOT_INSTALL_IMAGES = YES

# The kernel calls AArch64 'arm64', but U-Boot calls it just 'arm', so
# we have to special case it. Similar for i386/x86_64 -> x86
ifeq ($(KERNEL_ARCH),arm64)
MSCC_MUBOOT_ARCH = arm
else ifneq ($(filter $(KERNEL_ARCH),i386 x86_64),)
MSCC_MUBOOT_ARCH = x86
else
MSCC_MUBOOT_ARCH = $(KERNEL_ARCH)
endif

MSCC_MUBOOT_MAKE_OPTS += \
        CROSS_COMPILE="$(TARGET_CROSS)" \
        ARCH=$(MSCC_MUBOOT_ARCH) \
        HOSTCC="$(HOSTCC) $(subst -I/,-isystem /,$(subst -I /,-isystem /,$(HOST_CFLAGS)))" \
        HOSTLDFLAGS="$(HOST_LDFLAGS)"

define MSCC_MUBOOT_BUILD_CMDS
	mkdir -p $(@D)/images
	for cfg in $(call qstrip,$(BR2_MSCC_MUBOOT_TARGETS))					;\
	do											\
		cfgname=$${cfg/mscc_/}								;\
		$(TARGET_CONFIGURE_OPTS)							\
		$(MAKE) -C $(@D) $(MSCC_MUBOOT_MAKE_OPTS) clean $${cfg}_defconfig		;\
		$(TARGET_CONFIGURE_OPTS)							\
		$(MAKE) -C $(@D) $(MSCC_MUBOOT_MAKE_OPTS)					;\
		mv $(@D)/u-boot.bin $(@D)/images/u-boot-$${cfgname}.bin				;\
	done
endef

define MSCC_MUBOOT_INSTALL_IMAGES_CMDS
	cp -dpf $(@D)/images/* $(BINARIES_DIR)/
	mkdir -p $(BINARIES_DIR)/keys
	cp $(MSCC_MUBOOT_PKGDIR)/keys/* $(BINARIES_DIR)/keys/
endef

$(eval $(generic-package))
