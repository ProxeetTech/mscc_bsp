################################################################################
#
# multicast tools
#
################################################################################

MSCC_MULTICAST_TOOLS_VERSION = 2.3
MSCC_MULTICAST_TOOLS_SITE = http://github.com/troglobit/mtools/archive/v${MSCC_MULTICAST_TOOLS_VERSION}
MSCC_MULTICAST_TOOLS_SOURCE = multicast-tools-${MSCC_MULTICAST_TOOLS_VERSION}.tar.gz
MSCC_MULTICAST_TOOLS_INSTALL_STAGING = YES

MSCC_MULTICAST_TOOLS_LICENSE = CC0-1.0
MSCC_MULTICAST_TOOLS_LICENSE_FILES = LICENSE.md
MSCC_MULTICAST_TOOLS_ACTUAL_SOURCE_SITE = no upstream

define MSCC_MULTICAST_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" -C $(@D)
endef

define MSCC_MULTICAST_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/mreceive $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0755 -D $(@D)/msend $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
