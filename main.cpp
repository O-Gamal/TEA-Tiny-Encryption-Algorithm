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

    uint32_t sum = 0, i, v0 = values[0], v1 = values[1];
    uint32_t delta = 0x9e3779b9;

    for (i = 0; i < 32; i++) {
        sum += delta;
        v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1]);
        v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);
    }
    values[0] = v0; values[1] = v1;

}



/**
 * This function uses a 128-bit key to decrypt a 64-bit block in 32 cycles using TEA
 *
 * @param values - uint32_t array of size 2 (64-bit block)
 * @param key - uint32_t array of size 4 (128-bit key)
 */
void decrypt(uint32_t* values, uint32_t* key) {
    // TODO: write this function.
    
    uint32_t delta = 0x9e3779b9;
    uint32_t v0 = values[0], v1 = values[1], 
    		sum = delta<<5, i;

    for (i = 0; i < 32; i++) {
        v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);
        v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1]);
        sum -= delta;
    }
    
    values[0] = v0; values[1] = v1;

}



/**
 * This function combines every 4 characters from a char array of size 8 into one 32-bit block
 *
 * @param str - unsigned char array of size 8
 * @param values - uint32_t array of size 2 (64-bit block)
 */
void combine(unsigned char* str, uint32_t* values){
    // TODO: write this function.
	values[0] = str[0] | str[1] << 8 | str[2] << 16 | str[3] << 24;
    values[1] = str[4] | str[5] << 8 | str[6] << 16 | str[7] << 24;
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

    string splitOut = "";

	// splitting the first 4 chars from values[0] to splitOut string
    splitOut += (unsigned char)(values[0] & 0xFF);
    splitOut += (unsigned char)(values[0] >> 8);
    splitOut += (unsigned char)(values[0] >> 16);
    splitOut += (unsigned char)(values[0] >> 24);

    // splitting the second 4 chars from values[1] to splitOut string
    splitOut += (unsigned char)(values[1] & 0xFF);
    splitOut += (unsigned char)(values[1] >> 8);
    splitOut += (unsigned char)(values[1] >> 16);
    splitOut += (unsigned char)(values[1] >> 24);

    return splitOut;
}



/**
 * This function works as a driver for all other functions to prevent duplicated code
 *
 * Convert user input (string contains 8 chars) to char array and pass it to combine function
 * Encrypt the 8 characters (64-bit block) using the 4 digits keys (128-bit block)
 * Display the encrypted message
 *
 * Decrypt the 8 characters (64-bit block) again using the 4 digits keys (128-bit block)
 * Display the decrypted message
 *
 * @param str - The user input
 * @param key - uint32_t array of size 4 (128-bit key)
 */
void TEA(string str, uint32_t* key)
{
    uint32_t values[2];
    unsigned char message[9] = "";

    for(int i = 0 ; i < 2 ; i++)
    {
        //converting user input to char array
        for (int i = 0; i < 8; i++) {
            message[i] = str[i];
        }

        combine(message, values);
        i == 0 ? encrypt(values, key) : decrypt(values, key);
        str = split(values);

        i == 0 ? cout<<"Encrypted: " : cout<<"Decrypted: ";
        cout<<str<<endl;
    }
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
	string input= "";
	uint32_t key[4] = {0,0,0,0};

	cout<<"Enter 8 characters: ";
	getline(cin,input);

	cout<<"Enter a 4 digits key: ";
    for(int i = 0 ; i < 4 ; i++)
    {
        cin>>key[i];
    }
    TEA(input, key);

	return 0;
}
