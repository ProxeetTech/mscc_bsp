################################################################################
#
# testptp
#
################################################################################

MSCC_TESTPTP_VERSION = 4dacc76d401c47847bb57dddde512fcf6064f893
MSCC_TESTPTP_SITE = https://bitbucket.microchip.com/UNGE/sw-testptp/archive
MSCC_TESTPTP_SOURCE = ${MSCC_TESTPTP_VERSION}.tar.gz

define MSCC_TESTPTP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" -C $(@D)
endef

define MSCC_TESTPTP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/testptp $(TARGET_DIR)/usr/bin
endef

MSCC_TESTPTP_LICENSE = MIT
MSCC_TESTPTP_LICENSE_FILES = COPYING
MSCC_TESTPTP_ACTUAL_SOURCE_SITE = no upstream

$(eval $(generic-package))
