#!/bin/sh
# Check 2 - OVS daemons are alive and a userspace (netdev) bridge can be made.
. "$(dirname "$0")/lib.sh"
banner "check 2: Open vSwitch"

require_container

for d in ovsdb-server ovs-vswitchd; do
  dexec pidof "$d" >/dev/null 2>&1 \
    || die "$d is not running inside the container" \
           "make logs - the entrypoint starts it; TODO 2 is the usual cause"
done
pass "ovsdb-server and ovs-vswitchd are running"

BR=lab0chk
dexec ovs-vsctl --if-exists del-br "$BR" >/dev/null 2>&1
if ! dexec ovs-vsctl add-br "$BR" -- set bridge "$BR" datapath_type=netdev >/dev/null 2>&1; then
  dexec ovs-vsctl --if-exists del-br "$BR" >/dev/null 2>&1
  die "could not create a userspace (netdev) bridge" \
      "TODO 2: OVS needs elevated privileges inside the container"
fi
DP=$(dexec ovs-vsctl get bridge "$BR" datapath_type 2>/dev/null | tr -d '"')
dexec ovs-vsctl --if-exists del-br "$BR" >/dev/null 2>&1
[ "$DP" = "netdev" ] || die "bridge datapath_type is '$DP', expected 'netdev'" \
                            "see README section 5 on the userspace datapath"
pass "a netdev (userspace) bridge can be created and deleted"
