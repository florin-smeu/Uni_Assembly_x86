%include "io.inc"

section .data
    %include "input.inc"
    incorrect db "Baza incorecta", 0    

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    
    ;Setam contorul ecx la valoarea zero.
    xor ecx, ecx

CONVERT_NEXT_NUMBER:  
    ;Testam daca am convertit toate numerele.
    ;In caz afirmativ, programul se incheie.
    cmp ecx, [nums]
    jz RETURN      
    
    ;Baza in care se doreste sa se converteasca
    ;este depusa in registrul ebx.
    mov ebx, dword [base_array + ecx * 4]
    
    inc ecx
    
    ;Verificam daca baza este una corecta.
    ;In caz negativ, afisam stringul "Baza incorecta". 
    cmp ebx, 2
    jl INCORRECT_BASE
    
    cmp ebx, 16 
    jg INCORRECT_BASE
    
    ;In eax vom plasa numarul de convertit.
    ;Acesta fiind reprezentat pe maximum 32 de biti,
    ;in registrul edx vom regasi valoarea zero
    mov eax, dword [nums_array + (ecx - 1) * 4]
    xor edx, edx
    
    ;Realizam impartirea la baza in care vrem sa convertim.
    ;Restul impartirii il vom depune pe stiva.
    div ebx
    push edx
    
    ;Testam daca deja catul impartirii este zero.
    ;In caz afirmativ, trecem la convertirea numarului urmator.
    cmp eax, 0
    jz RECOVER_CONVERTED_NUMBER

CONVERT_NEXT_DIGIT:
    ;Ne asiguram ca in edx avem doar valoarea zero.
    xor edx, edx
    
    ;Impartim succesiv la valoarea bazei si resturile 
    ;obtinute le salvam pe stiva.
    div ebx        
    
    push edx 
    cmp eax, 0
    jg CONVERT_NEXT_DIGIT

RECOVER_CONVERTED_NUMBER:
    ;Recuperam resturile de pe stiva si afisam valoarea acestora.        
    pop edx
    cmp edx, 9
    jle DIGIT

    add edx, 87
    jmp PRINT_NUMBER
    
DIGIT: 
    add edx, 48    
    
PRINT_NUMBER:    
    PRINT_CHAR edx
    
    cmp esp, ebp
    jl RECOVER_CONVERTED_NUMBER
    
    NEWLINE
    
    ;Trecem la convertirea urmatorului numar, daca acesta exista.
    jmp CONVERT_NEXT_NUMBER
    
INCORRECT_BASE:
    PRINT_STRING incorrect
    NEWLINE
    jmp CONVERT_NEXT_NUMBER

RETURN:
    ;Restauram stiva si returnam valoarea zero.
    mov esp, ebp              
    xor eax, eax
    ret
