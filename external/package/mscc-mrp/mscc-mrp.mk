################################################################################
#
# mscc-MRP(Media Redundancy Protocol)
#
################################################################################

MSCC_MRP_VERSION = 339d6220c63a118e91fce5089b49091df76b8da2
MSCC_MRP_SITE = $(call github,microchip-ung,mrp,$(MSCC_MRP_VERSION))
MSCC_MRP_DEPENDENCIES = libnl libev libmnl mscc-cfm
MSCC_MRP_INSTALL_STAGING = YES

MSCC_MRP_LICENSE = GPLv2
MSCC_MRP_LICENSE_FILES = LICENSE

$(eval $(cmake-package))
