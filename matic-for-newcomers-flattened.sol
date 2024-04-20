
// File: https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.4/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: matic-for-newcomers.sol



// It seems valuable to support newcomers who found their first FreedomCash Wallet 
// with some Matic so that they can execute their first transactions on Blockchains easily.

// During early phases of the Freedom Cash Project newcomers might receive such a Matic Donation by simply asking for it via
// https://t.me/FriendsOfSatoshi_bot. This means every Geo Cacher is invited to claim Matic for each Freedom Cash Wallet 
// he has generated and funded or found. With this Geo Cachers can enjoy e.g. the Freedom Players Board from Jan's & Tobias' Team easily.

// We open up spaces to explore and co-create architectures of freedom.

pragma solidity 0.8.19;


contract MaticForNewComers { 

    address public nativeFreedomCash = 0x1Dc4E031e7737455318C77f7515F8Ea8bE280a93;    
    uint256 public donationCounter;
    mapping(address => uint256) public maticReceived; 
    mapping(uint256 => IDonation) public dons; 
    error CheckInput();
    error CheckdID();
    error TransferOfMaticFailed();
    struct IDonation {
        uint256 totalMatic;
        uint256 distributedMatic;
        uint256 perClaimMaticAmount;
        uint256 minFREE;
    }

    function donate(uint256 perClaimMaticAmount, uint256 minFREE) public payable {
        if (perClaimMaticAmount > 0 && msg.value > 0 && (msg.value % perClaimMaticAmount == 0)) {
            donationCounter++;
            dons[donationCounter] = IDonation(msg.value, 0, perClaimMaticAmount, minFREE);
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
