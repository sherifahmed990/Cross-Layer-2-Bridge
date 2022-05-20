
from brownie import accounts


def test_Destination_Contract(ssBridge, token0, dsBridge):
    
    #create 20 claims to create a batch
    for i in range(1,21):
        transfer1 = ssBridge.transfer("0x0000000000000000000000000000000000000000",
            accounts[2],
            ".00001 ether", #in kwei(divide by one thousand)
            0,
            {
                'from':accounts[0],
                'value': ".02 ether"
            }
        )
        transaction1 = transfer1.events['Transaction']['transferData']

        claim1 = dsBridge.claim(transaction1, {
            'from':accounts[0],
            'value': "1 ether"
        })

        """
        Test if the contract will emit an event after a calim
        """
        assert 'Reward' in claim1.events

    
    assert dsBridge.claimCount() == 20

    hashonion = claim1.events['NewHashOnionCreated']['hash']
    """
    0x920c2986e388705dc538e970b6c53912a833a8370ade23d6660c1e7b9003da2d
    """
    """
    token0.approve(ssBridge.address, 1000000, {"from": accounts[0]})
    transfer = ssBridge.transfer(token0.address, accounts[2], 5,
       10,{
           'from':accounts[0]
       })
    transaction2 = transfer1.events['Transaction']['transferData']
    assert 'Transaction' in transfer.events
    """
   