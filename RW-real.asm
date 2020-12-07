section .text
   global _start          ;must be declared for linker (gcc)
    
_start:  


    call read_real
    
    call write_real
    
    call endl
    call write_int

    
    mov eax,1
    int 80h
    
write_real:
    push eax
    push ebx
    push ecx
    push edx
    
    push eax
    
    and eax,dword 0x7FFFFF

    pop ebx
    
    and ebx,dword 0x7F800000        ;extracting raw exponent
    add eax,dword 0x800000          ; adding explicit 1 into mantissa
    push eax        ; mantissa
    push ebx        ; exponent
      ;printing----
    
    ;extracting exponent

    mov eax,dword 2
    mov ebx,dword 23    ;extracting exponent by shifting 23 bits right
    call power              
    
    mov ebx,eax
    
    pop eax         ; extracted exponent biased
    idiv ebx
    
    sub eax,dword 127       ; exponent
    
    call endl
    call write_int
    
    
    mov ebx,dword 23
    sub ebx,eax             ; free bits
    
    mov eax,ebx
    
    call endl
    call write_int          ; last free bits after decimal
    
    mov edx,eax         ;free bits after deci :
 
    mov eax,dword 2
    call power          ;power for shifting before decimal value to integer
 
    mov ebx,eax
    
    pop eax         ; 1 added raw mantissa
    
    push edx        ; free bits after decimal
    
    ;printing----
    ;call endl
    ;call write_int              ; mantissa
    
    mov ecx,eax
    
    mov edx,dword 0
    
    idiv ebx                ; shifter raw mantissa to get int value
    
    push eax  ;  bdeci
    
    mul ebx
 
    ; seperating adeci bits
    mov ebx,eax
    mov eax,ecx
    xor eax,ebx
    ;printing----
    
   
    ; in eax encoded value of after decimal
    
    mov ebx,eax
    
    pop eax             ; before decimal value
     ;printing----
    call endl
    call write_int
    
    pop eax             ; free space after decimal
    
    
    
    ;printing----
    ;call endl
    ;call write_int
    
    ; at that moment in eax free bits after deci and in ebx encoded value of after deci
    ; ebx = value
    ; eax = space
    ; decoding from here after decimal value
    
    ;mov ecx,ebx
    ;mov ebx,eax
    
    ;mov eax,dword 2
    
    ;call power
    
    ;and eax,ecx
    
    ;cmp eax,ecx

    pop edx
    pop ecx
    pop ebx
    pop eax
    
   ret
read_real:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    call read_int
    mov [q],eax
    mov eax,[q]
    
    mov ebx,2
    
    call significant
    
    mov ecx,dword 23
    sub ecx,eax
    push eax        ; pushing bdeci significants
    mov eax,[q]
    
    mov ebx,ecx
    
    call shiftl
    
    sub eax,8388608
    
    push eax
    push ebx        ; (23-QS)
    
    xor eax,eax
    mov ebx,0
    mov ecx,0
    mov edx,0
    call read_int
    mov [q],eax
    mov eax,[q]
    call adeci
    
    pop ecx
    sub ecx,ebx  
    ;push ecx     ; (23-QS-DS)
    mov ebx,ecx
    sub ebx,1       ; adjustment
    
    call shiftl
    
    pop ebx
    add eax,ebx
    
    mov ecx,127  ; biased
    pop ebx         ; exponent
    add ecx,ebx     ; biased exponent
    sub ecx,1       ; adjustment
    push eax
    
    mov eax,ecx
    mov ebx,22
    
    call shiftl
    
    pop ebx
    add eax,ebx     
    
    ; at that moment in eax we have ieee 754 floatpoint representation
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
    ;============================ reading integer and store it into eax
read_int:

    push ebx
    push ecx
    push edx
    push esi
    
    mov    edx,1      
    mov    ecx,a     
    mov    ebx,0      
    mov    eax,3        
    int    0x80        
   
   mov eax,[a]  
   sub eax,'0'
   mov [i],eax
   ;===============check num end
