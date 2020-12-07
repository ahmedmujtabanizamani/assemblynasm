;This program does calculate only a+b, a-b and b-a
;Negative number does not handled in inputs but answers can be showed negative too. like 3-4 = -1
;The answer is provided between 0-255 of integer because of usage of byte formate
;A+B will shown in unsigned formate 
;A-B and B-A will shown neg numbers between -1 to -128
;Please input the values in 3 significants for each input 
;if you want to input 65, write it as 065 in input, and if 7 write it 007
;sory for incomplete assignment but i tried my best

;It was tested in nasm (linux)

segment .bss
n1 resb 4
n2 resb 4

number1 resb 1
number2 resb 1

sum resb 1
subs resb 1
subs2 resb 1

sign resb 1
sign2 resb 1

result1 resb 3
result2 resb 3
result3 resb 3

segment .data 

   msg1 db "please enter a number "
   len1 equ $- msg1 

   msg2 db "Please enter a second number "
   len2 equ $- msg2 

   msg3 db "A+B   =  "
   len3 equ $- msg3
   
   msg4 db "A-B   =  "
   len4 equ $- msg4
   
   msg5 db "B-A   =  "
   len5 equ $- msg5
   
   endl db 0xA
	
section	.text
   global _start  
	
_start:            

;=====================================prompt 1

	mov ax,4
	mov bx,1
	mov ecx,msg1
	mov dx,len1
	int 80h
	
	;=======================			input 1
	
	mov ax,3
	mov bx,1
	mov ecx,n1
	mov dx,4
	int 80h
	
	;=======================		prompt 2
	
	mov ax,4
	mov bx,1
	mov ecx,msg2
	mov dx,len2
	int 80h
	
	;=======================			input 2
	
	mov ax,3
	mov bx,1
	mov ecx,n2
	mov dx,4
	int 80h
	;===============================    input 1 converting into single input byte from characters
	mov [number1],byte 0
	
	mov ax,0
	mov al,[n1]
	mov bl, 100
	sub al,'0'
	mul bl
	add [number1],ax
	
	mov ax,0
	mov al,[n1+1]
	mov bl, 10
	sub al,'0'
	mul bl
	add [number1],ax
	
	mov al,[n1+2]
	sub al,'0'
	add [number1],al
	
	;===============================    input 2 converting into single input byte from characters
	
	mov [number2],byte 0
	
	mov ax,0
	mov al,[n2]
	mov bl, 100
	sub al,'0'
	mul bl
	add [number2],ax
	
	mov ax,0
	mov al,[n2+1]
	mov bl, 10
	sub al,'0'
	mul bl
	add [number2],ax
	
	mov al,[n2+2]
	sub al,'0'
	add [number2],al
	
	;=============================== performing operations
	mov bx,0
	mov bl,[number1]
	add bl,[number2]
	mov [sum],bl
	
	mov bx,0
	mov bl,[number1]
	sub bl,[number2]
	mov [subs],bl
	
	mov bx,0
	mov bl,[number2]
	sub bl,[number1]
	mov [subs2],bl
	
	;=============================  performing 2's comp: for handling neg: number from substraction A-B
	mov ax,0
	mov [sign],byte ''
	mov al,[subs]
	
	cmp ax,127
	
	jg _tcomp
	jle _cont
	
_tcomp:
	mov [sign],byte '-'
	NOT al
	add al,1
	mov [subs],al
	
_cont:
	
	;=============================  performing 2's comp: for handling neg: number from substraction B-A
	
	mov ax,0
	mov [sign2],byte ''
	mov al,[subs2]
	
	cmp ax,127
	jg _tcomp2
	jle _cont2
	
_tcomp2:
	
	mov [sign2],byte '-'
	NOT al
	add al,1
	mov [subs2],al
	
_cont2:
	mov ax,0
	
	;============================== converting result# 1 back to character form
	
	mov bl,10
	mov al,[sum]
	div bl
	add ah,'0'
	mov [result1+2],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result1+1],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result1],ah
	
	;============================== converting result# 2 back to character form
	mov ax,0
	mov bl,10
	mov al,[subs]
	div bl
	add ah,'0'
	mov [result2+2],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result2+1],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result2],ah
	
	;============================== converting result# 3 back to character form
	
	mov ax,0
	mov bl,10
	mov al,[subs2]
	div bl
	add ah,'0'
	mov [result3+2],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result3+1],ah
	
	mov ah,0
	div bl
	add ah,'0'
	mov [result3],ah
	
	;================================= answer prompt msg A+B
	
	mov ax,4
	mov bx,1
	mov ecx,msg3
	mov dx,len3
	int 80h
	
	;================================ printing answer A+B
	
	mov ax,4
	mov bx,1
	mov ecx,result1
	mov dx,3
	
	int 80h
	
	;=============================== endl newline after result
	
	mov ax,4
	mov bx,1
	mov ecx,endl
	mov dx,1
	int 80h
	
	;================================= answer prompt msg A-B
	
	mov ax,4
	mov bx,1
	mov ecx,msg4
	mov dx,len4
	int 80h
	;================================= printing sign for sub: operation result
	
	mov ax,4
	mov bx,1
	mov ecx,sign
	mov dx,1
	int 80h
	;================================ printing answer A-B
	
	mov ax,4
	mov bx,1
	mov ecx,result2
	mov dx,3
	int 80h
	
	;=============================== endl newline after result
	
	mov ax,4
	mov bx,1
	mov ecx,endl
	mov dx,1
	int 80h
	
	;==
	;================================= answer prompt msg B-A
	
	mov ax,4
	mov bx,1
	mov ecx,msg5
	mov dx,len5
	int 80h
	;================================= printing sign for sub: operation result
	
	mov ax,4
	mov bx,1
	mov ecx,sign2
	mov dx,1
	int 80h
	;================================ printing answer B-A
	
	mov ax,4
	mov bx,1
	mov ecx,result3
	mov dx,3
	int 80h
	
	;=============================== endl newline after result
	
	mov ax,4
	mov bx,1
	mov ecx,endl
	mov dx,1
	int 80h
		
	;===============================  exit program
   mov eax, 1 
   int 0x80
  
