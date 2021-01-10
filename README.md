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
