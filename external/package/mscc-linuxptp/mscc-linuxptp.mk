################################################################################
#
# mscc-linuxptp
#
################################################################################

MSCC_LINUXPTP_VERSION = 0d2ed208a1a0ad3cecc9e8ad043d600a2f449ffa
MSCC_LINUXPTP_SITE = $(call github,microchip-ung,ptp4l,$(MSCC_LINUXPTP_VERSION))
MSCC_LINUXPTP_LICENSE = GPL-2.0+
MSCC_LINUXPTP_LICENSE_FILES = COPYING

MSCC_LINUXPTP_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	KBUILD_OUTPUT=$(STAGING_DIR)

MSCC_LINUXPTP_MAKE_OPTS = \
	prefix=/usr \
	EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)"

define MSCC_LINUXPTP_BUILD_CMDS
	$(MSCC_LINUXPTP_MAKE_ENV) $(MAKE) $(MSCC_LINUXPTP_MAKE_OPTS) -C $(@D) all
endef

define MSCC_LINUXPTP_INSTALL_TARGET_CMDS
	$(MSCC_LINUXPTP_MAKE_ENV) $(MAKE) $(MSCC_LINUXPTP_MAKE_OPTS) \
		DESTDIR=$(TARGET_DIR) -C $(@D) install
endef

$(eval $(generic-package))
