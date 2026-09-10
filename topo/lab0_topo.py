#!/usr/bin/env python3
"""Lab 0 topology: one userspace OVS switch, no controller.

Part A (given):  h1 --- s1 --- h2
Part B (yours):  add h3 and link it to s1

Why no controller: s1 runs with failMode='standalone', so OVS falls back to
acting like an ordinary learning L2 switch. From Lab 2 on you will remove that
crutch and install every flow yourself.

Why datapath='user': the userspace (netdev) datapath needs no kernel module, so
this runs identically on your laptop and on the GitHub-hosted autograder.
"""

import sys
from functools import partial

from mininet.net import Mininet
from mininet.node import OVSSwitch
from mininet.topo import Topo
from mininet.link import TCLink
from mininet.log import setLogLevel, info


class Lab0Topo(Topo):
    def build(self):
        h1 = self.addHost('h1', ip='10.0.0.1/24', mac='02:00:00:00:00:01')
        h2 = self.addHost('h2', ip='10.0.0.2/24', mac='02:00:00:00:00:02')

        s1 = self.addSwitch('s1')

        self.addLink(s1, h1)
        self.addLink(s1, h2)

        # TODO 5 -- Part B.
        #   Add a third host h3 (10.0.0.3/24, mac 02:00:00:00:00:03) and link
        #   it to s1, so that `pingall` covers three hosts and drops nothing.
        #   Two lines. Look at how h1/h2 above are written.


def build_net():
    # Userspace datapath + no controller. Both are deliberate; see the docstring.
    switch = partial(OVSSwitch, datapath='user', failMode='standalone')
    net = Mininet(topo=Lab0Topo(), switch=switch, controller=None,
                  link=TCLink, autoSetMacs=False, waitConnected=False)
    return net


def run_ping():
    """h1 -> h2. Exit 0 on success."""
    net = build_net()
    try:
        net.start()
        h1, h2 = net.get('h1', 'h2')
        out = h1.cmd('ping -c 3 -W 2 -i 0.3 %s' % h2.IP())
        print(out)
        ok = ', 0 received' not in out and '0 packets received' not in out
        print('PASS: h1 can ping h2' if ok else 'FAIL: h1 cannot ping h2')
        return 0 if ok else 1
    finally:
        net.stop()


def run_pingall():
    """Full mesh over every host in the topology. Exit 0 only on 0% dropped."""
    net = build_net()
    try:
        net.start()
        hosts = net.hosts
        if len(hosts) < 3:
            print('FAIL: expected at least 3 hosts, found %d (%s). '
                  'Did you finish TODO 5?'
                  % (len(hosts), ' '.join(h.name for h in hosts)))
            return 1
        dropped = net.pingAll(timeout='2')
        print('dropped: %.1f%% over %d hosts' % (dropped, len(hosts)))
        if dropped == 0.0:
            print('PASS: pingall dropped 0%%')
            return 0
        print('FAIL: pingall dropped %.1f%%' % dropped)
        return 1
    finally:
        net.stop()


MODES = {'ping': run_ping, 'pingall': run_pingall}

if __name__ == '__main__':
    setLogLevel('info')
    mode = sys.argv[1] if len(sys.argv) > 1 else 'ping'
    if mode not in MODES:
        print('usage: %s [%s]' % (sys.argv[0], '|'.join(MODES)))
        sys.exit(2)
    sys.exit(MODES[mode]())
