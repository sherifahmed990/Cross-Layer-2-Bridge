from brownie import SourceDomainSideBridge, DestinationDomainSideBridge, L1DomainSideBridge, accounts, network

l1DomainSideContract = "0x76Df34f51d6bE45F3bC300317E595333bf6F5708"
#  SourceDomainSideBridge deployed at: 0x4bC39CDa64831Fa385CFc855A28B24B3EEF86704
#  DestinationDomainSideBridge deployed at: 0x472D0CdC3336234b0685fcCbC5F5BC072eF6370B
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