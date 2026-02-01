// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./YulDeployer.sol";
import {Fallback} from "../src/fallback/Fallback.sol";

interface iAttacker {
  function attack() external;
}

contract FallbackTest is Test, YulDeployer {
  Fallback public fb;
  iAttacker  public attacker;

  function setUp() public {
    fb = new Fallback();
    attacker = iAttacker(deployYul("FallbackAttack"));
  }

  function testAttack() public {
    attacker.attack();
  }
}