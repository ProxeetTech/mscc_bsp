################################################################################
#
# mscc-qos-utils
#
################################################################################

MSCC_QOS_UTILS_VERSION = a5050640d36489f7126cef92f3529243295fa099
MSCC_QOS_UTILS_SITE = https://bitbucket.microchip.com/UNGM/qos-utils/archive
MSCC_QOS_UTILS_SOURCE = ${MSCC_QOS_UTILS_VERSION}.tar.gz
MSCC_QOS_UTILS_INSTALL_STAGING = YES

MSCC_QOS_UTILS_LICENSE = MIT
MSCC_QOS_UTILS_LICENSE_FILES = LICENSE
MSCC_QOS_UTILS_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
