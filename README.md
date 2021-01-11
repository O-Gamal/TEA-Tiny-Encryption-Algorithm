# TEA Tiny Encryption Algorithm


Security communication become more important today as a result increasing use of the electronic communication for many daily activities such as internet banking, online shopping.

To establish secure communication, Transmitted data must be encrypted to prevent attacking it using cipher algorithms.

![Cipher](https://user-images.githubusercontent.com/47731377/104136694-650aa000-53a0-11eb-94ed-9901429d97a3.png)

In our project transmitted data, be encrypted and decrypted using One of most efficient and fastest software encryption algorithms ever devised specially for mobile systems which has limited resource yet still concern in speed and area is Tiny Encryption Algorithm (known by its convenient acronym TEA).



### Implement tea in C++ :
* We implemented tea cipher to take input string [64-bit] in high level language to simplify the functionality of cipher.
  So we implemented these five functions :
* Encryption 
* Decryption 
* Combine & Split >> Two helper functions.
* TEA >> Then upgrade this code to work on multiple 64-bit blocks.

----------------------------------------------------------------------------
#### Implement tea in assembly  

### Combine

* This function combines every four characters in one integer. 

* The input is 8 chars so we need array of two integers

![Combine](https://user-images.githubusercontent.com/47731377/104136740-b2870d00-53a0-11eb-9ca1-1dc2c901d140.png)

### Encryption algorithm 
![Encryption](https://user-images.githubusercontent.com/47731377/104136762-cc285480-53a0-11eb-9609-f595af29ff94.png)

### Split
* This function the reverse operation of combine.

* It uses the returned array from encryption or decryption,
every 32-bit integer splitted into 4
chars.

![Split](https://user-images.githubusercontent.com/47731377/104136771-e2361500-53a0-11eb-9d02-daec71d0d59f.png)
### Decryption algorithm 
![Decryption](https://user-images.githubusercontent.com/47731377/104136776-ed894080-53a0-11eb-870a-329aab1efbe7.png)
﻿### UPGRADE CODE TO WORK ON MULTIPLE BIT BLOCKS ####

#### Steps to implement this feature
* Split the input into blocks of 8 chars.
* Iterate on each block to combine and generate 2 integers.
* encrypt these integers.
* split the encrypted integers.
* store the encrypted text in a new string.

***This code works fine with a string of multiples of 8,
other strings must be appended with (0x00)***

### UPGRADE CODE TO BE INTERACTIVE
* Message asks the user if he want to decrypt
  the text or not after printing the encrypted one.
* Message asks the user if he want to encrypt another text.
* 
![Demo](https://user-images.githubusercontent.com/47731377/104136786-f8dc6c00-53a0-11eb-9965-f2bc7f26b13b.gif)


