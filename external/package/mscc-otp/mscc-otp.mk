################################################################################
#
# mscc-otp
#
################################################################################

MSCC_OTP_VERSION = ac7d7c3cea8c47394cafb1ba78846b5e7ef1d008
MSCC_OTP_SITE = https://bitbucket.microchip.com/UNGE/sw-otp/archive
MSCC_OTP_SOURCE = ${MSCC_OTP_VERSION}.tar.gz
MSCC_OTP_INSTALL_STAGING = YES

MSCC_OTP_LICENSE = MIT
MSCC_OTP_LICENSE_FILES = COPYING
MSCC_OTP_ACTUAL_SOURCE_SITE = no upstream

$(eval $(cmake-package))
