.386
INCLUDE Irvine32.inc

.data	;Insert ur data here

;----- combine data -----
turn db 8 DUP(0),0 ; char array of size 8
;----- end combine data -----


;----- split data -----
splitOut db 8 DUP(0), 0
;----- end split data -----


;----- encrypt & decrypt data -----
sum dd 0
values dd 2 DUP(0)
v0 dd ?
v1 dd ?
delta dd 9e3779b9h ;constant
key dd 4 DUP(0)
;----- end encrypt & decrypt data -----


;----- TEA data -----
inputLen dd ?
rounds dd 0
teaIn db 1000 DUP(0),0 ;string of size multiples of 8
i dw 0
j db 0
teaOut db 1000 DUP(0),0 
decision db 0
encryptedMsg db "Encrypted text", 0
decryptedMsg db "Decrypted text", 0
printIndex dd 0
;----- end TEA data -----


;----- main data -----
inputMsg db "Enter a string: ",0
inKeyMsg db "**Enter 4 keys**",10,13,0
enterKeyMsg db "Enter Key ",0
colon db ": ",0
msgBoxDecrypt db "Would you like to decrypt?",0
msgBoxRestart db "Would you like to enter another string?",0
msgBoxDecTitle db "Decrypt ?",0
msgBoxResTitle db "Restart ?",0
newSize dd ?
;----- end main data -----


.code	;Inser ur code here



;----------------   Start Main  ----------------
main PROC
	
    START:
        ;cout<<"Enter a String: "
        lea edx, inputMsg 
        call writestring

        ;getline(cin,input)
        lea edx, teaIn 
        mov ecx, 1000
        call readstring

        call StrLength ; eax = teaIn.length()
        mov inputLen, eax ;inputLen = teaIn.length()

        ;handling empty input
        cmp inputLen,0
        je START

        ;remove newline char from the string buffer
        add eax , offset teaIn
        mov BYTE PTR [eax+1], 0 ;[teaIn + inputLen + 1] = 00h

        ;cout<<"Enter a 4 keys: "
        lea edx, inKeyMsg
        call writestring

        ;for(int i = 0 ; i < 4 ; i++) cin>>key[i];
        mov ecx, 4
        lea ebx, key
        mov i, 1
        keyLoop:

            ;cout<<"enter key no#:";
            lea edx, enterKeyMsg
            call writestring

            ;cout<<"#: ";
            movzx eax,i
            call writeDec
            lea edx, colon
            call writestring

            ;cin>>key[i];
            call readDec
            mov [ebx], eax
            add ebx, 4
            inc i

        LOOP keyLoop

        mov decision, 0 ;decision = 0 to set TEA to encrypt
        ;teaOut = TEA(teaIn, key) >> encryption
        call TEA
    
        ;make a msgbox asking would u like to decrypt?
        lea  edx, msgBoxDecrypt
        lea  ebx, msgBoxDecTitle
        call MsgBoxAsk

        ;if yes call decrypt
        ;else 
        ;make a msg box asking would u like to enter another message?
        ;if yes goto the start of main
        ;else goto end main
        cmp eax , IDYES ;eax = 7 if user choose no, eax = 6 if yes /// IDYES = 6
        ja skipDecryption

        mov decision, 1 ;decision = 1 to set TEA to encrypt

        ; teaIn = teaOut //copy teaOut in teaIn
        mov ecx, newSize
        lea ebx, teaOut
        lea edx, teaIn
        copyLoop:
        mov al, [ebx]
        mov [edx], al
        inc edx
        inc ebx
        LOOP copyLoop

        ;teaOut = TEA(teaIn, key) >> decryption
        call TEA

        skipDecryption:
        lea edx, msgBoxRestart
        lea ebx, msgBoxResTitle
        call MsgBoxAsk
        ;if clicked yes goto start
        cmp eax , IDYES

    je START

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
    
    ;calc no of rounds
    call calcRounds
    
    mov i ,0
    cmp rounds , 0
    ;jump if below or equal 
    jbe skipTeaOuterLoop

    ;for(int i = 0 ; i < rounds ; i++)
    teaOuterLoop:
        
        mov j,0
        ;for(int j = 0 ; j < 8 ; j++)
        mov ecx, 8  ; ecx = 8
        turnLoop:

        ;turn[j] = teaIn[i*8 + j];
        mov eax, 0
        mov eax, 8 
        mul i   ;eax = 8 * i
        movzx edx, j
        add eax , edx     ;eax= (8*i + j)

        lea edx, teaIn  ;edx = offset teaIn
        mov eax,[edx + eax]     ;eax = teaIn[i*8 + j]
      
        movzx ebx , j ; ebx = j
        add ebx, offset turn ; ebx = turn[j]

        mov [ebx] , al    ;turn[j] = teaIn[i*8 + j]

        INC j

        LOOP turnLoop
		
		;combine(turn, values);
        call combine

        ;if(decision == 0) encrypt(values, key);
        ;else decrypt(values, key);
        CMP decision, 0
        je encryption
        call decrypt
        jmp endDecision

        encryption:
            call encrypt

        endDecision:

        ;teaOut+=split(values); 
        call split ;return splitOut contains 8 chars
        

        ;teaOut += splitOut
        mov esi, offset splitOut
        mov edi, offset teaOut
        mov eax, 8 
        mul i   ;eax = 8 * i
        add edi, eax
        mov ecx, 8
        cld
        REP MOVSB
        
        INC i
        dec rounds

        cmp rounds, 0
    Jg teaOuterLoop

    skipTeaOuterLoop:

  ;if(decision == 0) cout<<"Encrypted: ";
    ;else cout<<"Decrypted: ";    

    CMP decision, 0
    je printEncrypted
        lea ebx, decryptedMsg
    jmp endPrintDecision

    printEncrypted:
        lea ebx, encryptedMsg

    endPrintDecision:

    lea edx, teaOut
    call msgBox

    ret
