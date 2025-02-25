#!/usr/bin/env ruby

$path = ENV["BINARIES_DIR"]
$version = "v2.8.8-mchp1"

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/lan966x_b0-release.fip.gz")
system("gzip -d lan966x_b0-release.fip.gz")
system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/fwu-lan966x_b0-release.html -O #{$path}/fwu.html")

system("cert_create -n --ntfw-nvctr 3 --key-alg ecdsa --hash-alg sha256 " \
       "--nt-fw-key output/build_arm_bootloaders/build/host-mscc-atf-#{$version}/keys/bl33_ecdsa.pem " \
       "--nt-fw-cert /tmp/lan966x.crt --nt-fw #{$path}/u-boot-mchp_lan966x_evb.bin")
system("fiptool update --nt-fw-cert /tmp/lan966x.crt --nt-fw #{$path}/u-boot-mchp_lan966x_evb.bin lan966x_b0-release.fip")

system("mv lan966x_b0-release.fip #{$path}/lan966x_b0-release.fip")
system("rm /tmp/lan966x.crt")
