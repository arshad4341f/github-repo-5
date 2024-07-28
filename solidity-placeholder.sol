// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
}

interface ILendingPool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

contract ArbitrageBot {
    address public owner;
    ILendingPoolAddressesProvider public addressesProvider;

    constructor(address _addressesProvider) {
        owner = msg.sender;
        addressesProvider = ILendingPoolAddressesProvider(_addressesProvider);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function executeFlashLoan(
        address token,
        uint256 amount,
        bytes calldata params
    ) external onlyOwner {
        address lendingPool = addressesProvider.getLendingPool();
        address[] memory assets = new address[](1);
        assets[0] = token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // no debt

        ILendingPool(lendingPool).flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            params,
            0
        );
    }

    function withdrawProfit() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
