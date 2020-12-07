;input end with '$' dollar symbol

section .text
   global _start          ;must be declared for linker (gcc)
	
_start:                   ;tell linker entry point
    
	;______________________________________________________________ 
 
	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,len
	int 80h
	
	mov [f],dword 0x2
	mov [n1],dword 5436
	
	call cleario
    call read_int           ;reading int
    mov [n1], eax
    
fagain:
    mov eax,[f]
    call check_prime
    cmp eax,0
    jz incfac
    ;=============================
    
sagain:
    mov eax,[n1]
    mov ebx,[f]
    xor edx,edx
    
    cmp eax,0       ;terminate condition
    jz continue
    
    idiv ebx
    
    cmp edx,0
    jnz incfac
    
    mov [n1],eax
    
    mov eax,ebx
    call write_int
    mov eax,4
	mov ebx,1
	mov ecx,msgp
	mov edx,plen
	int 80h
	
	jmp sagain

    ;===================
incfac:
    mov eax,[f]
    inc eax
    mov [f],eax
    jmp fagain
    
    
continue:
        mov	eax,1		  ;system call number (sys_exit)
        int	0x80		  ;call kernel
        
;________________________________________________________________
    
check_prime:  
    cmp eax,2
    je prime
    
    ;=======================
    
    mov esi,eax
    xor edx,edx
	mov ebx,eax ;ebx = i  eax = n ; i = n-1
	sub ebx,1
again:
	idiv ebx

	cmp edx,0
	jz notprime
	
	xor edx,edx
	mov eax,esi
	dec ebx
	
	cmp ebx,1
	jg again
	
	;=== print if prime
	
	mov eax,esi     ;only taking mod so restoring n
prime:
	mov eax,dword 0x1
	
	jmp end
	
notprime:
	mov eax,esi
	xor eax,eax
	
end:

	ret
	
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
   xor edx,edx
   mul ebx          ; mul eax x ## = edx eax
   
   pop ebx          ;pop new digit
   add eax,ebx      ;add new digit with old ones
   
   mov [i],eax      ; storing into memory
   
   jmp read         ; going to read more  digits
   
next:
	xor eax,eax
    mov eax,[i]
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    xor esi,esi
    mov [i],ebx
    
    ret

;================== printing integer from eax register
write_int:
    xor ecx,ecx
    mov ebx,0xA
    xor esi,esi
    
write:
    xor edx,edx
    idiv ebx
    add edx,0x30
    
    push edx
    inc ecx
    cmp eax,0
    jnz write
    
    mov esi, ecx
    
print:

   ;================ printing from stack
   pop ecx
   mov  [a], ecx 
  
   mov edx,4
   mov	ecx,a         
   mov	ebx,1		
   mov	eax,4		
   int	0x80		
   
   dec esi
   cmp esi,0
   jnz print
   
  
   ret
   
endl:				; endl
    mov [a], dword 0xA
	mov eax, 4
	mov ebx, 1
	mov ecx, a
	mov edx, 1
	
	int 80h
	ret
	
cleario:			;==== clearing register after io use
	xor esi,esi
	xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx, edx
    mov [i], eax
    mov [a], eax
    
    ret

;================================================
section .data
msg DB "please enter any number : "
len equ $-msg

msgnp DB " is not prime",0xA
nplen equ $-msgnp

msgp DB " x "
plen equ $-msgp

section .bss
i resb 4
a resb 4
f resb 4
n1 resb 4
