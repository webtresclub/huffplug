const {keccak256, encodePacked} = require('viem');


// start on 270000n to save time (known nonce from previous run)
let n = 270000n;

// makeAddr("user")
const USER ='0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D';

// keccak256("salt")
const CURRENT_SALT ='0xa05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b70';

while(true) {
  const message = encodePacked(['address', 'bytes32', 'uint256'], [USER, CURRENT_SALT, n])
  const result = keccak256(message);
  // demo para una dificultad de 5 ceros
  if(n % 10000n == 0n) console.log(n, result);
  if(result.slice(2,7) == '00000') {
    console.log(message);

    console.log("seed:", n);
    console.log("hash:", result);
    break;
  };
  n += 1n;
}

/**
 * Output:
 *

0x6ca6d1e2d5347bfab1d91e883f1915560e09129da05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b7000000000000000000000000000000000000000000000000000000000000422ad
seed: 271021n
hash: 0x000007f054220926c6f963ec4dae8a5f4b3905226fed39f215d0395cbd3739dd
*/