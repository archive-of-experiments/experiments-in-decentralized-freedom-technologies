// SPDX-License-Identifier: GNU AFFERO GENERAL PUBLIC LICENSE Version 3

// It seems valuable to support newcomers who found their first FreedomCash Wallet 
// with some Matic so that they can execute their first transactions on Blockchains easily.

// During early phases of the Freedom Cash Project newcomers might receive such a Matic Donation by simply asking for it via
// https://t.me/FriendsOfSatoshi_bot. This means every Geo Cacher is invited to claim Matic for each Freedom Cash Wallet 
// he has generated and funded or found. With this Geo Cachers can enjoy e.g. the Freedom Players Board from Jan's & Tobias' Team easily.

// We open up spaces to explore and co-create architectures of freedom.

pragma solidity 0.8.19;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.4/contracts/token/ERC20/IERC20.sol";

contract MaticForNewComers { 

    address public nativeFreedomCash = 0x1Dc4E031e7737455318C77f7515F8Ea8bE280a93;    

    uint256 public donationCounter;

    mapping(address => uint256) public maticReceived; 
    mapping(uint256 => IDonation) public dons; 

    error CheckInput();
    error CheckdID();
    error TransferOfMaticFailed();

    struct IDonation {
        address from;
        uint256 totalMatic;
        uint256 distributedMatic;
        uint256 perClaimMaticAmount;
        uint256 minFREE;
        string donationMessage;
    }

    function donate(uint256 perClaimMaticAmount, uint256 minFREE, string memory donationMessage) public payable {
        if (perClaimMaticAmount > 0 && msg.value > 0 && (msg.value % perClaimMaticAmount == 0)) {
            donationCounter++;
            dons[donationCounter] = IDonation(msg.sender, msg.value, 0, perClaimMaticAmount, minFREE, donationMessage);
        } else {
            revert CheckInput();
        }
    }

    function claimMaticFor(address receiver, uint256 dID) public {
        if (dons[dID].totalMatic > dons[dID].distributedMatic) {
            if (getMaticBalanceOf(receiver) == 0 && getFREEBalanceOf(receiver) >= dons[dID].minFREE && maticReceived[receiver] == 0) {
                (bool sent, ) = address(receiver).call{value: dons[dID].perClaimMaticAmount}("Freedom Cash");
                if (sent == false) { 
                    revert TransferOfMaticFailed(); 
                }
                maticReceived[receiver] = dons[dID].perClaimMaticAmount;
                dons[dID].distributedMatic = dons[dID].distributedMatic + dons[dID].perClaimMaticAmount;
            } else {
                revert CheckInput();
            }
        } else {
            revert CheckdID();
        }
    }

    function getMaticBalanceOf(address walletAddress) public view returns(uint256)  {
        return address(walletAddress).balance;
    }

    function getFREEBalanceOf(address walletAddress) public view returns(uint256)  {
        return IERC20(address(nativeFreedomCash)).balanceOf(address(walletAddress));
    }

}
