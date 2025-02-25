################################################################################
#
# p-net
#
################################################################################

MSCC_RTLABS_PNET_VERSION = ea5e5540b2be55c4dfadffda39b948632c104daa
MSCC_RTLABS_PNET_SITE_METHOD = git
MSCC_RTLABS_PNET_SITE = https://github.com/rtlabs-com/p-net.git
MSCC_RTLABS_PNET_GIT_SUBMODULES = YES
MSCC_RTLABS_PNET_INSTALL_STAGING = YES
MSCC_RTLABS_PNET_LICENSE = Dual-licensed under GPLv3 or a commercial license
MSCC_RTLABS_PNET_LICENSE_FILES = LICENSE.md
MSCC_RTLABS_PNET_SUPPORTS_IN_SOURCE_BUILD = NO
MSCC_RTLABS_PNET_DEPENDENCIES = mscc-mera mscc-osal
MSCC_RTLABS_PNET_CONF_OPTS += \
	-DBUILD_TESTING=OFF \
	-DPNET_OPTION_DRIVER_ENABLE=ON \
	-DPNET_OPTION_DRIVER_LAN9662=ON

# this is needed because we need to copy also some scripts that are used by pnet
define MSCC_RTLABS_PNET_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 $(@D)/buildroot-build/pn_dev $(TARGET_DIR)/usr/bin/pn_dev
	$(INSTALL) -m 755 $(@D)/buildroot-build/pn_lan9662 $(TARGET_DIR)/usr/bin/pn_lan9662
	$(INSTALL) -m 755 $(@D)/buildroot-build/pn_shm_tool $(TARGET_DIR)/usr/bin/pn_shm_tool
	$(INSTALL) -m 755 $(@D)/buildroot-build/libprofinet.so $(TARGET_DIR)/usr/lib/libprofinet.so
	$(INSTALL) -m 755 $(@D)/buildroot-build/set_profinet_leds $(TARGET_DIR)/usr/bin/set_profinet_leds
	$(INSTALL) -m 755 $(@D)/buildroot-build/set_network_parameters $(TARGET_DIR)/usr/bin/set_network_parameters
	$(INSTALL) -m 755 $(@D)/samples/pn_shm_tool/shm_echo_all.sh $(TARGET_DIR)/usr/bin/shm_echo_all.sh
	$(INSTALL) -m 755 $(@D)/samples/pn_shm_tool/shm_read_all.sh $(TARGET_DIR)/usr/bin/shm_read_all.sh
	$(INSTALL) -m 755 $(@D)/samples/pn_shm_tool/shm_write_all_inputs.sh $(TARGET_DIR)/usr/bin/shm_write_all_inputs.sh
	$(INSTALL) -m 755 $(@D)/samples/pn_dev_lan9662/switchdev-profinet-example.sh $(TARGET_DIR)/usr/bin/switchdev-profinet-example.sh
	$(INSTALL) -m 755 $(@D)/src/drivers/lan9662/add_outbound_vcap_rule.sh $(TARGET_DIR)/usr/bin/add_outbound_vcap_rule.sh
	$(INSTALL) -m 755 $(@D)/src/drivers/lan9662/add_inbound_vcap_rule.sh $(TARGET_DIR)/usr/bin/add_inbound_vcap_rule.sh
	$(INSTALL) -m 755 $(@D)/src/drivers/lan9662/del_vcap_rule.sh $(TARGET_DIR)/usr/bin/del_vcap_rule.sh
endef

$(eval $(cmake-package))
