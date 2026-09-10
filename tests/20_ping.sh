#!/bin/sh
# Check 3 - h1 can ping h2 through s1 with no controller.
. "$(dirname "$0")/lib.sh"
banner "check 3: h1 ping h2 (no controller)"

require_container
dexec mn -c >/dev/null 2>&1

if dexec python3 /workspace/topo/lab0_topo.py ping; then
  pass "h1 reached h2 through s1 in failMode=standalone"
else
  die "h1 could not ping h2" \
      "run 'make shell' then 'python3 topo/lab0_topo.py ping' and read the output"
fi
