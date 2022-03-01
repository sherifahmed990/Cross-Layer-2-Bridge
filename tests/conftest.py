import pytest
from brownie_tokens import MintableForkToken

@pytest.fixture(autouse=True)
def setup(fn_isolation):
    """
    Isolation setup fixture.
    This ensures that each test runs against the same base environment.
    """
    pass

@pytest.fixture(scope="module")
def dsBridge(accounts, DestinationDomainSideBridge):
    """
    Yield a `Contract` object for the SolidityStorage contract.
    """
    yield accounts[0].deploy(DestinationDomainSideBridge)

@pytest.fixture(scope="module")
def ssBridge(accounts, SourceDomainSideBridge):
    """
    Yield a `Contract` object for the SolidityStorage contract.
    """
    yield accounts[0].deploy(SourceDomainSideBridge)


@pytest.fixture(scope="module")
def token0(accounts,):
    token = MintableForkToken("0xdCFaB8057d08634279f8201b55d311c2a67897D2")
    yield token._mint_for_testing(accounts[0], "1 ether")

    