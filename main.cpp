#include<bits/stdc++.h>
using namespace std;



/**
 * This function uses a 128-bit key to encrypt a 64-bit block in 32 cycles using TEA
 *
 * @param values - uint32_t array of size 2 (64-bit block)
 * @param key - uint32_t array of size 4 (128-bit key)
 */
void encrypt(uint32_t* values, uint32_t* key) {
    // TODO: write this function.
}



/**
 * This function uses a 128-bit key to decrypt a 64-bit block in 32 cycles using TEA
 *
 * @param values - uint32_t array of size 2 (64-bit block)
 * @param key - uint32_t array of size 4 (128-bit key)
 */
void decrypt(uint32_t* values, uint32_t* key) {
    // TODO: write this function.
}



/**
 * This function combines every 4 characters from a char array of size 8 into one 32-bit block
 *
 * @param str - unsigned char array of size 8
 * @param values - uint32_t array of size 2 (64-bit block)
 */
void combine(unsigned char* str, uint32_t* values){
    // TODO: write this function.
}



/**
 * This function splits every 32-bit from the 64-bit block into 4 characters
 *
 * @param values - uint32_t array (64-bit block) to be splitted
 *
 * @return a string contains the equivalent 8 characters that was stored in the 64-bit block
 */
string split(uint32_t* values){
    // TODO: write this function.
    string splitOut = ""

    return splitOut;
}



/**
 * Read 8 characters from the user
 * Read 4 digits key from the user
 *
 * Encrypt the 8 characters (64-bit block) using the 4 digits keys (128-bit block)
 * Display the encrypted message
 *
 * Decrypt the 8 characters (64-bit block) using the 4 digits keys (128-bit block)
 * Display the decrypted message
 */
int main(){
    // TODO: write this function.

}
