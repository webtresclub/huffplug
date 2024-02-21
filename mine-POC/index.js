const {keccak256, encodePacked} = require('viem');

function fromHexString(hexString) {
  if(hexString.startsWith('0x')) hexString = hexString.slice(2);
  return Uint8Array.from(hexString.match(/.{1,2}/g).map((byte) => parseInt(byte, 16)));
}

function toHexString(bytes) {
  return  bytes.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '');
}

let n = 0;

// makeAddr("user")
const USER ='0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D';

// keccak256("salt")
const CURRENT_SALT ='0xa05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b70';
// 10k en 72 - 74 ms
const message = fromHexString(encodePacked(['address', 'bytes32', 'uint256'], [USER, CURRENT_SALT, Math.floor(Math.random() * 1e10)]))

const startArr = fromHexString(
  encodePacked(['address', 'bytes32'], [USER, CURRENT_SALT])
).length;

let startTimestamp = +Date.now();
while(true) {
  const result = keccak256(message);
  // demo para una dificultad de 5 ceros
  if(n % 10000 == 0) {
    console.log(n, result);
    // hash rate
    console.log('hash rate 10k in', ((+Date.now() - startTimestamp)), 'ms');
    startTimestamp = +Date.now();
  }
  if(result.startsWith('0x00000')) {
    console.log(`0x${toHexString(message)}`);

    console.log("seed:", `0x${toHexString(message.slice(-32))}`);
    console.log("hash:", result);
    break;
  };
  message[startArr + (n & 31)] = (Math.random() * 256) | 0;
  n++;
}

/**
 * Output:
 *

0x6ca6d1e2d5347bfab1d91e883f1915560e09129da05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b7000000000000000000000000000000000000000000000000000000000000422ad
seed: 271021n
hash: 0x000007f054220926c6f963ec4dae8a5f4b3905226fed39f215d0395cbd3739dd
*/