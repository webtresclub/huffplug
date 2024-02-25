extern crate ethers;

use ethers::types::{self, H256, H160, U256};
use ethers::abi::{self, Token, Address};
use ethers::utils::{self, keccak256};

use hex::encode as hex_encode; // Added for hex encoding
use hex::decode as hex_decode;//

use rand::Rng;

use std::{fmt::Write, num::ParseIntError, time::Instant};


fn main() {
    let user: H160 = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D".parse().unwrap();
    let current_salt: H256 = "0x851e34d5f1de39b1758b00f0040ae4ab4f3bc8c5631b4a8463144022de2cf428".parse().unwrap();
    let difficulty = 9;
    
    loop {
        let start = Instant::now(); // Start timing

        let mut rng = rand::thread_rng();

        let mut _n = vec![0u8; 32]; // Create random nonce
        //rng.fill(&mut _n[..]);
                
        let encoded = abi::encode_packed(&[Token::Address(user), Token::FixedBytes(current_salt.0.to_vec())]).unwrap();

        let base_len = encoded.len();

        let mut encoded_with_nonce = encoded.clone();
        encoded_with_nonce.extend_from_slice(&_n); // Append the nonce bytes directly
            
        for i in 0..1_000_000 {            
            let nonce_index = base_len + (i % 32);
            encoded_with_nonce[nonce_index] = rng.gen_range(0..=255);
            

            // let encoded = abi::encode_packed(&[Token::Address(user), Token::FixedBytes(current_salt.0.to_vec()),Token::Uint(nonce)]).unwrap();
            let salt = keccak256(&encoded_with_nonce);
            // println!("hash: 0x{:?}", hex_encode(&salt.to_vec()));
           // println!("hash: {:?}", nonce_index - base_len);
            
            if leading_zeros(&salt, difficulty) {
                println!("seed: 0x{:}", hex_encode(&encoded_with_nonce[base_len..].to_vec()));
                println!("hash output: 0x{:}", hex_encode(&salt.to_vec()));

                // this will exit
                return;
                // break;
            }
            
        }


        let elapsed = start.elapsed().as_secs_f32(); // Calculate elapsed time in seconds
        let hashes_per_second = 1_000_000f32 / elapsed;
        println!("loop, Hashes per second: {}", hashes_per_second);
    }
}


fn leading_zeros(hash: &[u8], n: usize) -> bool {
    // Calculate the number of full zero bytes required
    let full_zero_bytes = n / 2;

    // Check each full zero byte
    for &byte in hash.iter().take(full_zero_bytes) {
        if byte != 0x00 {
            return false;
        }
    }

    // If N is odd, check the next half byte (4 bits) for zeros
    if n % 2 != 0 {
        // Get the byte that should contain the next half-zero if full_zero_bytes is within bounds
        if full_zero_bytes < hash.len() {
            // Check if the higher 4 bits of the byte are 0 (for even N, we check the next byte)
            if hash[full_zero_bytes] & 0xF0 != 0 {
                return false;
            }
        }
    }

    true
}
