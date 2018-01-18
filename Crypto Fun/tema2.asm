extern puts
extern printf

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0
format: db "Length is: %d",0xa,0

section .text
global main
 
;================================================================
; string_length: 
;       An auxiliary function that computes the length of a 
;       string by counting the number of bytes that are different
;       than the null terminator.
;================================================================  
string_length:
    push ebp
    mov ebp, esp  
    
    push ecx  
    
    mov ecx, [ebp + 8]  
    mov esi, ecx  
repeat:
    cmp byte [esi], 0
    je done_computing
    
    inc esi
    jmp repeat
done_computing:
    sub esi, ecx
    
    ; the length of the string will be returned
    ; using the EAX register 
    mov eax, esi
    
    pop ecx
    
    leave
    ret

;================================================================
; xor_strings: 
;       This function solves TASK 1.
;       The two parameters are the message (encrypted) and the 
;       key.
;       The XOR operation is performed between the message bytes 
;       and the key bytes in order to decrypt the message.
;       The encrypted message is replaced by the decrypted 
;       message then.   
;================================================================
xor_strings:
    push ebp
    mov ebp, esp
    
    push ebx
    push eax
    push edx
    
    ; the address of the message string
    mov eax, [ebp + 8]
    
    ; the address of the key string
    mov ebx, [ebp + 12]  
    
repeat_xor:  
    mov dl, byte [ebx]        
    mov dh, byte [eax]
    
    ; a decrypted byte of the message will be stored in DL
    xor dh, dl
    
    ; replace the encrypted byte with the one that has
    ; been decrypted
    mov byte [eax], dh
    
    inc eax
    inc ebx
    
    cmp byte [eax], 0
    je done_xor
    jmp repeat_xor
    
done_xor:
    pop edx
    pop eax
    pop ebx
    
    leave
    ret

;================================================================
; rolling_xor: 
;       This function solves TASK 2.
;       The parameter is the encrypted message. 
;       In iteration "i + 1", we perform XOR between 
;       the encrypted byte at address 
;       "message + i + 1" and the encrypted one at address 
;       "message + i".
;       Therefore byte at address "message + i + 1" is decrypted. 
;       An auxiliary register (CL) retains encrypted bytes in 
;       order to perform the operations described above.   
;================================================================
rolling_xor:
    push ebp
    mov ebp, esp
    
    push edx
    push ecx
    push eax
    
    ; the address of the encrypted message 
    mov eax, [ebp + 8]
    
    xor cl, cl
    
repeat_rolling_xor:
    mov dh, byte [eax] 
    mov dl, cl
    mov cl, dh 
    xor dh, dl
    
    ; the decrypted byte replaces the encrypted one
    mov byte [eax], dh  
    
    inc eax
    cmp byte [eax], 0
    je done_rolling_xor
    jmp repeat_rolling_xor
    
done_rolling_xor:                                      
    pop eax
    pop ecx
    pop edx                        
    
    leave 
    ret

;================================================================
; xor_hex_strings:
;       This function solves TASK 3.
;       The two parameters are the encrypted message and the key. 
;       The function transforms from hex tobinary bytes of the 
;       message and the key.               
;                              
;       After the successful conversion, XOR is performed between
;       the message and the key.  
;       The operations are performed in the following order:
;       1) create the small nibble of the message byte      
;       2) create the big nibble of the message byte
;       3) using the two nibbles, create the message byte
;       4) create the small nibble of the key byte
;       5) create the big nibble of the key byte           
;       6) create the key byte using it's nibbles
;       7) xor between message and key bytes
;       8) the decrypted byte replaces the encrypted one in the
;          message                  
;================================================================                                                 
xor_hex_strings:
    push ebp
    mov ebp, esp
    
    push ebx
    push edx
    push eax
    push ecx
    
    ; the address of the key
    mov ecx, [ebp + 12]
    
    ; the address of the encrypted message
    mov ebx, [ebp + 8]
    ; ESI will also point to the beginning of the message
    mov esi, ebx
     
repeat_xor_hex:
    xor edx, edx
    xor eax, eax
    
    cmp byte [esi + 1], 0 
    je done_xor_hex
    
    mov dl, byte [esi + 1]
    ; we check if the character to be converted is a digit
    ; or a letter
    cmp dl, '9'
    jle transf_digit_little_nib_msg
    jmp transf_letter_little_nib_msg
    
transf_digit_little_nib_msg:
    ; by substracting the ASCII value of '0', the digit
    ; will be found out
    sub dl, '0'
    jmp big_nibble_msg

transf_letter_little_nib_msg:
    ; by substracting 87 from the ASCII representation,
    ; the hexazecimal value is found out 
    sub dl, 87          

big_nibble_msg:
    mov al, byte [esi]
    cmp al, '9'
    jle transf_digit_big_nib_msg
    jmp transf_letter_big_nib_msg

transf_digit_big_nib_msg:
    sub al, '0'
    jmp create_byte_of_msg

transf_letter_big_nib_msg:
    sub al, 87

