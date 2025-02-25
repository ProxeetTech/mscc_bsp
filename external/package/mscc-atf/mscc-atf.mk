################################################################################
#
# ATF(ARM Trusted Firmware)
#
################################################################################

MSCC_ATF_VERSION = $(call qstrip,$(BR2_PACKAGE_HOST_MSCC_ATF_VERSION))
MSCC_ATF_SITE = $(call github,microchip-ung,arm-trusted-firmware,$(MSCC_ATF_VERSION))
MSCC_ATF_LICENSE = BSD-3-Clause
MSCC_ATF_LICENSE_FILES = docs/license.rst

HOST_MSCC_ATF_DEPENDENCIES = $(BR2_MAKE_HOST_DEPENDENCIES)

define HOST_MSCC_ATF_BUILD_CMDS
	$(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D) fiptool certtool
endef

define HOST_MSCC_ATF_INSTALL_CMDS
	${HOST_DIR}/bin/patchelf --set-rpath $(HOST_DIR)/lib $(@D)/tools/fiptool/fiptool
	${HOST_DIR}/bin/patchelf --set-rpath $(HOST_DIR)/lib $(@D)/tools/cert_create/cert_create
	$(INSTALL) -m 0755 -D $(@D)/tools/fiptool/fiptool $(HOST_DIR)/bin/fiptool
	$(INSTALL) -m 0755 -D $(@D)/tools/cert_create/cert_create $(HOST_DIR)/bin/cert_create
endef

$(eval $(host-generic-package))
