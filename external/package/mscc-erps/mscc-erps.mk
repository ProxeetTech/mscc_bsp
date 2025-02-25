################################################################################
#
# ERPS (Ethernet Ring Protection - G.8032)
#
################################################################################

MSCC_ERPS_VERSION = 3532af53c2d2ea28b71caac86f3fdd3bbc3f37fa
MSCC_ERPS_SITE = $(call github,microchip-ung,erps,$(MSCC_ERPS_VERSION))
MSCC_ERPS_DEPENDENCIES = libnl libev libmnl
MSCC_ERPS_INSTALL_STAGING = YES

MSCC_ERPS_LICENSE = GPLv2
MSCC_ERPS_LICENSE_FILES = LICENSE

$(eval $(cmake-package))
