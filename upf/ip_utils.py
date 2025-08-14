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
import sys
import ipaddress

"""
Script used to fetch first IP address in a given IP range. i.e. the calling bash script reads the std output

Usage in command line:
e.g:
$ python3 ip_utils.py --ip_range 192.168.100.0/24
$ python3 ip_utils.py --ip_range 2001:230:cafe::/48
"""


def validate_ip_net(ctx, param, value):
    try:
        ip_net = ipaddress.ip_network(value)
        return ip_net
    except ValueError:
        raise click.BadParameter(
            'Value does not represent a valid IPv4/IPv6 range')


@click.command()
@click.option('--ip_range',
              required=True,
              callback=validate_ip_net,
              help='UE IPv4/IPv6 Address range in CIDR format e.g. 192.168.100.0/24 or 2001:230:cafe::/48')
def start(ip_range):

    # Get the first IP address in the IP range and netmask prefix length
    first_ip_addr = next(ip_range.hosts(), None)
    if not first_ip_addr:
        raise ValueError('Invalid UE IPv4 range. Only one IP given')
    else:
        first_ip_addr = first_ip_addr.exploded
        print(str(first_ip_addr))

if __name__ == '__main__':
    try:
        start()
        sys.exit(0)
    except ValueError:
        sys.exit(1)
