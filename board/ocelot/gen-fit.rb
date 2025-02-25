#!/usr/bin/env ruby

$path = "output/build_mipsel_standalone/images"
$output = "fit-ocelot.itb"
$pwd = %x(pwd).chomp()

def create_fit(load_kernel, entry_kernel)
    its = '''
/dts-v1/;

/ {
	description = "FIT image file";
	#address-cells = <1>;

	images {
		kernel {
			description = "Kernel";
			data = /incbin/("PATH_KERNEL");
			type = "kernel";
			arch = "mips";
			os = "linux";
			compression = "gzip";
			load = <0xLOAD_KERNEL>;
			entry = <0xENTRY_KERNEL>;
		};

		fdt{
			description = "Flattened Device Tree blob";
			data = /incbin/("PATH_FDT");
			type = "flat_dt";
			arch = "mips";
			compression = "none";
		};

		ramdisk {
			description = "ramdisk";
			data = /incbin/("PATH_RAMDISK");
			type = "ramdisk";
			arch = "mips";
			os = "linux";
			compression = "none";
		};
	};

	configurations {
	        default = "conf@ocelot";

		conf@ocelot {
			description = "mips kernel";
			kernel = "kernel";
			fdt = "fdt";
			ramdisk = "ramdisk";
		};
	};
};
    '''
    its.sub! "PATH_KERNEL", "#{$pwd}/#{$path}/kernel.bin"
    its.sub! "PATH_FDT", "#{$pwd}/#{$path}/ocelot_pcb123.dtb"
    its.sub! "PATH_RAMDISK", "#{$pwd}/#{$path}/rootfs.squashfs"
    its.sub! "LOAD_KERNEL", "#{load_kernel}"
    its.sub! "ENTRY_KERNEL", "#{entry_kernel}"

    File.open("#{$path}/vmlinux.its", 'w') { |file| file.write(its) }

    system("mkimage -f #{$pwd}/#{$path}/vmlinux.its #{$path}/#{$output}")
end

def get_kernel_info(keyword)
    output = %x(mkimage -l #{$path}/kernel.bin)
    lines = output.split("\n")
    lines.each { |x|
	if x.include?(keyword)
	    return x[keyword.length..keyword.length + 8]
	end
    }
end

# make a working copy
system("cp #{$path}/mscc-linux-kernel.bin #{$path}/kernel.bin")

# detect entry and load address
load_kernel = get_kernel_info("Load Address: ")
entry_kernel = get_kernel_info("Entry Point:  ")

# remove uImage header
system("tail -c+65 < #{$path}/kernel.bin > #{$path}/kernel")
system("rm #{$path}/kernel.bin")
system("mv #{$path}/kernel #{$path}/kernel.bin")

# create fit
create_fit(load_kernel, entry_kernel)
