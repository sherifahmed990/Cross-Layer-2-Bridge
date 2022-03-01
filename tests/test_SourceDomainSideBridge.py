
def test_withdraw_emit_event(ssBridge):
    """
    Test if the contract will emit an event after a withdrawal
    """
    root1 = ssBridge.get_deposit_root()

    withdraw = ssBridge.withdraw("0x0000000000000000000000000000000000000000",
    "0xe48D5A8Ebb82d0365Cd734840b6d15e3370ca913", 5,
       1, 10, 1, {
           'value': "1 ether"
       })
    assert 'Transaction' in withdraw.events
    
    """
    Test if the contract balance will be 1 ether.
    """
    assert ssBridge.balance() == "1 ether"

    root2 = ssBridge.get_deposit_root()

    """
    Test if the Merkle root is changed.
    """
    assert root1 != root2

def test_withdraw_emit_event(ssBridge,token0):
    """
    Test if the contract will emit an event after a withdrawal
    """
    root1 = ssBridge.get_deposit_root()

    withdraw = ssBridge.withdraw("0x0000000000000000000000000000000000000000",
    "0xe48D5A8Ebb82d0365Cd734840b6d15e3370ca913", 5,
       1, 10, 1, {
           'value': "1 ether"
       })
    assert 'Transaction' in withdraw.events
    
    """
    Test if the contract balance will be 1 ether.
    """
    assert ssBridge.balance() == "1 ether"

    root2 = ssBridge.get_deposit_root()

    """
    Test if the Merkle root is changed.
    """
    assert root1 != root2
    assert token0.totalSupply() == 1