create_byte_of_msg:
    shl al, 4
    add al, dl
    ; message byte is now saved on stack
    push ax
   
    xor edx, edx
    xor eax, eax 
    
    cmp byte [ecx + 1], 0
    je done_xor_hex       
    
    mov dl, byte [ecx + 1]
    cmp dl, '9'
    jle transf_digit_little_nib_key
    jmp transf_letter_little_nib_key

transf_digit_little_nib_key:
    sub dl, '0'
    jmp big_nibble_key
transf_letter_little_nib_key:
    sub dl, 87
              
big_nibble_key:
    mov al, byte [ecx]
    cmp al, '9'
    jle transf_digit_big_nib_key
    jmp transf_letter_big_nib_key
    
transf_digit_big_nib_key:
    sub al, '0'
    jmp create_byte_of_key
    
transf_letter_big_nib_key:
    sub al, 87
    
create_byte_of_key:
    shl al, 4
    add al, dl
    
    ; message byte is now saved in dl   
    pop dx
    xor dl, al             
    
    ; replace the encrypted byte with the decrypted one
    mov byte [ebx], dl 
    
    add ecx, 2
    add esi, 2
    inc ebx
    
    cmp byte [esi], 0
    je done_xor_hex
    jmp repeat_xor_hex  

done_xor_hex:
    ; at the end of the string, null terminator will be added  
    mov byte [ebx], 0  
    
    pop ecx
    pop eax
    pop edx
    pop ebx

    leave
    ret

;================================================================
;bruteforce_singlebyte_xor: 
;       This function solves TASK 5.
;       The parameter is the encrypted message. The decryption
;       key will be returned using the EAX register.
;       Initially, we assume the key is 1, and we perform the XOR
;       operation between the encrypted message and the key.
;       The aim is to obtain the decrypted message 'force'. If it
;       is not acheived using the current key, than it is 
;       incremented. 
;       When the right key is found, all the message is 
;       decrypted.                     
;================================================================
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    
    push ecx
    push ebx
    push edx
    
    ; both EAX and EBX point to the encrypted message
    mov eax, [ebp + 8]
    mov ebx, eax
    
    ; the decryption key will be stored in ECX 
    mov ecx, 1
     
check_current_key:
    mov eax, ebx

decrypt_letter:    
    mov dl, byte [eax]

f:
    xor dl, cl
    cmp dl, 'f'
    je o
    jmp test_final_byte 

o:    
    inc eax
    mov dl, byte [eax]
    xor dl, cl
    cmp dl, 'o'
    je r
    jmp test_final_byte

r:
    inc eax
    mov dl, byte [eax]
    xor dl, cl
    cmp dl, 'r'
    je c
    jmp test_final_byte

c: 
    inc eax
    mov dl, byte [eax]
    xor dl, cl
    cmp dl, 'c'
    je e
    jmp test_final_byte         

e:    
    inc eax  
    mov dl, byte [eax]
    xor dl, cl
    cmp dl, 'e'
    je found_decryption_key
    jmp test_final_byte

test_final_byte:
    ; check if the message ends
    inc eax
    cmp byte [eax], 0
    je new_key
    jmp decrypt_letter

new_key:
    ; increment the value of the key    
    inc cl
    cmp cl, 255
    ; making sure overflow is not generated
    je found_decryption_key
    jmp check_current_key

found_decryption_key:
    ; place the value of the key in the EAX register
    mov eax, ecx

finally_decrypt:
    mov dl, byte [ebx]    
    xor dl, cl
    
    ; store the decrypted byte at the proper address
    mov byte [ebx], dl
    
    inc ebx    
    cmp byte [ebx], 0
    je return_from_bruteforce
    jmp finally_decrypt

return_from_bruteforce:                
    pop edx
    pop ebx
    pop ecx
    
    leave
    ret    

;================================================================
;break_substitution: 
;       This function solves TASK 6.
;       The two parameters are the encrypted message and the 
;       substitution table.
;       Every letter (byte) of the encrypted message, is searched
;       in the substitution table.
;       When the match is found, the encrypted letter is replaced
;       by the letter that substitutes it.                         
;================================================================
break_substitution:
    push ebp
    mov ebp, esp
    
    push ebx
    push ecx
    push edx
    push eax
    
    ; the address of the substitution table
    mov eax, [ebp + 12]
    
    ; the address of the encrypted message
    mov ebx, [ebp + 8]
      
repeat_decrypt_substitution:
    ; a byte of the encrypted message
    mov dl, byte [ebx]
    
    ; ECX will be used to iterate through the substitution
    ; table
    xor ecx, ecx
    
search_substitution:
    ; check if the letter is equal with a letter in the
    ; substitution table 
    cmp dl, byte [eax + ecx + 1] 
    
    ; affirmative => substitute the letter  
    je substitute
    
    ; negative => check for other letters in the substitution table
    add ecx, 2
    jmp search_substitution

substitute:
    ; here we perform the substitution after we found 
    ; the right letter
    mov dl, byte [eax + ecx]
    mov byte [ebx], dl    
    
    ; move on to substitute a new letter
    inc ebx
    cmp byte [ebx], 0     
    je done_substitution
    jmp repeat_decrypt_substitution

