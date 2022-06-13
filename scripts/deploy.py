from brownie import SourceDomainSideBridge, DestinationDomainSideBridge, L1DomainSideBridge, accounts, network

l1DomainSideContract = "0xF3A7EDf172C66427D8284f19f6c62Be1a738Fb33"
#  SourceDomainSideBridge deployed at: 0x6Fa32eE1871631717b7898A8C41Bc851Bf07b3e5
#  DestinationDomainSideBridge deployed at: 0x2A22D002f4BBA380502071E0D152d5D10A5281B5
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