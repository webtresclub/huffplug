extern crate ethers;

use ethers::types::{self, H256, H160, U256};
use ethers::abi::{self, Token, Address};
use ethers::utils::{self, keccak256};

use std::{fmt::Write, num::ParseIntError};


pub fn encode_hex(bytes: &[u8]) -> String {
    let mut s = String::with_capacity(bytes.len() * 2);
    for &b in bytes {
        write!(&mut s, "{:02x}", b).unwrap();
    }
    s
}

fn main() {
    let user: H160 = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D".parse().unwrap();
    let current_salt: H256 = "0xa05e334153147e75f3f416139b5109d1179cb56fef6a4ecb4c4cbc92a7c37b70".parse().unwrap();

    // let mut n = H256::from(270000u64); // Start from known nonce
    let mut n = U256::from(270000u64);

    loop {
        
        let encoded = abi::encode_packed(&[Token::Address(user), 
        // Token::Uint(current_salt),
        Token::FixedBytes(current_salt.0.to_vec()),
        Token::Uint(n)]).unwrap();
        let salt = keccak256(encoded);

        let saltVec = salt.to_vec();
        if (saltVec[0] == 0x00  && saltVec[1] == 0x00 /*&& saltVec[2] < 0x10 */) {
            println!("seed: {:?}", n);
            println!("hash: 0x{:?}", encode_hex(&salt.to_vec()));
            break;
        }

        if n % U256::from(10000) == U256::from(0) {
            println!("{:?}, {:?}", n, encode_hex(&salt.to_vec()));
        }

        // println!("{:?}", encode_hex(&salt.to_vec()));

        n += U256::from(1);
    }
}