done_substitution:
    pop eax
    pop edx    
    pop ecx
    pop ebx
    
    leave
    ret

main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
        ; read(fd, ebp-2300, inputlen);
    mov ebx, eax
    mov eax, 3
    lea ecx, [ebp-2300]
    mov edx, [inputlen]
    int 0x80

    ; close(fd);
    mov eax, 6
    int 0x80

    ; all input.dat contents are now in ecx (address on stack)

    ; TASK 1: Simple XOR between two byte streams	        
    push ecx
    call string_length
    add esp, 4
    ; the length of the string is stored in EAX.
    
    ; EBX will also point to the message string
    mov ebx, ecx
       
    add ebx, eax
    inc ebx
    ; EBX points now to the key string
          
    push ebx        
    push ecx
    call xor_strings
    add esp, 8
          
    ; print the first resulting string        
    push ecx
    call puts
    add esp, 4
                                            
    ; TASK 2: Rolling XOR
    push ebx
    call string_length
    add esp, 4
        
    add ebx, eax
    inc ebx
        
    push ebx
    call rolling_xor
    add esp, 4
        
    ; print the second resulting string
    push ebx
    call puts
    add esp, 4

    ; TASK 3: XORing strings represented as hex strings
    push ebx
    call string_length
    add esp, 4
        
    add ebx, eax
    inc ebx
    ; EBX points to the message string
    
    mov edx, ebx
    ; also EDX points to the message string
    
    push ebx
    call string_length
    add esp, 4
        
    add ebx, eax
    inc ebx
        
    ; EBX represents the decryption key and EDX the message
    push ebx
    push edx
    call xor_hex_strings
    add esp, 8
        	
    push ebx
    
    ; print the third string   
    push edx
    call puts
    add esp, 4
	
    pop ebx
    
    ; TASK 4: decoding a base32-encoded string
    push ebx
    call string_length
    add esp, 4
        
    add ebx, eax
    inc ebx
           
    ; print the fourth string
    push ebx
        
    push ebx   
    call puts
    add esp, 4
    
    pop ebx    

    ; TASK 5: Find the single-byte key used in a XOR encoding
    push ebx
    call string_length
    add esp, 4
        
    add ebx, eax
    inc ebx
    ; EBX points to the string to be decrypted
        
    push ebx
    call bruteforce_singlebyte_xor
    add esp, 4

    ; the string address and the key will be preserved by
    ; saving them on stack 
    push eax
    push ebx
    
    ; print the fifth string    
    push ebx
    call puts
    add esp, 4
        
    pop ebx
    pop eax
    
    ; print the value of the key        
    push eax
    push fmtstr
    call printf
    add esp, 8

    ; TASK 6: Break substitution cipher	
    push ebx 
    call string_length
    add esp, 4
    
    add ebx, eax
    inc ebx    
    ; now EBX points to the string to be decrypted
        
    ; place subtitution table on stack
    sub esp, 2
    mov word[esp], 0
    sub esp, 2
    mov word[esp], '.x'
    sub esp, 2
    mov word[esp], ' c'
    sub esp, 2
    mov word[esp], 'zv'
    sub esp, 2
    mov word[esp], 'yz'
    sub esp, 2
    mov word[esp], 'xb'
    sub esp, 2
    mov word[esp], 'wn'
    sub esp, 2
    mov word[esp], 'vj'
    sub esp, 2
    mov word[esp], 'um'
    sub esp, 2
    mov word[esp], 'tk'
    sub esp, 2
    mov word[esp], 'sl'
    sub esp, 2
    mov word[esp], 'rs'
    sub esp, 2
    mov word[esp], 'qa'
    sub esp, 2
    mov word[esp], 'pd'
    sub esp, 2
    mov word[esp], 'og'
    sub esp, 2
    mov word[esp], 'n.'
    sub esp, 2
    mov word[esp], 'mh'
    sub esp, 2
    mov word[esp], 'lf'
    sub esp, 2
    mov word[esp], 'kp'
    sub esp, 2
    mov word[esp], 'jo'
    sub esp, 2
    mov word[esp], 'ii'
    sub esp, 2
    mov word[esp], 'hy'
    sub esp, 2
    mov word[esp], 'gt'
    sub esp, 2
    mov word[esp], 'fu'
    sub esp, 2
    mov word[esp], 'e '
    sub esp, 2
    mov word[esp], 'de'
    sub esp, 2
    mov word[esp], 'cw'
    sub esp, 2
    mov word[esp], 'br'
    sub esp, 2
    mov word[esp], 'aq'
     
    ; retain the address of the substitution table in EAX
    lea eax, [esp]
            
    push eax
    push ebx
    call break_substitution
    add esp, 8
        
    ; make sure the address of the substitution table is not lost
    push eax
               
    ; print final solution
    push ebx
    call puts
    add esp, 4    
        
    pop eax
        
    ; print substitution table
    push eax
    call puts
    add esp, 4
           
    add esp, 58

    xor eax, eax
    leave
    ret