read:  

    mov    edx,1    
    mov    ecx,a   
    mov    ebx,0    
    mov    eax,3    
    int    0x80    
    
   mov eax,[a]
   
   cmp eax,"."     ; read end trigger
   je next
 
   sub eax,'0'      ;extracting digit from char
   
   push eax         ;push new digit to stack
   mov eax,[i]      ;acessing old digits
   
   ;multiply by 10 to inc significant of old digits
   mov ebx,0xA
   mov edx,0
   mul ebx          ; mul eax x ## = edx eax
   
   pop ebx          ;pop new digit
   add eax,ebx      ;add new digit with old ones
   
   mov [i],eax      ; storing into memory
   
   jmp read         ; going to read more  digits
   
next:
    mov eax,0
    mov eax,[i]
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov esi,0
    mov [i],ebx
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    
    ret
 ;========================================
shiftl:
    push ebx
    push ecx
    push edx
    mov ecx,ebx
    mov ebx,dword 2
againmul:
    mov edx,dword 0
    mul ebx
    dec ecx
    cmp ecx,0
    jge againmul
    
    pop edx
    pop ecx
    pop ebx
    ret
    
adeci:      
;after decimal to int and store its significant to ebx and actual value to eax

    push ecx
    push edx
    push esi
    push edi
    
    mov ebx,dword 10
    
    call significant
    mov ebx,eax
    mov eax, dword 10
    
    call power
    
    mov esi,eax
    mov ecx,dword 0
    mov edi, dword 0
   
    
    mov eax,[q]
    mov ebx,dword 2
loop1:
    mov edx,dword 0
    mul ebx
    
    cmp eax,esi
    jge again3
    jmp cont
again3:
    
    sub eax,esi
    or ecx,dword 1

cont:
    cmp eax,0
    jz endp
    push eax
    mov eax,ecx
    mul ebx
    
    mov ecx,eax
    pop eax
    
    inc edi
    cmp edi,23
    je endp
    
    jmp loop1

endp:

    mov eax,ecx
    mov ebx,edi
    
    pop edi
    pop esi
    pop edx
    pop ecx
    
    ret  
power:          
; power accept base in eax, and power in ebx
    push ebx
    push ecx
    push edx
    push esi
    
    mov ecx,ebx
    mov ebx,eax
    mov eax,dword 1
    
again2:
    mov edx,dword 0
    
    mul ebx
    dec ecx
    cmp ecx,0
    
    jnz again2
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    
    ret


significant:
;returns significant of number in eax and also accept number in eax and base in ebx

    push ecx
    push edx
    push esi
    
again1:
    mov edx,dword 0
    idiv ebx
    inc ecx
    
    cmp eax,0
    jne again1
    
    mov eax,ecx
    
    pop esi
    pop edx
    pop ecx
    
    
    ret
    
;================== printing integer from eax register
write_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    mov ecx,dword 0
    mov ebx,dword 0xA
    mov edx,dword 0
    mov esi,dword 0
    
write:
    mov edx,dword 0
    div ebx
    add edx,"0"
    
    push edx
    inc ecx
    cmp eax,0
    jnz write
    
    mov esi, ecx
    
print:

   ;================ printing from stack
   pop ecx
   mov  [a], cl
 
   mov edx,4
   mov    ecx,a         
   mov    ebx,1        
   mov    eax,4        
   int    0x80        
   
   dec esi
   cmp esi,0
   jnz print
   
   mov [a],dword 0
   
   pop esi
   pop edx
   pop ecx
   pop ebx
   pop eax
 
   ret
   
    
endl:
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax,4
    mov ebx,1
    mov ecx,line
    mov edx,len
    int 80h
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret
    
section .data
line DB 0xA,"------------",0xA
len equ $-line

section .bss
i resb 4
q resb 4
e resb 4
a resb 4
