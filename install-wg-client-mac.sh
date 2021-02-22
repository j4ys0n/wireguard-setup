#!/bin/bash

# wireguard-tools isn't really necessary, but might be useful for some
brew install wireguard-tools

echo "opening wireguard in app store, via chrome"
open -a "Google Chrome" https://apps.apple.com/us/app/wireguard/id1451685025?mt=12
echo "copy config from install-wg-host.sh to client machine"
