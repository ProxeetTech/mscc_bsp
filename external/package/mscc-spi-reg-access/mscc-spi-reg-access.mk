################################################################################
#
# mscc-spi-reg-access
#
################################################################################

MSCC_SPI_REG_ACCESS_VERSION = f86c1ba8dd04f9c53475caa06889682a93799af1
MSCC_SPI_REG_ACCESS_SOURCE = ${MSCC_SPI_REG_ACCESS_VERSION}.tar.gz
MSCC_SPI_REG_ACCESS_SITE = https://bitbucket.microchip.com/UNGE/sw-tools-spi-reg-access/archive
MSCC_SPI_REG_ACCESS_INSTALL_STAGING = YES

MSCC_SPI_REG_ACCESS_LICENSE = MIT
MSCC_SPI_REG_ACCESS_LICENSE_FILES = COPYING
MSCC_SPI_REG_ACCESS_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
