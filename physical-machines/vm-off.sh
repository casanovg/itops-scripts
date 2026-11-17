#!/bin/sh

# Script to power a single virtual machine off
# .............................................
# 2018-03-15 gustavo.casanova@gmail.com
#
# Escalation policy (hardened 2026-11-17: during the weekly
# update-spirit-os run, w1-STG/w1-PRD shut their guest OS down but the
# VBoxHeadless processes hung mid power-off, the 300s wait expired
# silently with exit 0, and the update aborted leaving all guests off):
#   Phase 1. ACPI shutdown (guest-friendly), wait up to WAIT_TIME.
#   Phase 2. Forced poweroff ("vboxmanage controlvm poweroff",
#            i.e. virtual plug-pull), wait up to FORCE_WAIT_TIME.
#   Phase 3. SIGTERM then SIGKILL of the VBoxHeadless process(es).
# Exit codes: 0 clean ACPI stop, 1 VM not active, 2 VM not found,
#             3 forced poweroff was needed (VM stopped),
#             4 process kill was needed (VM stopped),
#             5 VM still running after all escalation (FAILURE).

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
WAIT_TIME=300 # If the virtual machine does not stop in 5 minutes, escalate
FORCE_WAIT_TIME=60 # Wait after forced poweroff before killing processes
KILL_WAIT_TIME=15 # Wait after SIGTERM before SIGKILL, and after SIGKILL before giving up
EXIT_CODE=0

is_running() {
	vboxmanage list runningvms 2>/dev/null | gawk -F\" '{print $(NF-1)}' | grep -qw "^$1$"
}

wait_while_running() {
	_REMAIN=$2
	while [ $_REMAIN -gt 0 ]; do
		if ! is_running "$1"; then
			return 0
		fi
		sleep 1
		_REMAIN=$((_REMAIN - 1))
	done
	if is_running "$1"; then
		return 1
	fi
	return 0
}

vm_pids() {
	# Print the PIDs of the VBoxHeadless process(es) of VM $1, one per line.
	# Match by UUID first (regex-safe), fall back to the --comment name.
	_UUID=$(vboxmanage showvminfo "$1" --machinereadable 2>/dev/null | awk -F= '/^UUID=/{gsub(/"/,"",$2);print $2}')
	if [ -n "$_UUID" ]; then
		pgrep -f "VBoxHeadless.*--startvm ${_UUID}" 2>/dev/null
		return
	fi
	ps -eo pid=,args= 2>/dev/null | grep -F "VBoxHeadless" | grep -F -- "--comment $1" | awk '{print $1}'
}

kill_vm_processes() {
	# SIGTERM, wait, then SIGKILL the VM processes. Returns 0 if the VM
	# dropped out of runningvms, 1 otherwise.
	_PIDS=$(vm_pids "$1")
	if [ -z "$_PIDS" ]; then
		echo ""$1": no VBoxHeadless process found, re-checking state ..."
		if is_running "$1"; then
			return 1
		fi
		return 0
	fi
	echo ""$1": sending SIGTERM to PID(s): $(echo $_PIDS | tr '\n' ' ')"
	kill $_PIDS 2>/dev/null
	if wait_while_running "$1" $KILL_WAIT_TIME; then
		return 0
	fi
	_PIDS=$(vm_pids "$1")
	if [ -n "$_PIDS" ]; then
		echo ""$1": still alive, sending SIGKILL to PID(s): $(echo $_PIDS | tr '\n' ' ')"
		kill -9 $_PIDS 2>/dev/null
		if wait_while_running "$1" $KILL_WAIT_TIME; then
			return 0
		fi
	fi
	return 1
}

if [ ! -z "$VM" ]; then
	RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
	if [ ! -z "$RUNNING_VM" ]; then
		echo ""
		echo ""$VM" virtual machine active, sending shutdown signal ..."
		vboxmanage controlvm "$VM" acpipowerbutton
		sleep 2
		vboxmanage controlvm "$VM" acpipowerbutton
		if wait_while_running "$VM" $WAIT_TIME; then
			echo ""$VM" stopped cleanly (ACPI)."
			echo ""
		else
			echo ""$VM" did not stop in ${WAIT_TIME}s, escalating to forced poweroff ..."
			vboxmanage controlvm "$VM" poweroff
			if wait_while_running "$VM" $FORCE_WAIT_TIME; then
				echo ""$VM" stopped (forced poweroff)."
				echo ""
				EXIT_CODE=3
			else
				echo ""$VM" did not stop in ${FORCE_WAIT_TIME}s after forced poweroff, killing processes ..."
				if kill_vm_processes "$VM"; then
					echo ""$VM" stopped (process kill)."
					echo ""
					EXIT_CODE=4
				else
					echo "ERROR: "$VM" still running after SIGTERM/SIGKILL, giving up."
					echo ""
					EXIT_CODE=5
				fi
			fi
		fi
	else
		echo ""
		echo ""$VM" virtual machine not active!"
		echo ""
		EXIT_CODE=1
	fi
else
	#echo ""
	echo ""$1" virtual machine not found!"
	echo ""
	EXIT_CODE=2
fi
exit $EXIT_CODE
