;; ====================================================
;; ====================================================

;; CONSTANT DEFINITIONS

null      equ   0x00
MAXARGS   equ   2
sys_exit  equ   1
sys_read  equ   3
sys_write equ   4
sys_close equ   6
sys_creat equ   8
stdin     equ   0
;stdout    equ   1
stderr    equ   3

;============= MACRO DEFINITIONS

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

; prints one ascii character to the console
%macro print_char 1
  mov eax, 4
  mov ebx, [fd_out]
  mov ecx, %1         ; address of data to print
  mov edx, 1          ; length of bytes to print
  int 0x80
%endmacro

; exit0 macro
%macro exit0 0
  mov ebx, 0
  mov eax, sys_exit
  int 0x80
%endmacro

;==================  END MACRO DEFINITIONS
;====================================================

;====================================================
;==================  DATA SEGMENT

SECTION     .data

fileName      db  "00000000.txt", 0
fileName_len  equ $ - fileName
hexprefix     db  "0x", null
debugOK       db  "OK", null
newline       db  0x0a, 0x0d

ftoc          db  " to Celcius is ", null
var1          db  0xff
var2          db  0xff
temp          db  0xff
result        db  0xff

; error messages
szErrMsg    db  "Too many arguments. The max number of args is ", null
szLineFeed  db  10
szBErrMsg   db  "Invalid number of hex digits entered.", null
properMsg   db  "Proper 2 digit hex value: 0x4F", null
arg1nullMsg db  "First argument is null.", null
arg2nullMsg db  "Second argument is null.", null

;====================================================
;==================  BSS SEGMENT
section .bss

fd_out      resb  1
fd_in       resb  1
info        resb  50

tmpbyte     resb  1 ;holds byte temporarily for the hex to ascii conversion
tmphexchar  resb  2 ;holds hex version of ascii char to be printed

arg1hex     resb  1 ;holds the hex value of first argument
arg2hex     resb  1 ;holds the hex value of second argument

arg1ascii   resb  5 ;holds the ascii version of first arg (4 char + null)
arg2ascii   resb  5 ;holds the ascii version of second arg (4 char + null)

;====================================================
;==================  TEXT SEGMENT
SECTION     .text
global      _start

