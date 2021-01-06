.386
INCLUDE Irvine32.inc

.data	;Insert ur data here



.code	;Inser ur code here



;----------------   Start Main  ----------------
main PROC
    ;TODO: write this proc.
	
    INVOKE ExitProcess, 0	;end the program
main ENDP
;----------------    End Main   ----------------





;-----------------------------------------------
;
; This proc works as a driver for all other procedures to prevent duplicated code
; 
; It Splits the string into multiple blocks of 64-bits to allow TEA to operate on input of any size
; Encrypt or Decrypt every block (depending on a decision bit)
; Display the encrypted text or the decrypted text
; 
; Recieves: a BYTE array (char array) contains user input	   
;
;----------------   Start TEA   ----------------
TEA PROC
    ;TODO: write this proc.
	
    ret
TEA ENDP
;----------------    End TEA    ----------------





;-----------------------------------------------
;
; This proc uses a 128-bit key to encrypt a 64-bit block in 32 cycles using TEA
;
; Recieves: a DWORD array of size 4 (128-bit key)
;		    a DWORD array of size 2 (64-bit block)
;
;---------------- Start encrypt ----------------
encrypt PROC
    ;TODO: write this proc.
	
    ret
encrypt ENDP
;----------------  End encrypt  ----------------





;-----------------------------------------------
;
;
; This proc uses a 128-bit key to decrypt a 64-bit block in 32 cycles using TEA
;
; Recieves: a DWORD array of size 4 (128-bit key)
;		    a DWORD array of size 2 (64-bit block)
;
;---------------- Start decrypt ----------------
decrypt PROC
    ;TODO: write this proc.
	
    ret
decrypt ENDP
;----------------  End decrypt  ----------------





;-----------------------------------------------
;
; This proc combines every 4 characters from a char array of size 8 into one 32-bit block
;
; Recieves: a BYTE array of size 8 (char array)
;          
; Returns: a DWORD array of size 2 (every DWORD contains 4 characters)
;
;---------------- Start combine ----------------
combine PROC
    ;TODO: write this proc.
	
    ret
combine ENDP
;----------------  End combine  ----------------





;-----------------------------------------------
;
;
; This proc splits every 32-bit from a 64-bit block into 4 characters
;
; Recieves: a DWORD array of size 2 (64-bit block)
;
;
; Returns: a BYTE array (char array) contains the equivalent 8 characters that were stored in the 64-bit block
;
;----------------- Start split -----------------
split PROC
    ;TODO: write this proc.
	
    ret
split ENDP
;-----------------  End split  -----------------



END main