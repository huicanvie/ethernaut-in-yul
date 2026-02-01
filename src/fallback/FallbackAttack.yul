/**
 * [Attack contract for Fallback challenge]
 * 1. The `receive` function is designed to receive plain transfers (transfer, send, call("")). 
 * 2. To satisfy the condition `contributions[msg.sender] > 0`, we first call `contribute()` with a transfer amount less than 0.001 ether. 
 * 3. Then, we perform a plain transfer operation: `token.call{value: 0.001 ether}("")`. 
 * 4.This fulfills the execution condition, leading to the execution of `owner = msg.sender`, thereby granting us ownership. 
 * 5. With ownership secured, we execute `withdraw()`, withdrawing the entire balance of the contract, effectively emptying its funds.
 */
object "Fallback" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }

  object "Runtime" {
    code {
      
    }
  }
}