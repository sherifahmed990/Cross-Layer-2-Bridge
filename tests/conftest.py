import pytest
# from brownie_tokens import MintableForkToken

@pytest.fixture(autouse=True)
def setup(fn_isolation):
    """
    Isolation setup fixture.
    This ensures that each test runs against the same base environment.
    """
    pass

@pytest.fixture(scope="module")
def l1sBridge(accounts, L1DomainSideBridge):
    """
    Yield a `Contract` object for the DestinationDomainSideBridge contract.
    """
    yield accounts[0].deploy(L1DomainSideBridge)

@pytest.fixture(scope="module")
def dsBridge(accounts, DestinationDomainSideBridge):
    """
    Yield a `Contract` object for the DestinationDomainSideBridge contract.
    """
    yield accounts[0].deploy(DestinationDomainSideBridge, accounts[2])

@pytest.fixture(scope="module")
def ssBridge(accounts, SourceDomainSideBridgeTest):
    """
    Yield a `Contract` object for the SourceDomainSideBridge contract.
    """
    yield accounts[0].deploy(SourceDomainSideBridgeTest, accounts[2])

@pytest.fixture(scope="module")
def token0(accounts,TestToken):
    """
    Yield a `Contract` object for an ERC20 token contract.
    """
    yield accounts[0].deploy(TestToken, accounts[0], 1000000000000)


    