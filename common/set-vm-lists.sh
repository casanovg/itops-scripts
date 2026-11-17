#!/bin/sh

# Common virtual machine list settings
# ...........................................
# 2020-01-03 gustavo.casanova@gmail.com

# Print the VM names listed in file $1, one per line, ignoring blank
# lines, full-line comments ("#" with optional leading whitespace),
# trailing comments ("<name> # comment") and CRLF line endings.
# Warns on stderr and returns 1 if the file does not exist.
read_vm_list() {
	if [ ! -f "$1" ]; then
		echo "Warning: $1 not found, ignoring." >&2
		return 1
	fi
	sed -e 's/\r$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
	    -e '/^#/d' -e 's/[[:space:]][[:space:]]*#.*$//' -e '/^$/d' "$1"
}

ACTIVE_VMS=$(read_vm_list ~/ActiveVMs)
ESSENTIAL_NET_SERVICE="$(read_vm_list ~/EssentialNetServices)"
