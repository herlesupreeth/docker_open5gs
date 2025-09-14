# BSD 2-Clause License

# Copyright (c) 2020-2025, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import click
import subprocess
import ipaddress

"""
Usage in command line:
e.g:
$ python3 tun_if.py --tun_ifname ogstun --tun_ifmode tun --ipv4_range 192.168.100.0/24 --ipv6_range 2001:230:cafe::/48 --no_nat_ipv4_addr 172.22.0.21 --no_nat_ipv6_addr 2001:230:eafe::1
"""

def validate_ip_net(ctx, param, value):
    try:
        ip_net = ipaddress.ip_network(value)
        return ip_net
    except ValueError:
        raise click.BadParameter(
            'Value does not represent a valid IPv4/IPv6 range')

def validate_ip(ctx, param, value):
    try:
        ip_addr = ipaddress.ip_address(value)
        return ip_addr.exploded
    except ValueError:
        raise click.BadParameter('Value does not represent a valid IPv4/IPv6 address')

@click.command()
@click.option('--tun_ifname',
              required=True,
              help='TUN interface name e.g. ogstun')
@click.option('--tun_ifmode',
              required=True,
              type=click.Choice(['tun', 'tap']),
              help='TUN interface mode e.g. tun or tap')
@click.option('--ipv4_range',
              required=True,
              callback=validate_ip_net,
              help='UE IPv4 Address range in CIDR format e.g. 192.168.100.0/24')
@click.option('--ipv6_range',
              required=True,
              callback=validate_ip_net,
              help='UE IPv6 Address range in CIDR format e.g. 2001:230:cafe::/48')
@click.option('--no_nat_ipv4_addr',
              required=True,
              callback=validate_ip,
              help='Destination IPv4 address to which NATing must not be applied e.g. 172.22.0.21')
@click.option('--no_nat_ipv6_addr',
              required=True,
              callback=validate_ip,
              help='Destination IPv6 address to which NATing must not be applied e.g. 2001:230:eafe::1')
@click.option('--nat_rule',
              default='yes',
              help='Option specifying whether to add NATing iptables rule or not')
def start(tun_ifname,
          tun_ifmode,
          ipv4_range,
          ipv6_range,
          no_nat_ipv4_addr,
          no_nat_ipv6_addr,
          nat_rule):

    # Get the first IP address in the IP range and netmask prefix length
    first_ipv4_addr = next(ipv4_range.hosts(), None)
    if not first_ipv4_addr:
        raise ValueError('Invalid UE IPv4 range. Only one IP given')
    else:
        first_ipv4_addr = first_ipv4_addr.exploded
    first_ipv6_addr = next(ipv6_range.hosts(), None)
    if not first_ipv6_addr:
        raise ValueError('Invalid UE IPv6 range. Only one IP given')
    else:
        first_ipv6_addr = first_ipv6_addr.exploded

    ipv4_netmask_prefix = ipv4_range.prefixlen
    ipv6_netmask_prefix = ipv6_range.prefixlen

    # Setup the TUN/TAP interface, set IP address and setup IPtables
    execute_bash_cmd('ip tuntap add name ' + tun_ifname + ' mode ' + tun_ifmode)
    execute_bash_cmd('ip addr add ' + first_ipv4_addr + '/' +
                     str(ipv4_netmask_prefix) + ' dev ' + tun_ifname)
    execute_bash_cmd('ip addr add ' + first_ipv6_addr + '/' +
                     str(ipv6_netmask_prefix) + ' dev ' + tun_ifname)
    execute_bash_cmd('ip link set ' + tun_ifname + ' mtu 1450')
    execute_bash_cmd('ip link set ' + tun_ifname + ' up')
    if nat_rule == 'yes':
        execute_bash_cmd('if ! iptables-save | grep -- \"-A POSTROUTING -s ' + ipv4_range.with_prefixlen + ' ! -o ' + tun_ifname + ' ! -d ' + no_nat_ipv4_addr + ' -j MASQUERADE\" ; then ' +
                         'iptables -t nat -A POSTROUTING -s ' + ipv4_range.with_prefixlen + ' ! -o ' + tun_ifname + ' ! -d ' + no_nat_ipv4_addr + ' -j MASQUERADE; fi')
        execute_bash_cmd('if ! ip6tables-save | grep -- \"-A POSTROUTING -s ' + ipv6_range.with_prefixlen + ' ! -o ' + tun_ifname + ' ! -d ' + no_nat_ipv6_addr + ' -j MASQUERADE\" ; then ' +
                         'ip6tables -t nat -A POSTROUTING -s ' + ipv6_range.with_prefixlen + ' ! -o ' + tun_ifname + ' ! -d ' + no_nat_ipv6_addr + ' -j MASQUERADE; fi')
        execute_bash_cmd('if ! iptables-save | grep -- \"-A INPUT -i ' + tun_ifname + ' -j ACCEPT\" ; then ' +
                         'iptables -A INPUT -i ' + tun_ifname + ' -j ACCEPT; fi')
        execute_bash_cmd('if ! ip6tables-save | grep -- \"-A INPUT -i ' + tun_ifname + ' -j ACCEPT\" ; then ' +
                         'ip6tables -A INPUT -i ' + tun_ifname + ' -j ACCEPT; fi')


def execute_bash_cmd(bash_cmd):
    return subprocess.run(bash_cmd, stdout=subprocess.PIPE, shell=True)


if __name__ == '__main__':
    start()
