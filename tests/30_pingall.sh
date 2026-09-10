#!/bin/sh
# Check 4 - three hosts, pingall drops nothing.
. "$(dirname "$0")/lib.sh"
banner "check 4: pingall over three hosts"

require_container
dexec mn -c >/dev/null 2>&1

if dexec python3 /workspace/topo/lab0_topo.py pingall; then
  pass "pingall dropped 0% over 3 hosts"
else
  die "pingall did not come back clean" \
      "TODO 5 in topo/lab0_topo.py: add h3 and link it to s1"
fi
