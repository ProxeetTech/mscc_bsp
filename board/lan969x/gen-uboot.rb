#!/usr/bin/env ruby

$path = ENV["BINARIES_DIR"]
$version = "v2.8.8-mchp1"

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/fwu-lan969x_a0-release.html -O #{$path}/fwu.html")

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/lan969x_a0-release.fip.gz")
system("gzip -d lan969x_a0-release.fip.gz")
system("cert_create -n --ntfw-nvctr 3 --key-alg ecdsa --hash-alg sha256 " \
       "--nt-fw-key output/build_arm64_bootloaders/build/host-mscc-atf-#{$version}/keys/bl33_ecdsa.pem " \
       "--nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_signed.bin")
system("fiptool update --nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_signed.bin lan969x_a0-release.fip")
system("mv lan969x_a0-release.fip #{$path}/lan969x_a0_signed-release.fip")
system("rm /tmp/lan969x.crt")

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/lan969x_a0-release.fip.gz")
system("gzip -d lan969x_a0-release.fip.gz")
system("cert_create -n --ntfw-nvctr 3 --key-alg ecdsa --hash-alg sha256 " \
       "--nt-fw-key output/build_arm64_bootloaders/build/host-mscc-atf-#{$version}/keys/bl33_ecdsa.pem " \
       "--nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x.bin")
system("fiptool update --nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x.bin lan969x_a0-release.fip")
system("mv lan969x_a0-release.fip #{$path}/lan969x_a0-release.fip")
system("rm /tmp/lan969x.crt")

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/lan969x_lm-release.fip.gz")
system("gzip -d lan969x_lm-release.fip.gz")
system("cert_create -n --ntfw-nvctr 3 --key-alg ecdsa --hash-alg sha256 " \
       "--nt-fw-key output/build_arm64_bootloaders/build/host-mscc-atf-#{$version}/keys/bl33_ecdsa.pem " \
       "--nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_sram.bin")
system("fiptool update --nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_sram.bin lan969x_lm-release.fip")
system("mv lan969x_lm-release.fip #{$path}/lan969x_lm_sram_emmc-release.fip")
system("rm /tmp/lan969x.crt")

system("dd if=/dev/zero of=mmc.gpt conv=sparse bs=1M count=3720")
system("parted -s mmc.gpt mktable gpt")
system("parted -s mmc.gpt --align minimal mkpart fip  2048s 264191s")
system("dd status=none if=#{$path}/lan969x_lm_sram_emmc-release.fip of=mmc.gpt seek=2048 bs=512 conv=notrunc")
system("parted -s mmc.gpt --align minimal mkpart fip.bak  264192s 526335s")
system("parted -s mmc.gpt --align minimal mkpart Env  526336s 530431s")
system("parted -s mmc.gpt --align minimal mkpart Env.bak  530432s 534527s")
system("parted -s mmc.gpt --align minimal mkpart Boot0 ext4 534528s 2631679s")
system("parted -s mmc.gpt --align minimal mkpart Boot1 ext4 2631680s 4728831s")
system("parted -s mmc.gpt --align minimal mkpart Data  4728832s 7614463s")
system("truncate -s 3145728 mmc.gpt")
system("mv mmc.gpt #{$path}/lan969x_lm_sram_emmc-release.gpt")

system("wget https://github.com/microchip-ung/arm-trusted-firmware/releases/download/#{$version}/lan969x_lm-release.fip.gz")
system("gzip -d lan969x_lm-release.fip.gz")
system("fiptool unpack --force --tb-fw bl2.bin --soc-fw bl31.bin --fw-config fw_config.bin " \
       "--trusted-key-cert trusted_key.crt --soc-fw-key-cert soc_fw_key.crt --soc-fw-cert soc_fw_content.crt " \
       "--tb-fw-cert tb_fw.crt --nt-fw-key-cert nt_fw_key.crt --nt-fw bl33.bin lan969x_lm-release.fip")
system("cert_create -n --ntfw-nvctr 3 --key-alg ecdsa --hash-alg sha256 " \
       "--nt-fw-key output/build_arm64_bootloaders/build/host-mscc-atf-#{$version}/keys/bl33_ecdsa.pem " \
       "--nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_sram.bin")
system("fiptool create --trusted-key-cert trusted_key.crt --soc-fw-key-cert soc_fw_key.crt --soc-fw-cert soc_fw_content.crt "\
       "--soc-fw bl31.bin --nt-fw-key-cert nt_fw_key.crt --nt-fw-cert /tmp/lan969x.crt --nt-fw #{$path}/u-boot-mchp_lan969x_sram.bin " \
       "lan969x_lm_sram_nor-release.fip")
system("fiptool create --fw-config fw_config.bin --tb-fw-cert tb_fw.crt --tb-fw bl2.bin " \
       "lan969x_lm_sram_nor_secured-release.fip")
system("dd if=lan969x_lm_sram_nor_secured-release.fip of=lan969x_lm_sram_nor-release.img")
system("dd conv=notrunc bs=1024 seek=128 if=lan969x_lm_sram_nor-release.fip of=lan969x_lm_sram_nor-release.img")
system("dd conv=notrunc bs=1024 seek=960 if=lan969x_lm_sram_nor-release.fip of=lan969x_lm_sram_nor-release.img")
system("truncate -s 2M lan969x_lm_sram_nor-release.img")
system("mv lan969x_lm_sram_nor-release.img #{$path}/lan969x_lm_sram_nor-release.img")
system("rm /tmp/lan969x.crt")