TEA ENDP
;----------------    End TEA    ----------------


;-----------------------------------------------
;
; This is helper proc called in TEA proc to calculate number of rounds
; rounds is the number we split string to
;
; Recieves: double word inputLen 
; 
; Returns: double word rounds
;
;---------------- Start calcRounds ----------------

calcRounds PROC

    ;calculating rounds
    ;rounds = inputLen/8;
    mov edx , 0
    mov eax, inputLen
    mov ecx, 8

    div ecx ;eax = quotient , edx = remainder

    mov rounds ,eax ;round = quotient

    ;if(inputLen%8 != 0)
    ; rounds++;
    CMP edx , 0 ; if remainder == 0 dont inc 
    jz noInc
    INC rounds ;else inc

    noInc:
     ; calculate new string size
        mov eax, 8
        mul rounds ;eax = round*8
        mov newSize, eax
        
    ret
    
calcRounds ENDP

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

    ;splitting first 4 chars

    mov eax, [values] 
    mov [splitOut], al ; splitOut[0] = first char in values[0]

    shr eax, 8
    mov [splitOut+1], al ; splitOut[1] = second char in values[0]

    shr eax, 8
    mov [splitOut+2], al ; splitOut[2] = third char in values[0]

    shr eax, 8
    mov [splitOut+3], al ; splitOut[3] = fourth char in values[0]


    ;splitting second 4 chars
    mov eax, [values+4]
    mov [splitOut+4], al ; splitOut[4] = first char in values[1]

    shr eax, 8
    mov [splitOut+5], al ; splitOut[5] = second char in values[1]

    shr eax, 8
    mov [splitOut+6], al ; splitOut[6] = third char in values[1]

    shr eax, 8
    mov [splitOut+7], al ; splitOut[7] = fourth char in values[1]

    ret

split ENDP
;-----------------  End split  -----------------



END main
