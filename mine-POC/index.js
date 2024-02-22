const {keccak256, encodePacked} = require('viem');


const cluster = require('node:cluster');
const numCPUs = require('node:os').availableParallelism();
const process = require('node:process');


// global user input data
// makeAddr("user")
const USER ='0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D';
// keccak256("salt")
const CURRENT_SALT ='0xa05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b70';

const DIFFICULTY = 9;


if (cluster.isPrimary) {
  console.log(`Primary ${process.pid} is running`);
  console.log(`Using ${numCPUs} core cpus`);

  // Fork workers.
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  // lets handle stats
  let loops = 0;
  
  // Count requests
  function messageHandler(msg) {
    if (msg.cmd && msg.cmd === 'loop') {
      loops++;
    }
  }
   for (const id in cluster.workers) {
    cluster.workers[id].on('message', messageHandler);
  }

  process.on("exit", () => {
    for (const id in cluster.workers) {
      cluster.workers[id].kill();
    }
  });

  cluster.on('exit', (worker, code, signal) => {
    console.log(`worker ${worker.process.pid} died`);
    process.exit();
  });


  const start = +Date.now();
  setInterval(() => {
    const totalMS = (+Date.now() - start);
    
    const hashPerSecond = ((loops * 100000) / totalMS) * 1000;
    const khPerSecond = hashPerSecond / 1000;

    console.log(`TotalProcess: ${numCPUs}. KHs per second: ${Math.floor(khPerSecond)}, TotalLoops: ${loops}`);   
  }, 2000);

} else {
  console.log(`Worker ${process.pid} started`);
  runMainWorkLoop();
}

function randomSeed() {
  // return Array.from(crypto.getRandomValues(new Uint8Array(32))); // crashes chrome
  const x = new Array(32);
  for (let i = 0; i < 32; i++) {
    x[i] = (Math.random() * 256) | 0;
  }
  return x;
}

function hex(arrayBuffer)
{
    return '0x' + Array.from(arrayBuffer)
        .map(n => n.toString(16).padStart(2, "0"))
        .join("");
}

function runMainWorkLoop() {
  const expectedHash = '0x'+'0'.repeat(DIFFICULTY); // Pre-compute expected hash prefix
    
  const bytesConcat = USER.toLowerCase().slice(2).concat(CURRENT_SALT.slice(2));
  const searchSeed = [];
  for (let i = 0; i < bytesConcat.length; i += 2) {
    searchSeed.push(parseInt(bytesConcat.slice(i, i + 2), 16));
  }

  const baseLen = searchSeed.length;


  while(1) {
    const message = new Uint8Array(searchSeed.concat(randomSeed()));
    
    for(let i = 0; i < 100000; ++i) {
      const hash = keccak256(message);
      
      if (hash.startsWith(expectedHash)) { // Use startsWith for clarity
        console.log("seed:", hex(message.slice(-32)));
        console.log("hash:", hash);
        process.exit();
      }
      message[baseLen + (i & 31)] = (Math.random() * 256) | 0;
    }
    process.send({ cmd: 'loop' });
  }
  
}
