################################################################################
#
# CFM(Continuity Failt Management)
#
################################################################################

MSCC_CFM_VERSION = 2b431096fc280fab8cc5c4d636b09be217eb9965
MSCC_CFM_SITE = $(call github,microchip-ung,cfm,$(MSCC_CFM_VERSION))
MSCC_CFM_DEPENDENCIES = libnl libev libmnl
MSCC_CFM_INSTALL_STAGING = YES

MSCC_CFM_LICENSE = GPLv2
MSCC_CFM_LICENSE_FILES = LICENSE

$(eval $(cmake-package))
