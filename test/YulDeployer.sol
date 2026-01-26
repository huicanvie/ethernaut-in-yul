// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract YulDeployer is Test {
    /// @notice deploy Yul
    /// @param fileName yul (without .yul suffix)
    /// @return deployedAddress
    function deployYul(string memory fileName) public returns (address) {
        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        
        // commands：
        // 1. solc --strict-assembly --bin compile
        // 2. grep/tail extract pure hex string
        // 3. tr -d remove newline characters
        string memory bashCommand = string.concat(
            "solc --strict-assembly --bin src/", 
            fileName, 
            ".yul | grep -A1 Binary | tail -n1 | tr -d '\n'"
        );
        
        inputs[2] = bashCommand;

        // execute command Bytecode
        bytes memory bytecode = vm.ffi(inputs);

        require(bytecode.length > 0, "Yul compilation failed: empty bytecode");

        // deploy Bytecode
        address deployedAddress;
        assembly {
            // create(value, offset, length)
            // add(bytecode, 0x20) skip bytes length header
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Deployment failed");
        return deployedAddress;
    }
}