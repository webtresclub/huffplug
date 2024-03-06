const fs = require('fs');


// utility to get ens names from wallets
async function f(address) {
  const e = await fetch("https://api.thegraph.com/subgraphs/name/ensdomains/ens", {
    "headers": {
      "accept": "application/json, multipart/mixed",
      "accept-language": "es-419,es;q=0.5",
      "cache-control": "no-cache",
      "content-type": "application/json",
      "pragma": "no-cache",
      "sec-ch-ua": "\"Chromium\";v=\"122\", \"Not(A:Brand\";v=\"24\", \"Brave\";v=\"122\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Linux\"",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "same-site",
      "sec-gpc": "1",
      "Referer": "https://thegraph.com/",
      "Referrer-Policy": "strict-origin-when-cross-origin"
    },
    "body": "{\"query\":\"query getDomainForAccount {\\n  account(id: \\\""+address+"\\\") {\\n    registrations(first: 1, orderBy: expiryDate, orderDirection: desc) {\\n      domain {\\n        name\\n      }\\n    }\\n    id\\n  }\\n}\\n\",\"operationName\":\"getDomainForAccount\"}",
    "method": "POST"
  });
  return e
}

const whitelistedThatHaveEns = {}

fs.readFileSync('./whitelist.txt').toString().split("\n").map(x => x.trim()).filter(x => x.length > 0).forEach(async (x) => {
  const ensResponse = await f(x).then(e => e.json());
  if(ensResponse.data.account == null || ensResponse.data.account.registrations.length == 0) {
    return;
  }
  console.log(JSON.stringify(ensResponse.data.account, null,2))
  whitelistedThatHaveEns[x] = ensResponse.data.account.registrations[0].domain.name;
  fs.writeFileSync('./whitelist-ens.json', JSON.stringify(whitelistedThatHaveEns, null, 2));
  
  

});
  //.then(e => console.log(JSON.stringify(e, null,2)));
