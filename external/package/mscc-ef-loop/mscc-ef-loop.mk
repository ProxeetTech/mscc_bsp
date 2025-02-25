################################################################################
#
# ef-loop
#
################################################################################

MSCC_EF_LOOP_VERSION = 83c3541e2427ad50cba9c83867d5f3f9b9eb2eb5
MSCC_EF_LOOP_SITE = https://bitbucket.microchip.com/UNGM/ef-loop/archive
MSCC_EF_LOOP_SOURCE = ${MSCC_EF_LOOP_VERSION}.tar.gz
MSCC_EF_LOOP_INSTALL_STAGING = YES

MSCC_EF_LOOP_LICENSE = MIT
MSCC_EF_LOOP_LICENSE_FILES = COPYING
MSCC_EF_LOOP_ACTUAL_SOURCE_SITE = no upstream
MSCC_EF_LOOP_DEPENDENCIES = libev

$(eval $(cmake-package))
