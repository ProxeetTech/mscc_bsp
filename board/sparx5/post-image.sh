#!/usr/bin/env bash

soc="sparx5"

# Remove the first argument which is the path to the +images+ output directory
shift

# The rest of the arguments comes from +BR2_ROOTFS_POST_SCRIPT_ARGS+
# Add the types to generate in +BR2_ROOTFS_POST_SCRIPT_ARGS+ separated by space

# all tergets are by default if +BR2_ROOTFS_POST_SCRIPT_ARGS+ is empty
if [[ $# -eq 0 ]]; then
    types="itb-rootfs ext4-itb-bare ubifs-itb-bare"
else
    types="$@"
fi

for type in $types
do
    case $type in
	"itb-rootfs")
	    echo "Generate fit.itb..."
	    $BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
		-s $soc \
		-t $type \
		-k $BINARIES_DIR/mscc-linux-kernel.bin.gz \
		-d $BINARIES_DIR/sparx5_pcb125.dtb,pcb125 \
		-d $BINARIES_DIR/sparx5_pcb134.dtb,pcb134 \
		-d $BINARIES_DIR/sparx5_pcb134_emmc.dtb,pcb134_emmc \
		-d $BINARIES_DIR/sparx5_pcb135.dtb,pcb135 \
		-d $BINARIES_DIR/sparx5_pcb135_emmc.dtb,pcb135_emmc \
		-d $BINARIES_DIR/lan969x_ev23x71a.dtb,lan9698_ev23x71a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_ev89p81a.dtb,lan9698_ev89p81a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_sr.dtb,lan9694_sunrise_0_at_lan969x \
		-a $BINARIES_DIR/overlays/lan969x_ev23x71a_dpll.dtbo,lan9698_ev23x71a_dpll_0_at_lan969x \
		-r $BINARIES_DIR/rootfs.tar \
		-o $BINARIES_DIR \
		-n fit
	    ;;
	"itb-initramfs")
	    echo "error: Generate $type not supported!" 1>&2
	    ;;
	"itb-bare")
	    echo "Generate itb-bare..."
	    $BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
		-s $soc \
		-t $type \
		-k $BINARIES_DIR/mscc-linux-kernel.bin.gz \
		-d $BINARIES_DIR/sparx5_pcb125.dtb,pcb125 \
		-d $BINARIES_DIR/sparx5_pcb134.dtb,pcb134 \
		-d $BINARIES_DIR/sparx5_pcb134_emmc.dtb,pcb134_emmc \
		-d $BINARIES_DIR/sparx5_pcb135.dtb,pcb135 \
		-d $BINARIES_DIR/sparx5_pcb135_emmc.dtb,pcb135_emmc \
		-d $BINARIES_DIR/lan969x_ev23x71a.dtb,lan9698_ev23x71a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_ev89p81a.dtb,lan9698_ev89p81a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_sr.dtb,lan9694_sunrise_0_at_lan969x \
		-a $BINARIES_DIR/overlays/lan969x_ev23x71a_dpll.dtbo,lan9698_ev23x71a_dpll_0_at_lan969x \
		-o $BINARIES_DIR
	    ;;
	"ext4-itb-bare")
	    echo "Generate ext4-itb-bare..."
	    $BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
		-s $soc \
		-t $type \
		-k $BINARIES_DIR/mscc-linux-kernel.bin.gz \
		-d $BINARIES_DIR/sparx5_pcb125.dtb,pcb125 \
		-d $BINARIES_DIR/sparx5_pcb134.dtb,pcb134 \
		-d $BINARIES_DIR/sparx5_pcb134_emmc.dtb,pcb134_emmc \
		-d $BINARIES_DIR/sparx5_pcb135.dtb,pcb135 \
		-d $BINARIES_DIR/sparx5_pcb135_emmc.dtb,pcb135_emmc \
		-d $BINARIES_DIR/lan969x_ev23x71a.dtb,lan9698_ev23x71a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_ev89p81a.dtb,lan9698_ev89p81a_0_at_lan969x \
		-d $BINARIES_DIR/lan969x_sr.dtb,lan9694_sunrise_0_at_lan969x \
		-a $BINARIES_DIR/overlays/lan969x_ev23x71a_dpll.dtbo,lan9698_ev23x71a_dpll_0_at_lan969x \
		-r $BINARIES_DIR/rootfs.tar \
		-o $BINARIES_DIR \
		-z \
		-n brsdk_standalone_arm64
	    ;;
	"ext4-itb-initramfs")
	    echo "error: Generate $type not supported!" 1>&2
	    ;;
	"ext4-bare")
	    echo "Generate ext4-bare..."
	    $BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
		-s $soc \
		-t $type \
		-r $BINARIES_DIR/rootfs.tar \
		-o $BINARIES_DIR
	    ;;
	"ubifs-itb-bare")
	    echo "Generate ubifs-itb-bare..."
	    $BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
		-s $soc \
		-t $type \
		-k $BINARIES_DIR/mscc-linux-kernel.bin.gz \
		-d $BINARIES_DIR/sparx5_pcb125.dtb,pcb125 \
		-d $BINARIES_DIR/sparx5_pcb134.dtb,pcb134 \
		-d $BINARIES_DIR/sparx5_pcb134_emmc.dtb,pcb134_emmc \
		-d $BINARIES_DIR/sparx5_pcb135.dtb,pcb135 \
		-d $BINARIES_DIR/sparx5_pcb135_emmc.dtb,pcb135_emmc \
		-r $BINARIES_DIR/rootfs.tar \
		-o $BINARIES_DIR
	    ;;
	*)
	    echo "error: Invalid type: $type!" 1>&2
	    ;;
    esac
done
