################################################################################
#
# mscc-easyframes
#
################################################################################

MSCC_EASYFRAMES_VERSION = 86838615a524404f3d597cc3ff0425e03b0220f2
MSCC_EASYFRAMES_SITE = $(call github,microchip-ung,easyframes,$(MSCC_EASYFRAMES_VERSION))
MSCC_EASYFRAMES_INSTALL_STAGING = YES

MSCC_EASYFRAMES_LICENSE = MIT
MSCC_EASYFRAMES_LICENSE_FILES = COPYING
MSCC_EASYFRAMES_ACTUAL_SOURCE_SITE = no upstream
MSCC_EASYFRAMES_DEPENDENCIES = zlib libpcap

$(eval $(cmake-package))
