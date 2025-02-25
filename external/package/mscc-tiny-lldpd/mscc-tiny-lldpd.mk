################################################################################
#
# mscc-tiny-lldpd
#
################################################################################

MSCC_TINY_LLDPD_VERSION = cac395b3b222f5b8eaae85cc8841e4fd1c2c0ffe
MSCC_TINY_LLDPD_SITE = https://bitbucket.microchip.com/UNGE/sw-tiny-lldpd/archive
MSCC_TINY_LLDPD_SOURCE = ${MSCC_TINY_LLDPD_VERSION}.tar.gz
MSCC_TINY_LLDPD_UTILS_INSTALL_STAGING = YES

MSCC_TINY_LLDPD_LICENSE = MIT
MSCC_TINY_LLDPD_LICENSE_FILES = COPYING
MSCC_TINY_LLDPD_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
