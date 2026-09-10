#!/bin/sh
# Check 1 - the container exists, is named right, has the tools, sees the repo.
. "$(dirname "$0")/lib.sh"
banner "check 1: container and toolchain"

require_container
pass "container '$CONTAINER' is running"

for tool in mn ovs-vsctl ovs-ofctl python3 ip ping; do
  dexec sh -c "command -v $tool >/dev/null 2>&1" \
    || die "'$tool' not found inside the container" \
           "the image should provide it; did you change the Dockerfile?"
done
pass "mn / ovs-vsctl / ovs-ofctl / python3 / ip / ping are all present"

dexec test -f /workspace/topo/lab0_topo.py \
  || die "/workspace/topo/lab0_topo.py is not visible inside the container" \
         "TODO 3: mount the project directory at /workspace"
pass "the repository is mounted at /workspace"

printf '      %s\n' "$(dexec ovs-vsctl --version | head -1)"
printf '      mininet %s\n' "$(dexec mn --version 2>&1 | head -1)"
