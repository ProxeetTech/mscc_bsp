#!/usr/bin/env ruby

require 'pp'
require 'open3'
require 'logger'
require 'optparse'
require 'fileutils'
require 'yaml'
require 'thread'
require_relative './external/support/scripts/resultnode.rb'

$steps = ["build", "pack", "relocate", "all"]

if ARGV.length < 1 or (not $steps.include?(ARGV[0]) and ARGV[0] != "--help")
    puts "One argument mandatory"
    exit
end

def sys(msg, cmd)
    begin
        system "#{$options[:build_path]}/#{$log_cmd} --line-prepend \"#{"%-20s" % [msg]}\" --log #{File.expand_path(__FILE__) + ".log"} -- \"#{cmd}\""
        raise "Running '#{cmd}' failed" if $? != 0 and $options[:fail_on_error]
    rescue
        save_log
        raise
    end
end

def sys_safe(msg, cmd)
    system "#{$options[:build_path]}/#{$log_cmd} --line-prepend \"#{"%-20s" % [msg]}\" --log #{File.expand_path(__FILE__) + ".log"} -- \"#{cmd}\""
end

def sys_ret(msg, file, cmd)
        system "#{$options[:build_path]}/#{$log_cmd} --line-prepend \"#{"%-20s" % [msg]}\" --log #{$options[:build_path]}/#{file + ".log"} -- \"#{cmd}\""
        return $? == 0 ? true : false
end

def sys_log(msg, file, cmd)
    begin
        system "#{$options[:build_path]}/#{$log_cmd} --line-prepend \"#{"%-20s" % [msg]}\" --log #{$options[:build_path]}/#{file + ".log"} -- \"#{cmd}\""
        raise "Running '#{cmd}' failed" if $? != 0 and $options[:fail_on_error]
    rescue
        save_log
        raise
    end
end

def save_log
    log_folder = "#{$src_ws}/#{$log_name}"
    sys_safe "save_log>", "mkdir -p #{log_folder}/"

    Dir.glob("external/configs/*.yaml").each do |conf_yaml|
        conf = YAML.load_file(conf_yaml)
        t = conf["defconfig_name"]
        o = "build_#{t.sub("_defconfig", "")}"
        next if not File.exist?("output/#{o}")

        sys_safe "save_log>", "cp output/#{o}/#{t}.log #{log_folder}/"
    end
    sys_safe "save_log>", "cd #{$src_ws} && tar -czf #{$log_name}.tar.gz --owner=root --group=root #{$log_name}"
    sys_safe "save_log>", "cd #{$src_ws}; mkdir -p artifact"
    sys_safe "save_log>", "cd #{$src_ws}; cp *.tar.gz artifact/"
    sys_safe "save_log>", "mkdir -p ../artifact";
    sys_safe "save_log>", "cp #{$src_ws}/artifact/* ../artifact/"
end

def find_keyword(array, keyword)
    array.each{ |x|
        if x.start_with?(keyword)
            data = x.split(/:?=/)
            return data[1] ? data[1].strip : nil
        end
    }
end

