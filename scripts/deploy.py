from brownie import SourceDomainSideBridge, DestinationDomainSideBridge, accounts, network

#accounts = ['0xC0BcE0346d4d93e30008A1FE83a2Cf8CfB9Ed301', '0xf414d65808f5f59aE156E51B97f98094888e7d92', '0x055f1c2c9334a4e57ACF2C4d7ff95d03CA7d6741', '0x1B63B4495934bC1D6Cb827f7a9835d316cdBB332', '0x303E8684b9992CdFA6e9C423e92989056b6FC04b', '0x5eC14fDc4b52dE45837B7EC8016944f75fF42209', '0x22162F0D8Fd490Bde6Ffc9425472941a1a59348a', '0x1DA0dcC27950F6070c07F71d1dE881c3C67CEAab', '0xa4c7f832254eE658E650855f1b529b2d01C92359','0x275CAe3b8761CEdc5b265F3241d07d2fEc51C0d8']

def main():
    # requires brownie account to have been created
    if network.show_active()=='development':
        # add these accounts to metamask by importing private key
        owner = accounts[0]
        SourceDomainSideBridge.deploy({'from':accounts[0]}, publish_source=True)
        DestinationDomainSideBridge.deploy({'from':accounts[0]}, publish_source=True)
        #VyperStorage.deploy({'from':accounts[0]})

    elif network.show_active() == 'kovan':
        # add these accounts to metamask by importing private key
        owner = accounts.load("first")
        SourceDomainSideBridge.deploy({'from':owner}, publish_source=True)
        DestinationDomainSideBridge.deploy({'from':owner}, publish_source=True)
        #VyperStorage.deploy({'from':owner})