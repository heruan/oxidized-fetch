# oxidized-fetch

See https://github.com/ytti/oxidized/issues/170 for more information.


A simplified version of oxidized-script which calls Node.run and saves the
configuration on the output specified in oxidized's config.

## Example:

    $ oxf -m ios -g core 10.0.0.242

## Usage:

oxf [options] hostname

    -g, --group          host group
    -m, --model          host model (ios, junos, etc), otherwise discovered from Oxidized source
    -u, --username       username to use
    -p, --password       password to use
    -t, --timeout        timeout value to use
    -e, --enable         enable password to use
    -c, --community      snmp community to use for discovery
        --protocols      protocols to use, default "ssh, telnet"
    -v, --verbose        verbose output, e.g. show commands sent
    -d, --debug          turn on debugging
        --terse          display clean output
    -h, --help           Display this help message.

## To install:

    gem install bundler
    sudo rake install
