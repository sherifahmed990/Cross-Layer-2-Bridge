from brownie import SourceDomainSideBridge, DestinationDomainSideBridge, L1DomainSideBridge, accounts, network

l1DomainSideContract = "0x8F0F1538e04BD1f61D94BeAd25f2606dBDee203f"
#  SourceDomainSideBridge deployed at: 0xBb7D1032371486eef0A5e17Ff0279be14078F3E4
#  DestinationDomainSideBridge deployed at: 0x33323F2B2D204DBa2A55341D099c5bA6B3C952e5
def main():
    # requires brownie account to have been created
    if network.show_active()=='development':
        # add these accounts to metamask by importing private key
        owner = accounts[0]
        SourceDomainSideBridge.deploy(accounts[2], {'from':accounts[0]})
        DestinationDomainSideBridge.deploy(accounts[2], {'from':accounts[0]})
    elif network.show_active() == 'kovan':
        owner = accounts.load("first")
        l1dcontract = L1DomainSideBridge.deploy({'from':owner}, publish_source=True)

    elif network.show_active() == 'OptimismKovan':
        owner = accounts.load("first")
        SourceDomainSideBridge.deploy(l1DomainSideContract, {'from':owner}, publish_source=False)
        DestinationDomainSideBridge.deploy(l1DomainSideContract, {'from':owner}, publish_source=False)