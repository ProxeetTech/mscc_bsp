################################################################################
#
# mscc-easyrun
#
################################################################################

MSCC_EASYRUN_VERSION = df40aa82b072c37870baee28c83399f395fdcff9
MSCC_EASYRUN_SITE = $(call github,microchip-ung,easyrun,$(MSCC_EASYRUN_VERSION))
MSCC_EASYRUN_INSTALL_STAGING = YES

MSCC_EASYRUN_LICENSE = MIT
MSCC_EASYRUN_LICENSE_FILES = COPYING
MSCC_EASYRUN_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
