from brownie import SourceDomainSideBridge, DestinationDomainSideBridge, L1DomainSideBridge, accounts, network

l1DomainSideContract = "0xcd0291CA071Dbd75f1dB8d04D21fc9f2945196A3"
#  SourceDomainSideBridge deployed at: 0x04d18666ee55257Ad7f8c3314D5Cce7A30B9921c
#  DestinationDomainSideBridge deployed at: 0x1c2728dc77cC04d071F7a6522539a75CA04a2467
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