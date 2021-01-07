.386
INCLUDE Irvine32.inc

.data	;Insert ur data here


;----- encrypt & decrypt data -----
sum dd 0
values dd 2 DUP(0)
v0 dd ?
v1 dd ?
delta dd 9e3779b9h ;constant
key dd 4 DUP(0)
;----- end encrypt & decrypt data -----

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

    ;uint32_t sum = 0
    mov sum, 0
    
    ;v0 = values[0]
    mov eax, [values]
    mov v0, eax

    ;v1 = values[1]
    mov eax, [values+4]
    mov v1, eax

    ;for (i = 0; i < 32; i++) 
    ;loop 32 times
    mov ecx, 32

    encryptLoop:

        ;sum += delta;
        mov eax, delta
        add sum ,eax

        ;v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])

        ;v1<<4
        mov eax, v1
        shl eax, 4

        ;(v1 << 4) + key[0])
        add eax, [key] ; eax =(v1 << 4) + key[0])
    
        ;(v1 + sum)
        mov ebx, v1
        add ebx, sum ; ebx = (v1 + sum)

        ;(v1 << 4) + key[0]) ^ (v1 + sum)  >>> eax ^ ebx
        xor eax, ebx ; eax = (v1 << 4) + key[0]) ^ (v1 + sum)

        ;((v1 >> 5) + key[1])
        mov ebx, v1
        shr ebx, 5  ;ebx = (v1 >> 5)
        add ebx, [key+4]    ;ebx =(v1 >> 5) + key[1]

        ;eax = (v1 << 4) + key[0]) ^ (v1 + sum)  
        ;ebx = (v1 >> 5) + key[1]
        xor eax, ebx  ; eax = ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])

        add v0, eax ;v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])


        ;v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);

        ;v0<<4
        mov eax, v0
        shl eax, 4
        ;(v0 << 4) + key[2])
        add eax, [key+8] ; eax =(v0 << 4) + key[2])
    
        ;(v0 + sum)
        mov ebx, v0
        add ebx, sum ; ebx = (v0 + sum)

        ;(v0 << 4) + key[2]) ^ (v0 + sum)  >>> eax ^ ebx
        xor eax, ebx ; eax = (v0 << 4) + key[2]) ^ (v0 + sum)

        ;((v0 >> 5) + key[3])
        mov ebx, v0
        shr ebx, 5  ;ebx = (v0 >> 5)
        add ebx, [key+12]    ;ebx =(v0 >> 5) + key[3]

        ;eax = (v0 << 4) + key[2]) ^ (v0 + sum)  
        ;ebx = (v0 >> 5) + key[3]
        xor eax, ebx  ; eax = ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])

        add v1, eax ;v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])

    loop encryptLoop

    ; values[0] = v0
    mov eax, v0
    mov [values] , eax

    ; values[1] = v1
    mov eax, v1
    mov [values+4] , eax

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
    ;v0 = values[0]
    mov eax, [values]
    mov v0, eax

    ;v1 = values[1]
    mov eax, [values+4]
    mov v1, eax

    ;sum = delta<<5
    mov ebx, delta
    shl ebx, 5
    mov sum, ebx

    ;for (i = 0; i < 32; i++)
    ;loop 32 times
    mov ecx, 32

    encLoop:

        ;v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3]);

        ;v0<<4
        mov eax, v0
        shl eax, 4
        ;(v0 << 4) + key[2])
        add eax, [key+8] ; eax =(v0 << 4) + key[2])
    
        ;(v0 + sum)
        mov ebx, v0
        add ebx, sum ; ebx = (v0 + sum)

        ;(v0 << 4) + key[2]) ^ (v0 + sum)  >>> eax ^ ebx
        xor eax, ebx ; eax = (v0 << 4) + key[2]) ^ (v0 + sum)

        ;((v0 >> 5) + key[3])
        mov ebx, v0
        shr ebx, 5  ;ebx = (v0 >> 5)
        add ebx, [key+12]    ;ebx =(v0 >> 5) + key[3]

        ;eax = (v0 << 4) + key[2]) ^ (v0 + sum)  
        ;ebx = (v0 >> 5) + key[3]
        xor eax, ebx  ; eax = ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])

        sub v1, eax ;v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])


        ;v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1]);

        ;v1<<4
        mov eax, v1
        shl eax, 4
        ;(v1 << 4) + key[0])
        add eax, [key] ; eax =(v1 << 4) + key[0])
    
        ;(v1 + sum)
        mov ebx, v1
        add ebx, sum ; ebx = (v1 + sum)

        ;(v1 << 4) + key[0]) ^ (v1 + sum)  >>> eax ^ ebx
        xor eax, ebx ; eax = (v1 << 4) + key[0]) ^ (v1 + sum)

        ;((v1 >> 5) + key[1])
        mov ebx, v1
        shr ebx, 5  ;ebx = (v1 >> 5)
        add ebx, [key+4]    ;ebx =(v1 >> 5) + key[1]

        ;eax = (v1 << 4) + key[0]) ^ (v1 + sum)  
        ;ebx = (v1 >> 5) + key[1]
        xor eax, ebx  ; eax = ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])

        sub v0, eax ;v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])


        ;sum -= delta;
        mov eax, delta
        sub sum ,eax

    loop encLoop

    ;values[0] = v0
    mov eax, v0
    mov [values] , eax

    ;values[1] = v1
    mov eax, v1
    mov [values+4] , eax

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

    ;v[0] = s[0] | s[1] << 8 | s[2] << 16 | s[3] << 24;
	movzx edx, [turn+0]

	mov eax, 0
	mov al, [turn+1]
	shl eax, 8

	or edx, eax

	mov eax, 0
	mov al, [turn+2]
	shl eax, 16

	or edx, eax

	mov eax, 0
	mov al, [turn+3]
	shl eax, 24

	or edx, eax
	mov [values+0], edx

	;v[1] = s[4] | s[5] << 8 | s[6] << 16 | s[7] << 24;
	movzx edx, [turn+4]

	mov eax, 0
	mov al, [turn+5]
	shl eax, 8

	or edx, eax

	mov eax, 0
	mov al, [turn+6]
	shl eax, 16

	or edx, eax

	mov eax, 0
	mov al, [turn+7]
	shl eax, 24

	or edx, eax
	mov [values+4], edx

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