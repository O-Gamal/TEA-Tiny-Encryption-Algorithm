#include<bits/stdc++.h>
using namespace std;

uint32_t inputLen;
uint32_t newSize;
uint32_t rounds;
bool decision;

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
 * It also Splits the string into multiple blocks of 64-bits to allow input of any size
 * Encrypt or Decrypt every block (depending on decision bit)
 * Display the encrypted text or the decrypted text
 *
 *
 * @param str - The user input
 * @param key - uint32_t array of size 4 (128-bit key)
 */
string TEA(string in, uint32_t* key){

    string out = "";
    uint32_t values[2];
    unsigned char turn[9]= "";

    for(uint32_t i = 0 ; i < rounds ; i++)
    {
        for(int j = 0 ; j < 8 ; j++)
        {
            turn[j] = in[i*8 + j];
        }

        combine(turn, values);

        if(decision == 0)
            encrypt(values, key);
        else
            decrypt(values, key);

        out+=split(values);
    }

    cout<<endl;
    if(decision == 0)
    {
        cout<<"Encrypted: ";
    }
    else
        cout<<"Decrypted: ";

    for(uint32_t i = 0 ; i < inputLen ; i++)
    {
        cout<<out[i];
    }
    cout<<endl<<endl;

    return out;
}



/**
 * Read a string of any size from the user
 * Read 4 integer keys from the user
 *
 * Encrypt the whole string using the 4 integer keys
 * Display the encrypted message
 *
 * Ask the user if he wants to decrypt or enter another string?
 *
 * Display the decrypted message
 * or go to the begining of the program again
 */
int main()
{
    while(1)
    {
        string input="";
        decision = 0;
        string encrypted="";
        string decrypted="";
        uint32_t key[4] = {0,0,0,0};
        cin.sync();

        cout<<"Enter a String: ";
        getline(cin,input);

        inputLen = input.length();

        newSize = inputLen;

        cout<<"Enter a 4 digits key: ";
        for(int i = 0 ; i < 4 ; i++)
        {
            cin>>key[i];
        }

        if (inputLen % 8 != 0)
            newSize = inputLen + (8 - inputLen % 8);

        for (uint32_t i = 0; i < newSize - inputLen; ++i)
        {
            char c = 0x0;
            input += c;
        }

        //rounds = how many blocks have been entered by user
        rounds = newSize/8;

        decision = 0;
        encrypted = TEA(input, key);

        cout<<"Enter (1) to Decrypt, or (0) to Enter another sentence: ";
        cin>>decision;

        if(decision)
        {
            decision = 1;
            decrypted = TEA(encrypted, key);
            return 0;
        }
    }
}
