.386
include c:\Irvine\Irvine32.inc
includelib c:\Irvine\irvine32.lib
includelib c:\Irvine\kernel32.lib
includelib \masm32\lib\user32.lib

.data	;Insert ur data here

;----- combine data -----
turn db 8 DUP(0),0 ; char array of size 8
;----- end combine data -----

;----- encrypt & decrypt data -----
sum dd 0
values dd 2 DUP(0)
v0 dd ?
v1 dd ?
delta dd 9e3779b9h ;constant
key dd 4 DUP(0)
;----- end encrypt & decrypt data -----

;----- split data -----
splitOut db 8 DUP(0), 0
;----- end split data -----

;----- TEA data -----
printString db 5000 DUP(0),0
teaIn db 5000 DUP(0),0 ;string of size multiples of 8
teaOut db 5000 DUP(0),0 
inputLen dd ?
rounds dd 0
decision db 0
encryptedMsg db "Encrypted text", 0
decryptedMsg db "Decrypted text", 0
printIndex dd 0
i dw 0
j db 0
;----- end TEA data -----

;----- main data -----
inputMsg db "Enter your text: ",0
inKeyMsg db "**Enter 4 keys**",10,13,0
enterKeyMsg db "Enter Key ",0
colon db ": ",0
msgBoxDecrypt db "Would you like to decrypt?",0
msgBoxRestart db "Would you like to enter another text?",0
msgBoxDecTitle db "Decrypt ?",0
msgBoxResTitle db "Restart ?",0
newSize dd ?
;----- end main data -----

;----- handleKey data -----
keyStr db 200 DUP(0)
validKey dd ?
invalidInputMsg db "Invalid Input, Try another key: ",0
;----- end handleKey data -----

;------- testing data -------
BUFFER_SIZE = 5000
buffer BYTE BUFFER_SIZE DUP(?)
inFilename BYTE "test_cases.txt",0
outFilename BYTE "asm_out.txt",0
inFileHandle HANDLE ?
outFileHandle HANDLE ?
bytesRead DWORD ?
croppedIndex dd 0
startIndex dd 0
endIndex dd 0
diff dd 0
newLineStr db 13,10,0
outputWritten db "Output Written Successfully to: ",0
testLength db "Test Case length: ",0
;-------- end testing data -----
.code	;Inser ur code here

main PROC
	    mov edx,OFFSET inFilename
        call OpenInputFile
        mov inFileHandle,eax ;eax contains file handle
        
        mov edx, OFFSET buffer
        mov ecx, BUFFER_SIZE
        call readFromFile
        mov teaIn[eax],0 
        mov bytesRead, eax
        ;call WriteDec                                ; display file size
        ;call Crlf
        ;mov edx,OFFSET buffer    ; display the buffer
        ;call WriteString
        ;call Crlf

        mov edx,OFFSET outFilename
        call createOutputFile
        mov outFileHandle,eax ;eax contains file handle


    START:
            mov ebx, startIndex
            mov endIndex, ebx
            lea eax, buffer
            add eax,startIndex
            
        croppingLoop:
            mov bl , [eax]
            cmp bl, 10
            je exitLoop
            inc endIndex
            inc eax
        LOOP croppingLoop




        exitLoop:
        dec endIndex
        mov esi, offset buffer
        mov edi, offset teaIn
        add esi, startIndex
        mov ecx, endIndex
        sub ecx, startIndex
        cld
        REP MOVSB
        
        mov edx , endIndex
        add edx, 2
        ;inc edx
        mov startIndex, edx 

        ;cout<<"Enter a String: "
        ;lea edx, inputMsg 
        ;call writestring

        ;getline(cin,input)
        ;lea edx, teaIn 
        ;mov ecx, 5000
        ;call readstring
        lea edx, testLength
        call writeString
        lea edx ,teaIn
        ;call crlf
        ;call writestring
        ;call crlf
        call StrLength ; eax = teaIn.length()
        mov inputLen, eax ;inputLen = teaIn.length()
        call writeDec
        call crlf



        ;remove newline char from the string buffer
        add eax , offset teaIn 
        mov BYTE PTR [eax+1], 0 ;[teaIn + inputLen + 1] = 00h

        

        ;for(int i = 0 ; i < 4 ; i++) cin>>key[i];
       
        mov decision, 0 ;decision = 0 to set TEA to encrypt
        ;teaOut = TEA(teaIn, key) >> encryption
        call TEA


        mov decision, 1 ;decision = 1 to set TEA to encrypt
        ; teaIn = teaOut //copy teaOut in teaIn

        
        mov ecx, newSize
        lea ebx, teaOut
        lea edx, teaIn
        copyLoop: ; copy teaOut into teaIn
        mov al, [ebx]
        mov [edx], al
        inc edx
        inc ebx
        LOOP copyLoop
 
        ;teaOut = TEA(teaIn, key) >> decryption
        call TEA

        mov ebx, bytesRead
        cmp startIndex, ebx
        jb START

        close_file:
        mov eax,inFileHandle
        call CloseFile
        mov eax,outFileHandle
        call CloseFile
        lea edx, outputWritten
        call writestring
        lea edx, outFilename
        call writestring
        call crlf
	INVOKE ExitProcess, 0	;end the program

