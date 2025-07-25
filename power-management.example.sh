#!/bin/bash -eE
set -o pipefail
shopt -s inherit_errexit

#
# Change power management settings identified by `powertop`.
#
# Notes:
#  * This is an EXAMPLE! Actual hardware devices and settings for their power management will vary wildly from system
#    to system; NONE of the commands in this example script should actually be executed on your system. Gather your own
#    commands and descriptive comments using `powertop` (generating an HTML report with `powertop --html=powertop.html`
#    may be helpful for this).
#  * A script based on this example would be placed at `/usr/local/sbin/power-management`, to be used with the
#    corresponding `power-management.service` systemd unit. The systemd unit would be placed in `/etc/systemd/system`,
#    followed by running `systemctl daemon-reload`, `systemctl enabled power-management` (if desired), and
#    `systemctl start power-management`.
#  * Place experimental settings in the `experimental` function. When you're satisfied they work as expected, move them
#    to the `safe` function.
#  * `powertop` doesn't always do a good job of showing the command to deactivate a setting. BEFORE running the
#    activation command from `powertop`, run a suitable command to get the current (default) setting to add to the
#    deactivate section. For an `echo ...` command, this is simply `cat` of the same path. For other settings, like
#    those invoking `iw ...`, consult the documentation for the tool.
#

PROG_NAME=${0##*/}

main() {
	local mode=$1
	local items=$2

	[[ "$EUID" == '0' ]] || {
		echo "ERROR: $PROG_NAME must be run as root" >&2
		return 1
	}

	[[ "$mode" != 'help' ]] || {
		usage
		return 0
	}

	[[ $# -eq 1 || $# -eq 2 ]] || {
		usage
		return 1
	}

	[[ "$mode" == 'activate' || "$mode" == "deactivate" ]] || {
		echo "ERROR: Invalid mode ${mode@Q}" >&2
		return 1
	}

	[[ -n "$items" ]] || items='all'

	case "$items" in
		safe)
			safe "$mode"
			;;
		experimental)
			experimental "$mode"
			;;
		all)
			all "$mode"
			;;
		*)
			echo "ERROR: Invalid item set ${items%Q}" >&2
			return 1
			;;
	esac
}

safe() {
	local mode=$1

	if [[ "$mode" == 'activate' ]]; then
		# Autosuspend for USB device Touchscreen [ELAN]
		echo 'auto' > '/sys/bus/usb/devices/1-9/power/control'

		# Wireless Power Saving for interface wlan1
		iw dev wlan1 set power_save on
		
		# Runtime PM for PCI Device NVIDIA Corporation GP107M [GeForce GTX 1050 Mobile]
		echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/power/control';
		
		# NMI watchdog should be turned off
		echo '0' > '/proc/sys/kernel/nmi_watchdog';
		
		# VM writeback timeout
		echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';
		
		# Runtime PM for PCI Device Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
		echo 'auto' > '/sys/bus/pci/devices/0000:02:00.0/power/control';
		
		# Enable Audio codec power management
		echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
		
		# Runtime PM for PCI Device Intel Corporation HM175 Chipset LPC/eSPI Controller
		echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.0/power/control';
		
		# Enable SATA link power management for host0
		echo 'med_power_with_dipm' > '/sys/class/scsi_host/host0/link_power_management_policy';
		
		# Enable SATA link power management for host1
		echo 'med_power_with_dipm' > '/sys/class/scsi_host/host1/link_power_management_policy';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #15
		echo 'auto' > '/sys/bus/pci/devices/0000:00:1d.6/power/control';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #2
		echo 'auto' > '/sys/bus/pci/devices/0000:00:1c.1/power/control';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family USB 3.0 xHCI Controller
		echo 'auto' > '/sys/bus/pci/devices/0000:00:14.0/power/control';
	else
		# Autosuspend for USB device Touchscreen [ELAN]
		echo 'on' > '/sys/bus/usb/devices/1-9/power/control'
		
		# Wireless Power Saving for interface wlan1
		iw dev wlan1 set power_save off
		
		# Runtime PM for PCI Device NVIDIA Corporation GP107M [GeForce GTX 1050 Mobile]
		echo 'on' > '/sys/bus/pci/devices/0000:01:00.0/power/control';
		
		# NMI watchdog should be turned off
		echo '1' > '/proc/sys/kernel/nmi_watchdog';
		
		# VM writeback timeout
		echo '500' > '/proc/sys/vm/dirty_writeback_centisecs';
		
		# Runtime PM for PCI Device Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
		echo 'on' > '/sys/bus/pci/devices/0000:02:00.0/power/control';
		
		# Enable Audio codec power management
		echo '0' > '/sys/module/snd_hda_intel/parameters/power_save';
		
		# Runtime PM for PCI Device Intel Corporation HM175 Chipset LPC/eSPI Controller
		echo 'on' > '/sys/bus/pci/devices/0000:00:1f.0/power/control';
	
		# Enable SATA link power management for host0
		echo 'max_performance' > '/sys/class/scsi_host/host0/link_power_management_policy';
		
		# Enable SATA link power management for host1
		echo 'max_performance' > '/sys/class/scsi_host/host1/link_power_management_policy';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #15
		echo 'on' > '/sys/bus/pci/devices/0000:00:1d.6/power/control';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #2
		echo 'on' > '/sys/bus/pci/devices/0000:00:1c.1/power/control';
		
		# Runtime PM for PCI Device Intel Corporation 100 Series/C230 Series Chipset Family USB 3.0 xHCI Controller
		echo 'on' > '/sys/bus/pci/devices/0000:00:14.0/power/control';
	fi
}

experimental() {
	local mode=$1

	if [[ "$mode" == 'activate' ]]; then
		:
	else
		:
	fi
}

all() {
	local mode=$1

	safe "$mode"
	experimental "$mode"
}

usage() {
	echo "Usage:" >&2
	echo "    $PROG_NAME {activate|deactivate} [{safe|experimental|all}] (default: all)" >&2
	echo "    $PROG_NAME help" >&2
}

main "$@"