def get_uboot_version()
    uboot_sha = $config["vars"]["MSCC_UBOOT_SHA"]
    uboot_tar = "dl/uboot/uboot-#{uboot_sha}.tar.gz"
    if !File.exist?(uboot_tar)
      uboot_tar = "dl/muboot/muboot-#{uboot_sha}-br1.tar.gz"
      if !File.exist?(uboot_tar)
        raise "No uboot sources for version #{uboot_sha}"
      end
    end
    file_array = %x(tar -xzf #{uboot_tar} -O --wildcards --no-wildcards-match-slash '*/Makefile').split("\n")
    raise "No data" unless file_array

    version = find_keyword(file_array, "VERSION")
    patchlevel = find_keyword(file_array, "PATCHLEVEL")
    sublevel = find_keyword(file_array, "SUBLEVEL")
    extraversion = find_keyword(file_array, "EXTRAVERSION")

    res = "#{version}.#{patchlevel}"
    res += "-#{sublevel}" if not sublevel.nil?
    res += extraversion if not extraversion.nil?
    return res
end

def get_linux_version()
    linux_sha = $config["vars"]["MSCC_LINUX_KERNEL_SHA"]
    linux_tar = "dl/linux/#{linux_sha}.tar.gz"
    file_array = %x(tar -xzf #{linux_tar} -O --wildcards --no-wildcards-match-slash '*/Makefile').split("\n")
    raise "No data" unless file_array

    version = find_keyword(file_array, "VERSION")
    patchlevel = find_keyword(file_array, "PATCHLEVEL")
    sublevel = find_keyword(file_array, "SUBLEVEL")
    extraversion = find_keyword(file_array, "EXTRAVERSION")

    res = "#{version}.#{patchlevel}"
    res += "-#{sublevel}" if not sublevel.nil?
    res += extraversion if not extraversion.nil?
    return res
end

def read_manifest(file, pop_first_entry)
    res = []
    begin
        res = File.readlines(file)
        res.shift if pop_first_entry
    rescue
    end
    return res
end

def write_manifest(file, arr)
    File.open(file, 'w') { |f|
        arr.each { |a|
            f << a
        }
    }
end

def update_legal_info(output_folder)
    uboot = ""
    begin
        uboot = " --uboot #{get_uboot_version()}"
    rescue
    end
    sys "legal>", "./external/support/scripts/licensedata.rb --legal-info #{output_folder} --kernel #{get_linux_version()} #{uboot} > #{output_folder}/licensedata.txt"
    sys "legal>", "xz --check=none --lzma2=preset=6e,dict=64KiB --stdout #{output_folder}/licensedata.txt > #{output_folder}/licensedata.xz"
    sys "legal>", "rm -rf #{output_folder}/host-sources"
    sys "legal>", "rm -rf #{output_folder}/sources"
end

def generate_sdk_setup(arch, output)
    setup = ""
    if arch == "mips"
        setup += <<EOF
MSCC_SDK_TARGET      ?= mipsel-mips32r2-linux-gnu
MSCC_SDK_PATH        ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux
MSCC_SDK_SYSROOT     ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux/mipsel-buildroot-linux-gnu/sysroot
MSCC_SDK_PREFIX      ?= mipsel-linux-
MSCC_SDK_TARGET_OPTS ?= -mel -mabi=32 -msoft-float -march=mips32
EOF
    elsif arch == "arm"
        setup += <<EOF
MSCC_SDK_TARGET      ?= arm-cortex_a8-linux-gnu
MSCC_SDK_PATH        ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux
MSCC_SDK_SYSROOT     ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux/usr/arm-buildroot-linux-gnueabihf/sysroot
MSCC_SDK_PREFIX      ?= arm-linux-
MSCC_SDK_TARGET_OPTS ?= -march=armv7-a -mtune=cortex-a8 -mfpu=neon
EOF
    elsif arch == "arm64"
        setup += <<EOF
MSCC_SDK_TARGET      ?= arm64-armv8_a-linux-gnu
MSCC_SDK_PATH        ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux
MSCC_SDK_SYSROOT     ?= $(MSCC_SDK_BASE)/$(MSCC_SDK_TARGET)/xstax/release/x86_64-linux/aarch64-buildroot-linux-gnu/sysroot
MSCC_SDK_PREFIX      ?= aarch64-linux-
MSCC_SDK_TARGET_OPTS ?= -march=armv8-a -mtune=generic
EOF
    end

    setup += <<EOF
MSCC_TOOLCHAIN_FILE ?= #{$tool_file}
MSCC_TOOLCHAIN_DIR  ?= #{$tool_dir}
MSCC_TOOLCHAIN_BRANCH ?= #{$tool_br}
EOF

    IO.write("#{output}/sdk-setup.mk", setup)
end

def simplegrid_build(conf)
    ret = true
    t = conf["defconfig_name"]
    o = "build_#{t.sub("_defconfig", "")}"
    begin
        cmd  = "SimpleGridClient "
        cmd += "-e MCHP_DOCKER_NAME=\"ghcr.io/microchip-ung/bsp-buildenv\" -e MCHP_DOCKER_TAG=\"1.8\" "
        cmd += "-w ../#{$src_name}.tar.gz --stamps output/#{o}/#{t} "
        cmd += "-c 'hostname && pwd && "
        cmd += "./#{$src_name}/build.rb build --configs=#{t} --build-path=#{$src_name} "
        if $options[:fail_on_error]
            cmd += "--fail-on-error "
        end
        cmd += "&& "
        cmd += "rm -rf output/#{o}/build && "
        cmd += "pwd' "
        cmd += "-a #{$src_name}/output/#{o} "
        cmd += "-o output/#{o}.tar "
        ret = sys_ret "sg-#{t}>", "output/#{o}/#{t}", "#{cmd}"
        sys "sg-#{t}>", "tar xf output/#{o}.tar --strip-components 1"
        sys "sg-#{t}>", "rm output/#{o}.tar"
    rescue
        ret = false
    end
    $buildTop.addSibling(ResultNode.new(t, ret == true ? "OK" : "Failure"))
    return ret
end

#####################################################
$options = {
    :configs => ".*",
    :branch => "brsdk",
    :build_path => ".",
}

OptionParser.new do |opt|
    opt.banner = """
usage: ./build.rb build|pack|relocate|all [--configs=<regex>] [--simplegrid]
                  [--local] [--fail-on-error] [--summary]

Available steps:
    The step is the first argument and it is mandatory. It must be one of the
    following: build, pack, relocate, all.

    build    - builds the sources. Before running this step the user can fiddle
               around the buildroot and then just run this step again. This will
               generate again the output in the images folder but they will not
               be copy to the result folder that will be used by webstax.
               This command will prepare also the legal info and the sdk in case
               it is needed. It is possible to build only a specific package
               but in that case it is required to use the actual buildroot
               commands for that.
               The following options are available for this step:
                 - configs - accepts a regex expression that will be matched with
                             the configuration names, and only those that will
                             match will be build. If nothing is passed will match
                             all configurations
                 - simplegrid - this enables to build using SimpleGridClient,
                                the result will be stored in the sources. This
                                option removes the build folder from output dir
                                therefore running again the BUILD step it takes
                                the same amount of time.
    pack     - this collects all the results from output/build_{tgt_name} and
               add them to a folder. The result folder is
               'output/mscc-brsdk-<arch>-<version>-<build-no>'.
               The following options are available for this step:
                 - configs - it is similar with the one from the build step.
    relocate - this step creates the artifact folder or copies the result folder
               to /opt/mscc/ folder. The following options are available for
               this step:
                 - configs - it is similar with the one from the build step.
                 - local - choses to copy the result folder to /opt/mscc
                 - summary - creates a summary of the build. This options is
                             mainly used by Jenkins, because the output folder
                             depends on the build step.
    all      - it executes all the previous steps in the order: build, pack,
               relocate.

Few examples:
    - build all configurations for local use:
        ./build.rb all --simplegrid --local
    - build a single configuration for local use:
        ./build.rb all --configs mipsel_bootloaders --local
    - rebuild all bootloaders configurations:
        ./build.rb build --configs bootloaders
        After running this step the result target is still in the sources
        directory therefore you still need collect the results and copy them
        to /opt/mscc to use them, therefore the commands will do that
            ./build.rb pack
            ./build.rb relocate --local
    - build a kernel for arm64 used by webstax:
        ./build.rb all --configs arm64_xstax

Options:
    """
    opt.on('--configs=x',       "Regex expression of which configuration to be build") { |o| $options[:configs] = o }
    opt.on('--build-path=x',    "Configure the path to build.rb script") { |o| $options[:build_path] = o }
    opt.on('--simplegrid',      "If set use simple grid for building") { |o| $options[:simplegrid] = o }
    opt.on('--fail-on-error',   "If set it would failed on any error") { |o| $options[:fail_on_error] = o }
    opt.on('--summary=s',       "Write summary status JSON file") { |o| $options[:summary] = o }
    opt.on('--local',           "Skips the tar files that are needed for deploy.
                                       It can be used when building locally to test different changes") { |o| $options[:local] = o }
end.parse!

$config     = YAML.load_file("#{$options[:build_path]}/external/support/misc/config.yaml")

$topRes     = ResultNode.new('brsdk', "OK", {"sdkversion" => $options[:version]})
$buildTop   = ResultNode.new('build', "OK")

$src_ws     = ENV['WS'] || "./output"

$src_name   = %x(basename $PWD).chomp
$log_name   = $src_name.gsub("source", "logs")

$version    = $src_name.gsub("mscc-brsdk-source-", "")

$regexp     = Regexp.new($options[:configs])
$step       = ARGV[0]

$tool_ver   = $config["tool_ver"]
$tool_br    = $config["tool_br"]
$tool_dir   = "#{$tool_ver}-#{$tool_br}"
$tool_file  = "#{$tool_ver}"
$tool_file  = "#{$tool_file}-#{$tool_br}" if $tool_br != "toolchain"

$log_cmd    = "./external/support/scripts/logcmd.rb"

sdk_install = "/usr/local/bin/mscc-install-pkg"
if File.exist?(sdk_install)
    sys "toolchain", "sudo #{sdk_install} -t toolchains/#{$tool_dir} mscc-toolchain-bin-#{$tool_file}"
elsif not File.exist?("/opt/mscc/mscc-toolchain-bin-#{$tool_file}")
    puts "ABORT: Required toolchain: mscc-toolchain-bin-#{$tool_file} doesn't exits"
    exit
end

if $step == "all" or $step == "build"
    threads = []
    semaphore = Mutex.new
    ret = true
    Dir.glob("#{$options[:build_path]}/external/configs/*.yaml").each do |conf_yaml|
        conf = YAML.load_file(conf_yaml)
        next if not $regexp.match(conf["defconfig_name"])

        t = conf["defconfig_name"]
        o = "build_#{t.sub("_defconfig", "")}"

        if $options[:simplegrid]
            threads << Thread.new do
                tmp = simplegrid_build conf
                semaphore.synchronize {
                    ret &= tmp
                }
            end
        else
            threads << Thread.new do
                ret = true
                begin
                    sys_log "#{t}>", "#{File.join("output/#{o}", "#{t}")}", "echo 'Building #{t}. Watch progress with \'tail -f ./output/#{o}/#{t}.log\''"
                    sys_log "#{t}>", "#{File.join("output/#{o}", "#{t}")}", "hostname"
                    sys_log "#{t}>", "#{File.join("output/#{o}", "#{t}")}", "cd #{$options[:build_path]}; make BR2_EXTERNAL=./external O=output/#{o}"
                    if conf["sdk_path"]
                      sys_log "#{t}>", "#{File.join("output/#{o}", "#{t}")}", "cd #{$options[:build_path]}; make BR2_EXTERNAL=./external O=output/#{o} sdk"
                    end
                    sys_log "#{t}>", "#{File.join("output/#{o}", "#{t}")}", "cd #{$options[:build_path]}; make BR2_EXTERNAL=./external O=output/#{o} legal-info"
                rescue
                    ret = false
                end
                $buildTop.addSibling(ResultNode.new(t, ret == true ? "OK" : "Failure"))
            end
        end
    end

    threads.each do |t|
        t.join
    end

    if ret == false and $options[:simplegrid]
        save_log
        exit -1
    end
end

$topRes.addSibling($buildTop)
$topRes.reCalc

if $step == "all" or $step == "pack"
    result_folders = []
    log_folder = "#{$src_ws}/#{$log_name}"
    sys "pack >", "mkdir -p #{log_folder}/"

    Dir.glob("external/configs/*.yaml").each do |conf_yaml|
        conf = YAML.load_file(conf_yaml)
        next if not $regexp.match(conf["defconfig_name"])

        t = conf["defconfig_name"]
        o = "build_#{t.sub("_defconfig", "")}"
        next if not File.exist?("output/#{o}")

        img_folder    = "#{$src_ws}/images/#{conf["output_path"]}"
	packetdir     = "#{$src_ws}/#{conf["output_packet"]}-#{$version}"
        result_folder = "#{packetdir}/#{conf["output_path"]}"
        result_folders << packetdir

        sys "pack>", "mkdir -p #{img_folder}"
        sys "pack>", "mkdir -p #{result_folder}"

        Dir.glob("output/#{o}/images/*").each do|f|
          if f =~ /sdk-buildroot.tar.gz$/
            sdkpath = packetdir + "/" + conf["sdk_path"]
            sys "pack>", "mkdir -p #{sdkpath}"
            sys "pack>", "tar -C #{sdkpath} -xzf #{f} --strip-components 1 --exclude-from=external/support/misc/tar-unpack-exclude.txt"
          else
            sys "pack>", "cp -r #{f} #{result_folder}"
            sys "pack>", "cp -r #{f} #{img_folder}/."
          end
        end

        legal_output = "#{result_folder}/legal-info"
        sys "pack>", "mkdir -p #{legal_output}"

        # in case multiple configuration have the same output dir for the
        # manifest file then the last build will overwrite the other ones
        # the fix consists of merging the files
        arr = read_manifest("#{legal_output}/manifest.csv", false)
        sys "pack>", "cp -r output/#{o}/legal-info/* #{legal_output}"
        arr = arr + read_manifest("#{legal_output}/manifest.csv", arr.any? ? true : false)
        write_manifest("#{legal_output}/manifest.csv", arr)

        sys "pack>", "cp  external/support/misc/mscc-version #{packetdir}/.mscc-version"
        sys "pack>", "cp  output/#{o}/#{t}.log #{result_folder}"
        sys "pack>", "mv  #{result_folder}/*.log #{log_folder}/"

        generate_sdk_setup "#{conf["arch"]}", "#{packetdir}"
        #update_legal_info legal_output
    end

    result_folders = result_folders.uniq
    result_folders.each { |x|
        sys "dedup>", "./external/support/scripts/dedup.rb #{x}"
    }
end

if $step == "all" or $step == "relocate"
    # create arch
    result_folders = []
    Dir.glob("external/configs/*.yaml").each do |conf_yaml|
        conf = YAML.load_file(conf_yaml)
        next if not $regexp.match(conf["defconfig_name"])

        t = conf["defconfig_name"]
        o = "build_#{t.sub("_defconfig", "")}"
        next if not File.exist?("output/#{o}")

        result_folder = "#{conf["output_packet"]}-#{$version}"
        result_folders << result_folder
    end

    threads = []
    result_folders = result_folders.uniq
    result_folders.each { |result_folder|
        threads << Thread.new do
            if File.exist?("#{$src_ws}/#{result_folder}.tar.gz")
                sys "relocate>", "cd #{$src_ws} && rm #{result_folder}.tar.gz"
            end
            sys "relocate>", "cd #{$src_ws} && tar -czf #{result_folder}.tar.gz --owner=root --group=root #{result_folder}"
        end
    }
    threads.each do |t|
        t.join
    end

    sys "relocate>", "cd #{$src_ws} && tar -czf #{$log_name}.tar.gz --owner=root --group=root #{$log_name}"

    if $options[:local]
        system "cd #{$src_ws}; for f in *.tar.gz; do sudo tar -xzf $f -C /opt/mscc; done"
    else
        sys "relocate", "cd #{$src_ws}; mkdir -p artifact"
        sys "relocate", "cd #{$src_ws}; cp *.tar.gz artifact/"
        sys "relocate", "cd #{$src_ws}; cp -r images/* artifact/"

        if $options[:summary]
            $topRes.to_file($options[:summary])
            sys "relocate", "mv #{$options[:summary]} #{$src_ws}/artifact"
        end

        sys "relocate", "cd #{$src_ws}/artifact; echo 'toolchain: #{$tool_file}' > dependencies.txt"
        sys "relocate", "cd #{$src_ws}/artifact; find . -type f ! -iname files.md5 -print0 | xargs -0 md5sum > files.md5"
    end
end

if $topRes.status == "OK"
    exit 0
else
    exit -1
end
