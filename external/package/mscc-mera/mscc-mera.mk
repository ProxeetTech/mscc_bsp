################################################################################
#
# mera
#
################################################################################

MSCC_MERA_VERSION = ac92e085126088355d49c69e6d27057e2bc351ef
MSCC_MERA_SITE = $(call github,microchip-ung,mera,$(MSCC_MERA_VERSION))
MSCC_MERA_INSTALL_STAGING = NO

MSCC_MERA_LICENSE = MIT
MSCC_MERA_LICENSE_FILES = LICENSE
MSCC_MERA_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