_start:      ; Begin main program

    ;; CREATE FILE
    mov eax, sys_creat
    mov ebx, fileName
    mov ecx, 0o611          ; read, write, execute by all
    mov edx, fileName_len
    int 0x80
    mov [fd_out], al        ; filedescriptor is returning in the A

    ;;;;;; Get arguments from the stack
    push    ebp          ; save ebp on stack
    mov     ebp, esp     ; set base pointer to stack pointer


    cmp     dword [ebp + 4], 1    ; check to see if no args were recieved
                                  ; (arg count will always be at least 1)
    je      NoArgs                ; if no args entered (arg count == 0)
                                  ; then go to program exit section

    cmp     dword [ebp + 4], MAXARGS + 1  ; check if total args entered is more than the max
    ja      TooManyArgs

    mov     ebx, 3      ; ebx is index into the argument pointer array
                        ; since ebp was pushed, args pointer array starts @ [ebp + 4*ebx] =

    ; ========================================================
    ;;;;;;;; Get first command line argument
    mov     edi, dword [ebp + 4 * ebx]  ; put pointer address of an arg into edi
    test    edi, edi                  ; test to see if pointer address is null
    jz      arg1Null                  ; exit loop if edi == 0

    call    GetStrLen                 ; string length be returned in EDX register
    mov     ecx, dword[ ebp + 4 * ebx]

    ; EXIT program if invalid length hex value detected in first arg
    cmp edx, 4              ; check for length of string to be 4
    jne invalidHexByte      ; if the legth is incorrect go to show error and exit

    ; put FIRST arg string into arg1ascii and then print to stdout
    mov al, [ecx]
    mov [arg1ascii], al       ; put first characted into arg1ascii
    mov al, [ecx + 1]
    mov [arg1ascii + 1], al   ; put second characted into arg1ascii
    mov al, [ecx + 2]
    mov [arg1ascii + 2], al   ; put third character into arg1ascii
    mov al, [ecx + 3]
    mov [arg1ascii + 3], al   ; put fourth character into arg1ascii

    mov byte [arg1ascii + 4], null ; put null character at end of arg1ascii
    ; ========================================================

    ; ========================================================
    ;;;;;;;; Get SECOND command line argument
    inc     ebx                         ; step arg array index
    mov     edi, dword [ebp + 4 * ebx]  ; put pointer address of an arg into edi
    test    edi, edi                    ; test to see if pointer address is null
    jz      arg2Null                    ; exit loop if edi == 0

    call    GetStrLen                   ; string length be returned in EDX register
    mov     ecx, dword[ ebp + 4 * ebx]  ; put address of 2nd argument into ecx

    ; EXIT program if invalid length hex value detected in second arg
    cmp edx, 4              ; check for length of string to be 4
    jne invalidHexByte      ; if the legth is incorrect go to show error and exit

    ; put first arg string into arg1ascii and then print to stdout
    mov al, [ecx]
    mov [arg2ascii], al       ; put first characted into arg1ascii
    mov al, [ecx + 1]
    mov [arg2ascii + 1], al   ; put second characted into arg1ascii
    mov al, [ecx + 2]
    mov [arg2ascii + 2], al   ; put third character into arg1ascii
    mov al, [ecx + 3]
    mov [arg2ascii + 3], al   ; put fourth character into arg1ascii

    mov byte [arg2ascii + 4], null ; put null character at end of arg1ascii
    ; ========================================================

    ; Convert arg1ascii to raw data
    mov   eax, [arg1ascii]  ; four ascii digits is the 32-bit that will go
                            ; into EAX to be converted
    call  ascii_hex_byte_to_raw; convert the ascii hex quantity to raw data
    mov   [var1], al

    ; Convert arg2ascii to raw data
    mov   eax, [arg2ascii]      ; four ascii digits is the 32-bit that will go
                                ; into EAX to be converted
    call  ascii_hex_byte_to_raw ; convert the ascii hex quantity to raw data
    mov   [var2], al

    ; ============================================================
    ; program expects that var1 will hold a Celcius temp value in hex
    ; the Fahrenheit value will be computed and displayed
    ; C = (F - 32) * 5 / 9

    mov eax, 0      ; re-initialize the A register

    mov al, [var1]  ; put var1 value into al
    mov bh, [var2]

      loop:
        cmp bh, 0
        je loop_exit

        mov edi, var1          ; pass address of var1 for print_hex_byte
        call print_hex_byte

        mov   edi, ftoc       ; print " to celsius is "
        call  print_string

        mov al, [var1]
        add al, -32     ; substract 32 to al
        mov bl, 5       ; set up too multiply al by 5
        mul bl          ; al has been multiplied by 5

        mov bl, 9       ; set up to divide by 9
        div bl          ; al has been divided by 9

        mov [result], al        ; put the Fahrenheit value into result so it can be displayed

        mov al, [var1]          ; put value of var1 into AL
        add al, 5               ; add 5 to AL
        mov [var1], al          ; updating value of var1 to be computed in next loop

        mov edi, result         ; pass address of result for print_hex_byte
        call print_hex_byte
        call print_nl
        dec bh

        jmp loop

      loop_exit:

    exit0                   ; good bye

    ;; =======================================================================

    NoArgs:
      ; No args entered
      ; start program without args here
      jmp arg1Null

    TooManyArgs:
      mov edi, szErrMsg
      call print_string
      call print_nl
      exit0

    invalidHexByte:
      mov edi, szBErrMsg
      call print_string
      call print_nl
      mov edi, properMsg
      call print_string
      call print_nl
      exit0

    arg1Null:
      mov edi, arg1nullMsg
      call print_string
      call print_nl
      exit0

    arg2Null:
      mov edi, arg2nullMsg
      call print_string
      call print_nl



    ;; CLOSE THE FILE
    mov eax, sys_close
    mov ebx, [fd_out]
    int 0x80

      exit0

  ; ============== END OF MAIN



; ==============================================================
; ============== FUNCTION / SUBROUTINES ========================

