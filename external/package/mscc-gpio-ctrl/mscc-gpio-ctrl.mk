################################################################################
#
# gpio-ctrl
#
################################################################################

MSCC_GPIO_CTRL_VERSION = 860128c1fecada4905fb2a7df7562afab15668d3
MSCC_GPIO_CTRL_SITE = https://bitbucket.microchip.com/UNGE/sw-tool-linux-gpio_ctrl/archive
MSCC_GPIO_CTRL_SOURCE = ${MSCC_GPIO_CTRL_VERSION}.tar.gz
MSCC_GPIO_CTRL_INSTALL_STAGING = YES

MSCC_GPIO_CTRL_LICENSE = MIT
MSCC_GPIO_CTRL_LICENSE_FILES = COPYING
MSCC_GPIO_CTRL_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
