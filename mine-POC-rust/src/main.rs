extern crate ethers;

use std::env;

use ethers::types::{self, H256, H160, U256};
use ethers::abi::{self, Token, Address};
use ethers::utils::{self, keccak256};

use hex::encode as hex_encode;
use hex::decode as hex_decode;

use rand::{self, Rng};
use std::sync::mpsc;
use std::thread;
use std::{fmt::Write, num::ParseIntError, time::Instant};

fn main() {
    /*
    let user: H160 = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045".parse().unwrap();
    let current_salt: H256 = "0x5a711436e0ac9c67ddf36e0fbfe7563b84b66557d9645db22a1feb55e57c2bf8".parse().unwrap();
    let difficulty = 8;
    let num_threads = 4; // Adjust based on your hardware

    */

    let args: Vec<String> = env::args().collect();

    if args.len() < 5 {
        eprintln!("Usage: ./mine_POC_rust <user address> <current salt> <difficulty> <number of threads>");
        std::process::exit(1);
    }

    let user: H160 = args[1].parse().expect("Invalid address");
    let current_salt: H256 = args[2].parse().expect("Invalid salt");
    let difficulty: usize = args[3].parse().expect("Invalid difficulty");
    let num_threads: usize = args[4].parse().expect("Invalid number of threads");

    // Explicitly specify the message type for the channel
    let (tx, rx): (mpsc::Sender<(Vec<u8>, Vec<u8>)>, mpsc::Receiver<(Vec<u8>, Vec<u8>)>) = mpsc::channel();

    for thread_number in 0..num_threads {
        let tx = tx.clone();
        
        thread::spawn(move || {
            hash_loop(user, current_salt, difficulty, tx, thread_number);
        });
    }

    if let Ok((nonce, salt)) = rx.recv() {
        println!("Success with nonce: 0x{:}", hex_encode(&nonce));
        println!("Hash output: 0x{:}", hex_encode(&salt));
    }
}


fn hash_loop(user: H160, current_salt: H256, difficulty: usize, tx: mpsc::Sender<(Vec<u8>, Vec<u8>)>, thread_n: usize) {
    loop {
        let start = Instant::now(); // Start timing

        let mut rng = rand::thread_rng();

        let mut _n = vec![0u8; 32]; // Create random nonce
        rng.fill(&mut _n[..]);
                
        let encoded = abi::encode_packed(&[Token::Address(user), Token::FixedBytes(current_salt.0.to_vec())]).unwrap();

        let base_len = encoded.len();

        let mut encoded_with_nonce = encoded.clone();
        encoded_with_nonce.extend_from_slice(&_n); // Append the nonce bytes directly
        
        let mut nonce_pos = 0;
        let mut nonce_index = base_len + (nonce_pos % 32);
        

        for _i in 31..1_000_000 {            
            if encoded_with_nonce[nonce_index] == 255 {
                encoded_with_nonce[nonce_index] = rng.gen_range(0..=255);
                nonce_pos +=1 ;
                nonce_index = base_len + (nonce_pos % 32);
            } else {
                encoded_with_nonce[nonce_index] += 1;
            }

            // print to ensure the nonce is changing
            // println!("nonce_index: {}", hex_encode(&encoded_with_nonce[base_len..]));
            
            let salt = keccak256(&encoded_with_nonce);
            
            if leading_zeros(&salt, difficulty) {
                tx.send((encoded_with_nonce[base_len..].to_vec(), salt.to_vec())).unwrap();
                return;
            }
            
        }
        let elapsed = start.elapsed().as_secs_f32(); // Calculate elapsed time in seconds
        let hashes_per_second = 1_000_000f32 / elapsed;
        println!("thread {}, Hashes per second: {}", thread_n, hashes_per_second);
        
    }
}


fn leading_zeros(hash: &[u8], difficulty: usize) -> bool {
    // Calculate the number of full zero bytes required
    let full_zero_bytes = difficulty / 2;
 
 
    // Check each full zero byte
    for &byte in hash.iter().take(full_zero_bytes) {
        if byte != 0 {
            return false;
        }
    }

    // If n is odd, check the next half byte (4 bits) for zeros
    // Note: No need to check if full_zero_bytes is within bounds again, as it's implied by earlier return
    if difficulty % 2 != 0 && (hash.get(full_zero_bytes).unwrap_or(&0) & 0xF0) != 0 {
        return false;
    }

    true
}

// add test
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_main_loop() {
        let user = H160::from_low_u64_be(0x1234567890abcdef);
        let current_salt = H256::from_low_u64_be(0x1234567890abcdef);
        let difficulty = 10;
        let (tx, rx) = mpsc::channel();
        let thread_n = 0;

        hash_loop(user, current_salt, difficulty, tx, thread_n);
        let (nonce, salt) = rx.recv().unwrap();
        assert_eq!(nonce.len(), 32);
        assert_eq!(salt.len(), 32);
    }
}