; print new line
; returns - nothing
print_nl:
  pushRegisters
  mov eax, sys_write
  mov ebx, [fd_out]
  mov ecx, newline    ; address of data to print
  mov edx, 2          ; number of bytes to print
  int 0x80
  popRegisters
  ret

; print hexadecimal prefix character "0x"
; uses - eax, ebx, ecx, EDX
; returns - nothing
print_0x:
  pushRegisters
  mov eax, sys_write
  mov ebx, [fd_out]
  mov ecx, hexprefix  ; address of data to print
  mov edx, 2          ; number of bytes to print
  int 0x80
  popRegisters
  ret

; print string
; recieves - address of C-Style string in register EDI
; C-Style means null terminated
; uses - eax, ebx, ecx, edx
; return - nothing

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

; print byte of data
; recieves - address of a data byte in register EDI
; uses - eax, ebx, ecx, edx, tmpbyte, tmphexchar
; returns - nothing

print_hex_byte:

  pushRegisters
  ;;
  call print_0x         ; print hex prefix
  mov al, [edi]         ; get hex byte to be printed
  mov [tmpbyte], al         ; put hex byte into tempbyte variable
  and byte [tmpbyte], 0x0f  ; isolate lower hex digit in bl
  shr al, 4                 ; shift right upper hex digit in al

  mov ah, al                ; pass upper hex digit to hex_char_to_ascii
  call hex_char_to_ascii    ; convert upper hex digit to ascii
  mov [tmphexchar], ah
  print_char tmphexchar

  mov ah, [tmpbyte]         ; pass lower hex digit to hex_char_to_ascii
  call hex_char_to_ascii    ; convert lower hex digit to ascii
  mov [tmphexchar], ah
  print_char tmphexchar
  ;;
  popRegisters
  ret

;; =======================================================================
;; ============== Fx(s) for generating command line parameters ==============
;; =======================================================================

; convert one hex character to ascii
; recieves - hex value in register ah
; uses     - AH register
; returns  - ascii encoded hex char in ah regsiter
hex_char_to_ascii:
    cmp ah, 10
    jl hexlessthan10    ; check if hex digit is A - F
    add ah, 0x07        ; adjust value for hex digit A - F
  hexlessthan10:
    add ah, 0x30        ; add ascii encoding
    ret


; convert one hex byte in ascii to a raw data byte
; recieves - ascii encoded hex value with 0x prefix in register AX
; uses     - AH register
; returns  - raw data hex value in AL register

ascii_hex_byte_to_raw:
    ror eax, 16
    cmp al, '9'       ; see if hex character is '9' or less
    jle lowCharLT9
    sub al, 7         ; offset the ascii value if it is A - F
  lowCharLT9:
    and al, 0x0f      ; remove ascii encoding
    cmp ah, '9'       ; see if hex character is '9' or less
    jle highCharLT9
    sub ah, 7
  highCharLT9:
    and ah, 0x0f      ; remove ascii encoding
    shl al, 4         ; shift left
    add al, ah
    ret


; get length of a C-Style string from command line argument passed in stack
; recieves - address of string in edi register
; uses     - eax, ecx register
; returns  - address of the string into edx register

GetStrLen:
  push  ebx         ; put ebx register data on the stack
  xor   ecx, ecx    ; clear ecx register
  not   ecx         ; set ecx = 0xffffffff. ECX will be decremented
                    ; by repne as non-null characters are counted
                    ;
                    ;
  xor   eax, eax    ; clear eax register, AL will be used by scasb to search for null
  cld               ; clear direction flag, index register are incremented
  repne scasb       ; search for 0 in string; if not found edi++, ecx--, and
                    ; check next character
                    ; scasb: compares AL and [ES:EDI], EDI += 1
                    ; repne: repeat instruction while string char not null (string char != AL)

  mov   byte [edi - 1], 0x0a  ; append newline character in place of null
  not   ecx                   ; 1's complement ecx, it will now contain address of an arg
  pop   ebx                   ; restore ebx value from stack
  lea   edx, [ecx - 1]        ; put address of the string into edx register
  ret


; ===========================================================================================
; ===========================================================================================
