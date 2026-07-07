// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./YulDeployer.sol";

interface IFallout {
  function owner() external view returns (address payable);
}

interface IFalloutAttack {
  function attack(address target) external payable returns (bool);
}

contract FalloutTest is Test, YulDeployer {
  IFallout public fo;
  IFalloutAttack public attacker;

  function setUp() public {
    fo = IFallout(payable(deployCode("fallout/Fallout.sol:Fallout")));
    attacker = IFalloutAttack(deployYul("fallout/FalloutAttack"));
    vm.deal(address(attacker), 1 ether);
  }

  function testAttack() public {
    // Attack should succeed
    bool success = attacker.attack{value: 1 ether}(address(fo));
    assertTrue(success, "Attack failed");

    // Verify attacker gained ownership
    assertEq(fo.owner(), address(attacker), "Attacker should be the owner");
  }
}
