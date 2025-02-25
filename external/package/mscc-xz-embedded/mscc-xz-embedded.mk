################################################################################
#
# mscc-xz-embedded
#
################################################################################

MSCC_XZ_EMBEDDED_VERSION = 20130513
MSCC_XZ_EMBEDDED_SOURCE = xz-embedded-$(MSCC_XZ_EMBEDDED_VERSION).tar.gz
MSCC_XZ_EMBEDDED_SITE = http://tukaani.org/xz
MSCC_XZ_EMBEDDED_INSTALL_STAGING = YES
MSCC_XZ_EMBEDDED_LICENSE = Public Domain
MSCC_XZ_EMBEDDED_LICENSE_FILES = COPYING

$(eval $(cmake-package))
