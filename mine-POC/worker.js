const {keccak256} = require('viem');


function hex(arrayBuffer){
    return Array.from(arrayBuffer)
        .map(n => n.toString(16).padStart(2, "0"))
        .join("");
}

module.exports = function runMainWorkLoop(DIFFICULTY, USER, CURRENT_SALT) {
  const expectedHash = '0x'+'0'.repeat(DIFFICULTY); // Pre-compute expected hash prefix
    
  const bytesConcat = USER.toLowerCase().slice(2).concat(CURRENT_SALT.slice(2));
  const searchSeed = [];
  for (let i = 0; i < bytesConcat.length; i += 2) {
    searchSeed.push(parseInt(bytesConcat.slice(i, i + 2), 16));
  }

  const baseLen = searchSeed.length;


  while(1) {
    const randomSeed = crypto.getRandomValues(new Uint8Array(32));
    randomSeed.forEach(n => searchSeed.push(n));
    const message = new Uint8Array(searchSeed);
    
    
    for(let i = 0; i < 100000; ++i) {
      const hash = keccak256(message);
      // Use startsWith for clarity
      if (hash.startsWith(expectedHash)) {
        console.log("seed:", hex(message.slice(-32)));
        console.log("hash:", hash);
        process.exit();
      }
      message[baseLen + (i & 31)] = (Math.random() * 256) | 0;
    }
    process.send({ cmd: 'loop' });
  }  
}
