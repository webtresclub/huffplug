const cluster = require('node:cluster');
const numCPUs = require('node:os').availableParallelism();
const process = require('node:process');

const workerLoop = require('./worker');


// global user input data
// makeAddr("user")
const USER ='0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D';
// keccak256("salt")
const CURRENT_SALT ='0xa05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b70';

const DIFFICULTY = 5;


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
  workerLoop(DIFFICULTY, USER, CURRENT_SALT)
}

