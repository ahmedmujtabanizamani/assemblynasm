;input end with '$' dollar symbol

section .text
   global _start          ;must be declared for linker (gcc)
	
_start:                   ;tell linker entry point
    
;========================================================= reading integer

	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,len
	int 80h
	
    call read_int
    
    mov esi,0
    mov ebx,0x2
again:                   ; n/2  if rem==0 : push 0  else push 1
    mov edx,0
    div ebx
    
    push edx
	
	inc esi
	
	cmp eax,0
	jg again
	
	call endl
	
	mov eax,4
	mov ebx,1
	mov ecx,msgb
	mov edx,lenb
	int 80h
	
printstack:
    
    pop eax
    add eax,"0"
    
    mov [bin], eax
    mov eax,4
	mov ebx,1
	mov ecx,bin
	mov edx,1
	int 80h
	
	dec esi
	cmp esi,0
	jg printstack
	
	call endl
    
	
	
	
   mov	eax,1		  ;system call number (sys_exit)
   int	0x80		  ;call kernel
	
;============================ reading integer and store it into eax
read_int:
    
    mov	edx,1	  
    mov	ecx,a     
    mov	ebx,0	  
    mov	eax,3		
    int	0x80		
   
   mov eax,[a]  
   sub eax,'0'
   mov [i],eax
   ;===============check num end
read:  

    mov	edx,1	
    mov	ecx,a   
    mov	ebx,0	
    mov	eax,3	
    int	0x80	
    
   mov eax,[a] 
   
   cmp eax,"$"     ; read end trigger
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
    
    ret

;================== printing integer from eax register
write_int:
    mov ecx,0
    mov ebx,0xA
    mov edx,0
    mov esi,0
    
write:
    mov edx,0
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
   mov	ecx,a         
   mov	ebx,1		
   mov	eax,4		
   int	0x80		
   
   dec esi
   cmp esi,0
   jnz print
   
   mov ebx,0
   mov ecx,0
   mov edx,0
   mov esi,0
   mov [a],edx
  
   ret
   
endl:				; endl
	mov al, 0xA
    mov [a], al
	mov eax, 4
	mov ebx, 1
	mov ecx, a
	mov edx, 1
	
	int 80h
	ret
	
cleario:			;==== clearing register after io use
	mov esi,0
	mov eax,0
    mov ebx,eax
    mov ecx,ebx
    mov edx, ecx
    mov [i], eax
    mov [a], al
    
    ret

;================================================
section .data

bin DB "0"

msg DB "please enter any number : "
len equ $-msg

msgb DB "binary equavalant is : "
lenb equ $-msgb

section .bss
i resb 4
a resb 1

n1 resb 4
