const poapEvents = require('./events.json');

const uniqueAddressesPerEvent = {};
let uniqueAddresses = {};

const meetMarto = [40634,43911,50802,63135,59174,72434,99888,143194];
const communityEvents = [4069,4510,4672,5606,12045,15027,15963,18520,52155,58336,59190,61068,67249,74218,82615,88154,98481,126806];

Object.keys(poapEvents).forEach((eventId) => {
  poapEvents[eventId].tokens.forEach(e => {
    uniqueAddressesPerEvent[eventId] = uniqueAddressesPerEvent[eventId] || {};
    uniqueAddressesPerEvent[eventId][e.owner.id] = true;
    uniqueAddresses[e.owner.id] = uniqueAddresses[e.owner.id] || 0;
    uniqueAddresses[e.owner.id] += 1;
  });

  uniqueAddressesPerEvent[eventId] = Object.keys(uniqueAddressesPerEvent[eventId]);
});


const whitelist = {};
Object.keys(uniqueAddresses).forEach((address) => {
  if (uniqueAddresses[address] > 1) {
    whitelist[address] = true;
  }
});

console.log(Object.keys(uniqueAddresses).length);
console.log(Object.keys(whitelist).length);

Object.keys(whitelist).sort().forEach((address) => {
  console.log(address);
})






