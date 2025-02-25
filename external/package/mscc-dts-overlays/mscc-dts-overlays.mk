################################################################################
#
# mscc-dts-overlays
#
################################################################################

MSCC_DTS_OVERLAYS_VERSION = a00ec89ac8584f2ac1ddb195fae18c3ab57352ae
MSCC_DTS_OVERLAYS_SITE = https://bitbucket.microchip.com/UNGM/dts-overlays/archive
MSCC_DTS_OVERLAYS_SOURCE = ${MSCC_DTS_OVERLAYS_VERSION}.tar.gz
MSCC_DTS_OVERLAYS_INSTALL_IMAGES = YES

define MSCC_DTS_OVERLAYS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/overlays
	$(INSTALL) -m 755 $(@D)/build/*.dtbo $(TARGET_DIR)/overlays
endef

define MSCC_DTS_OVERLAYS_INSTALL_IMAGES_CMDS
	mkdir -p $(BINARIES_DIR)/overlays
	$(INSTALL) -m 755 $(@D)/build/*.dtbo $(BINARIES_DIR)/overlays
endef

MSCC_DTS_OVERLAYS_LICENSE = MIT
MSCC_DTS_OVERLAYS_LICENSE_FILES = COPYING
MSCC_DTS_OVERLAYS_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
