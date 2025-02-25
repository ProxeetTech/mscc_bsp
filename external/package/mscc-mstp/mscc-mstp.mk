################################################################################
#
# mstp
#
################################################################################

MSCC_MSTP_VERSION = 0.0.8
MSCC_MSTP_SITE = https://github.com/mstpd/mstpd/archive
MSCC_MSTP_SOURCE = $(MSCC_MSTP_VERSION).tar.gz
MSCC_MSTP_INSTALL_STAGING = YES

define MSCC_MSTP_RUN_AUTOGEN
      cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

MSCC_MSTP_CONF_ARGS = --exec_prefix=""
MSCC_MSTP_CONF_OPTS = $(MSCC_MSTP_CONF_ARGS)

MSCC_MSTP_PRE_CONFIGURE_HOOKS += MSCC_MSTP_RUN_AUTOGEN

MSCC_MSTP_LICENSE = GPL-2.0
MSCC_MSTP_LICENSE_FILES = LICENSE
MSCC_MSTP_ACTUAL_SOURCE_SITE = no upstream

$(eval $(autotools-package))
