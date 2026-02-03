// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./YulDeployer.sol";
import {Fallback} from "../src/fallback/Fallback.sol";

interface IFallbackAttack {
  function attack(address target) external payable returns (bool);
}

contract FallbackTest is Test, YulDeployer {
  Fallback public fb;
  IFallbackAttack public attacker;

  function setUp() public {
    fb = new Fallback();
    attacker = IFallbackAttack(deployYul("fallback/FallbackAttack"));
    vm.deal(address(attacker), 1 ether);
  }

  function testAttack() public {
   attacker.attack{value: 1 ether}(address(fb));
  }
}