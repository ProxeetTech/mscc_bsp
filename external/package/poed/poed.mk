POED_VERSION = main
POED_SITE_METHOD = git
POED_SITE = git@github.com:ProxeetTech/poed.git
POED_INSTALL_STAGING = YES
POED_INSTALL_TARGET = YES
POED_GIT_SUBMODULES = YES

#define POED_INSTALL_TARGET_CMDS
#	$(INSTALL) -m 0755 -D $(POED_BUILD_DIR)/poed $(TARGET_DIR)/usr/bin/poed
#	$(INSTALL) -m 0755 -D external/package/poed/uci_cfg_poed $(TARGET_DIR)/etc/config/poed
#endef

define POED_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D external/package/poed/S58poed $(TARGET_DIR)/etc/init.d/S58poed
endef

#define POED_INSTALL_TARGET_POST
#	$(INSTALL) -m 0755 -D external/package/poed/uci_cfg_poed $(TARGET_DIR)/etc/config/poed
#endef

$(eval $(cmake-package))
