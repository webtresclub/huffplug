const {keccak256} = require('viem');


function hex(arrayBuffer){
    return Array.from(arrayBuffer)
        .map(n => n.toString(16).padStart(2, "0"))
        .join("");
}

module.exports = function runMainWorkLoop(DIFFICULTY, USER, CURRENT_SALT) {    
  const bytesConcat = USER.toLowerCase().slice(2).concat(CURRENT_SALT.slice(2));
  const searchSeed = [];
  for (let i = 0; i < bytesConcat.length; i += 2) {
    searchSeed.push(parseInt(bytesConcat.slice(i, i + 2), 16));
  }

  const baseLen = searchSeed.length;


  const SHIFT_NUM = BigInt(256 - (DIFFICULTY * 4));
  while(1) {
    const randomSeed = getRandomValues();
    randomSeed.forEach(n => searchSeed.push(n));
    const message = new Uint8Array(searchSeed);
    
    
    for(let i = 0; i < 100000; ++i) {
      const hash = keccak256(message);
      
      // if(BigInt(hash) >> SHIFT_NUM == 0n) { same as below
      if (BigInt(hash.slice(0, DIFFICULTY + 2)) == 0n) {
        console.log("seed:", hex(message.slice(-32)));
        console.log("hash:", hash);
        process.exit();
      }
      message[baseLen + (i & 31)] = (Math.random() * 256) | 0;
    }
    process.send({ cmd: 'loop' });
  }  
}

function getRandomValues() {
  return new Uint8Array(32).map(() => Math.floor(Math.random() * 256));
}
