.386
include c:\Irvine\Irvine32.inc
includelib c:\Irvine\irvine32.lib
includelib c:\Irvine\kernel32.lib
includelib \masm32\lib\user32.lib

.data	;Insert ur data here
BUFFER_SIZE = 5000

buffer1 BYTE BUFFER_SIZE DUP(?)
buffer2 BYTE BUFFER_SIZE DUP(?)

inFile1 BYTE "asm_out.txt",0
inFile2 BYTE "c++_out.txt",0

fileHandle1 HANDLE ?
fileHandle2 HANDLE ?

bytesRead1 dd ?
bytesRead2 dd ?

line dd 1

lineError db "There is error in line: ",0
successfulTest db "Test Passed Successfully.",10,13,0
failedTest db "Test Failed.",10,13,0
comparison db "Comparing asm_out.txt to c++_out.txt .....",10,13,0
.code	;Inser ur code here

main PROC

	    mov edx,OFFSET inFile1
        call OpenInputFile
        mov fileHandle1 ,eax ;eax contains file handle
        mov edx, OFFSET buffer1
        mov ecx, BUFFER_SIZE
        call readFromFile

        mov edx,OFFSET inFile2
        call OpenInputFile
        mov fileHandle1 ,eax ;eax contains file handle
        mov edx, OFFSET buffer2
        mov ecx, BUFFER_SIZE
        call readFromFile


        lea edx, buffer2
        call strlength
        mov bytesRead2, eax ;size of buffer1
        lea edx ,comparison
        call writeString
        mov ecx, bytesRead2
        lea edi, buffer1 ;asm file string
        lea esi, buffer2 ;c++ file string
        compareLoop:
            mov dl, [edi]
            mov dh, [esi]
            cmp dh, 10 ; if (dl == '\n' ) line++
            jne comparing
            inc line
            ;compare characters
            comparing:
            cmp dl,dh
            je noError

            lea edx , lineError
            call writestring
            mov eax, line
            call writeDec
            call crlf
            jmp failed

            noError:
            inc edi
            inc esi
        LOOP compareLoop

        lea edx, successfulTest
        call writeString
        call crlf
        jmp close_file

        failed:
            lea edx, failedTest
            call writeString
        
        close_file:
        mov eax , fileHandle1
        call CloseFile

        mov eax , fileHandle2
        call CloseFile

	INVOKE ExitProcess, 0	;end the program

main ENDP

END main