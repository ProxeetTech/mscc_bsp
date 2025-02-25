################################################################################
#
# mscc-pmac
#
################################################################################

MSCC_PMAC_VERSION = a29df0746fc2c108d5da99dba3aa4773a206b901
MSCC_PMAC_SITE = https://bitbucket.microchip.com/UNGE/sw-pmac/archive
MSCC_PMAC_SOURCE = ${MSCC_PMAC_VERSION}.tar.gz
MSCC_PMAC_INSTALL_STAGING = YES

MSCC_PMAC_LICENSE = MIT
MSCC_PMAC_LICENSE_FILES = LICENSE
MSCC_PMAC_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
