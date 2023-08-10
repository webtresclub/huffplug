const fetch = require('node-fetch');
const fs = require('fs');

const eventIds = [4069,4510,4672,5606,12045,15027,15963,18520,52155,58336,59190,61068,67249,74218,82615,88154,98481,126806,40634,43911,50802,63135,59174,72434,99888,143194]

async function go(id) {
  const response = await fetch(`https://api.poap.tech/event/${id}/poaps?limit=300&offset=0`, {
    "headers": {
      "accept": "*/*",
      "accept-language": "es-419,es;q=0.9",
      "cache-control": "no-cache",
      "pragma": "no-cache",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "cross-site",
      "sec-gpc": "1",
      "x-api-key": "vg..................OX", // taken using poap frontend
    "body": null,
    "method": "GET"
  });
  return response.json();
}

const eventsResponse = {};

async function run() {
  for(let i = 0; i < eventIds.length; i++) {
    const id = eventIds[i];
    console.log(id);
    eventsResponse[id] = await go(id);
    fs.writeFileSync('events.json', JSON.stringify(eventsResponse, null, 2));
  }
}

run();