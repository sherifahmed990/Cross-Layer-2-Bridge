
import brownie
from brownie import accounts

def test_Source_Contract(ssBridge, dsBridge, token0):
    balanceBefore = accounts[0].balance()
    contractBalanceBefore = ssBridge.balance()

    transfer1 = ssBridge.transfer("0x0000000000000000000000000000000000000000",
        accounts[2], 
        ".00001 ether", #in kwei
        10,
        {
            'from':accounts[0],
            'value': ".02 ether"
        }
    )
    transaction1 = transfer1.events['Transaction']['transferData']

    """
    Test if the contract will emit an event after a transfer
    """
    assert 'Transaction' in transfer1.events

    """
    Test will revert if amount higher than maximum amount
    """
    with brownie.reverts():
        transfer1 = ssBridge.transfer("0x0000000000000000000000000000000000000000",
        accounts[2], 
        "1 ether", #in kwei(divide by one thousand)
        10,
        {
            'from':accounts[0],
            'value': ".02 ether"
        }
    )

    """
    Test will revert if no enough ether sent with the transaction
    """
    with brownie.reverts():
        transfer1 = ssBridge.transfer("0x0000000000000000000000000000000000000000",
        accounts[2], 
        "1 ether", #in kwei(divid by one thousand)
        10,
        {
            'from':accounts[0],
            'value': "1 wei"
        }
    )

    balanceAfter = accounts[0].balance()
    contractBalanceAfter = ssBridge.balance()

    """
    Test if ether is transfered to the contract
    """
    assert balanceAfter < balanceBefore
    assert contractBalanceAfter > contractBalanceBefore

    rewardClaims = []
    for i in range(1,21):
        transfer1 = ssBridge.transfer("0x0000000000000000000000000000000000000000",
            accounts[2], 
            ".00001 ether", #in kwei(divide by one thousand)
            10,
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

        rewardClaims.append(claim1.events['Reward']['rewardData'])

    hashonion = claim1.events['NewHashOnionCreated']['hash']
    print(hashonion)

    addho1 = ssBridge.addNewKnownHashOnion(hashonion)

    """
    Test if the contract will emit an event after a addNewKnownHashOnion
    """
    assert 'NewKnownHashOnionAdded' in addho1.events

    balanceBefore = accounts[0].balance()
    ssBridge.processClaims(rewardClaims)
    balanceAfter = accounts[0].balance()

    """
    Test if ether is transfered to the lp
    """
    assert balanceAfter > balanceBefore