main ENDP





TEA PROC

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
 
    mov ecx, inputLen
    lea ebx, teaOut
    lea edx, printString
    
    copyTeaOut:

        mov al, [ebx]
        ;if (char == '\0') replace with ' ' // to allow msgBox to display the string correctly
        cmp al, 0
        jne putChar
        mov al, ' '

        putChar:
            mov [edx], al

        inc ebx
        inc edx
       
    LOOP copyTeaOut
        mov BYTE PTR [edx], 0

    ;erase everything in teaIn (user input)
    mov ecx , newSize
    lea ebx, teaIn
    eraseTeaIn:
        mov BYTE PTR [ebx], 0 
        inc ebx
    LOOP eraseTeaIn

    CMP decision, 0
    je printEncrypted
        lea ebx, decryptedMsg
    jmp endPrintDecision

    printEncrypted:
        lea ebx, encryptedMsg

    endPrintDecision:
    
    ;display encrypted or decrypted text in msg box
    ;lea edx, printString
    ;call writestring
    ;call crlf

    lea edx, printString
    call strlength
    mov ecx, eax
    mov eax,outFileHandle
    call WriteToFile

    lea edx, newLineStr
    call strlength
    mov ecx, eax
    mov eax,outFileHandle
    call WriteToFile

    ret
TEA ENDP



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



;combine function takes 8 cahrs and combine them into 2 double words variables
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



; encrypt function
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



split PROC

    ;splitOut[0] = first char in values[0] ;splitOut[1] = second char in values[0]
    ;splitOut[2] = third char in values[0] ;splitOut[3] = fourth char in values[0]
    ;-----------------------------------------------------------------------------
    ;splitOut[4] = first char in values[1] ;splitOut[5] = second char in values[1]
    ;splitOut[6] = third char in values[1] ;splitOut[7] = fourth char in values[1]

    ;splitting first 4 chars
    mov eax, values[0]

    lea ebx, splitOut ; ebx = offset splitOut
    mov ecx, 2 ;counter of outerloop
    splitOuterLoop:
        
        mov edx, ecx ;storing the counter of outerloop in edx

        mov ecx, 2 ;setting counter of inner loop
        splitInnerLoop:

                mov [ebx], al
                inc ebx

                mov [ebx], ah
                inc ebx

                shr eax, 16

        LOOP splitInnerLoop

        ;splitting second 4 chars
        mov eax, values[4]

        mov ecx, edx ;putting the counter of outer loop back in ecx
  LOOP splitOuterLoop

    ret

split ENDP



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


END main