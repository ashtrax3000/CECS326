;=====================================================
;=====================================================
;; Example of when  variable1 > variable2
;; Please enter a digit: 2

;; Please enter a second digit: 1

;; 2 is greater than 1
 
;; Example of when  variable1 == variable2
;; Please enter a digit: 1

;; Please enter a second digit: 1
;; 1 is equal to 1

;; Example of when  variable1 < variable2
;; Please enter a digit: 1

;; Please enter a second digit: 2

;; 1 is less than 2
;=====================================================
;=====================================================

null        		equ			0x00
sys_exit		equ			1
sys_read		equ			3
sys_write		equ			4
stdin			equ			0
stdout			equ			1

;============================================
;=== MACRO DEFINITIONS
;============================================

%macro print_char	1
		mov eax, sys_write
		mov ebx, stdout
		mov ecx, %1
		mov edx, 1
		int 0x80
%endmacro

%macro pushRegisters 0
		push eax
		push ebx
		push ecx
		push edx
%endmacro

%macro popRegisters 0
		pop edx
		pop ecx
		pop ebx
		pop eax
%endmacro

;exit0 macro
%macro exit0 0
		mov ebx, 0
		mov eax, sys_exit
		int 0x80
%endmacro

;============================================
;=== END MACRO DEFINITIONS
;============================================


section .data
var1			db		0xff
var2			db		0xff
nextline		db		0x0a, 0x0d
msg_is_greater:		db		' is greater than ', null
msg_is_less		db		' is less than ', null
msg_is_equal		db		' is equal to ', null

msg_prompt1		db		'Please enter a digit: '
len1			equ		$ - msg_prompt1
msg_prompt2		db		'Please enter a second digit: '
len2			equ		$ - msg_prompt2

section .text
		GLOBAL _start
		_start:

			mov eax, sys_write
			mov ebx, stdout
			mov ecx, msg_prompt1
			mov edx, len1
			int 0x80

			;; get the first digit from user
			mov eax, sys_read
			mov ebx, stdin
			mov ecx, var1
			mov edx, 255
			int 0x80

			mov eax, sys_write
			mov ebx, stdout
			mov ecx, msg_prompt2
			mov edx, len2
			int 0x80

			;; get the second digit from user
			mov eax, sys_read
			mov ebx, stdin
			mov ecx, var2
			mov edx, 255
			int 0x80

			print_char var1			; print first digit

			mov	al, [var1]
			cmp	al, byte [var2]
			je	var1_eq_var2
			
			cmp	al, byte [var2]
			jl var1_less_var2
			
			mov edi, msg_is_greater
			call print_string
			jmp end_main
			
		var1_less_var2:
			mov edi, msg_is_less
			call print_string
			jmp end_main

		var1_eq_var2:
			mov edi, msg_is_equal
			call print_string
			jmp end_main
			
		end_main:
			print_char var2			; print second integer
			call print_nextline
			exit0

;============================================
; FUNCTIONS / SUBROUTINES
;============================================

print_nextline:
		pushRegisters
		mov eax, 4
		mov ebx, 1
		mov ecx, nextline
		mov edx, 2
		int 0x80
		popRegisters
		ret

print_string:
		pushRegisters
		mov ecx, edi
  	checknull:
		cmp byte [ecx], null
		jz endstring
	  	print_char ecx
	  	inc ecx
		jmp checknull
	endstring:
		popRegisters
		ret
