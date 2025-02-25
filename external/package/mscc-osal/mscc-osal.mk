################################################################################
#
# osal
#
################################################################################

MSCC_OSAL_VERSION = c983cf5ac0b0567f2ee933a6242336bfe9fde718
MSCC_OSAL_SITE = https://github.com/rtlabs-com/osal.git
MSCC_OSAL_SITE_METHOD = git
MSCC_OSAL_GIT_SUBMODULES = YES
MSCC_OSAL_INSTALL_STAGING = YES
MSCC_OSAL_LICENSE = BSD-3-Clause
MSCC_OSAL_LICENSE_FILES = LICENSE
MSCC_OSAL_SUPPORTS_IN_SOURCE_BUILD = NO
MSCC_OSAL_CONF_OPTS += \
	-DBUILD_TESTING=OFF

$(eval $(cmake-package))
