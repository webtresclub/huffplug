extern crate ethers;

use ethers::types::{self, H256, H160, U256};
use ethers::abi::{self, Token, Address};
use ethers::utils::{self, keccak256};

use hex::encode as hex_encode; // Added for hex encoding
use hex::decode as hex_decode;//

use rand::Rng;

use std::{fmt::Write, num::ParseIntError};


fn main() {
    let user: H160 = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D".parse().unwrap();
    let current_salt: H256 = "0x851e34d5f1de39b1758b00f0040ae4ab4f3bc8c5631b4a8463144022de2cf428".parse().unwrap();

    loop {
        let mut rng = rand::thread_rng();

        // Corrected: Was referencing an undeclared variable `random_seed`
        let mut _n = vec![0u8; 32];
        rng.fill(&mut _n[..]); // Use rng variable declared above instead of creating a new one
        
        // Corrected: H256::from_slice is the correct method to create H256 from byte slice
        let mut n = hex_encode(&_n);
        let mut nonce: U256 = U256::from_big_endian(H256::from_slice(&_n).as_bytes());

        for i in 0..1000000 {
            
            let encoded = abi::encode_packed(&[Token::Address(user), 
            // Token::Uint(current_salt),
            Token::FixedBytes(current_salt.0.to_vec()),
            Token::Uint(nonce)]).unwrap();
            let salt = keccak256(encoded);
            // println!("hash: 0x{:?}", hex_encode(&salt.to_vec()));

            let saltVec = salt.to_vec();
    
            //if (&hex_encode(&salt)[0..6] == "000000") {
            if saltVec[0] == 0x00  && saltVec[1] == 0x00 && saltVec[2] == 0x00 && saltVec[3] == 0x00 {
                println!("seed: {:?}", nonce);
                println!("hash: 0x{:?}", hex_encode(&salt.to_vec()));

                // this will exit
                return;
                // break;
            }

            // Add 1 to the U256 value
            nonce += U256::from(1);
        }    
    }
}
