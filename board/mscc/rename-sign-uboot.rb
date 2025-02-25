#!/usr/bin/env ruby

$path = "mipsel_bootloaders_defconfig/images/"

Dir.glob("#{$path}/*.bin") do |filename|
    filename = File.basename(filename)
    filename.sub!(".bin", "")
    filename.sub!("u-boot-", "")

    chipfamily = filename
    input = "#{$path}/u-boot-#{chipfamily}.bin"
    output = "#{$path}/u-boot-#{chipfamily}.img"

    # Create a signed copy of the U-Boot binary,
    # recognizable by the WebStaX software stack.
    archid = ""
    chipid = ""
    case chipfamily
        when "luton"
          chipid = "0x7428"
          archid = 2
        when "jr2"
          chipid = "0x7468"
          archid = 2
        when "serval"
          chipid = "0x7438"
          archid = 2
        when "servalt"
          chipid = "0x7415"
          archid = 2
        when "ocelot"
          chipid = "0x7514"
          archid = 2
        else
          printf "Illegal chip family: #{chipfamily}\n"
          exit 1
    end

    system("perl -Iboard/mscc/lib board/mscc/mkbootimage.pl -T #{archid} -C #{chipid} -o #{output} #{input}")
end
