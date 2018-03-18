TITLE Program1   (project1.asm)

; Author: Jonathan Perry
; CS 271 / Project #1  Date: 4/12/17

; Description: This is an introductory MASM assembly language programming assignment
; which asks the user to enter 2 integers to calculate and display the sum, difference,
; product, quotient, and remainder from those 2 integers. The program checks that the
; second number entered is less than the first number entered, and the program also allows
; the user to restart the program.

INCLUDE Irvine32.inc

.data
sProgramTitle   BYTE	"	Elementary Arithmetic",0
sName		    BYTE	"	by Jonathan Perry",0        ;
sExtraCredit    BYTE    "**EC: Program verifies second number less than first.",13,10
				BYTE    "**EC: Program repeats until user chooses to quit.",0
sAskForInput    BYTE	"Enter 2 numbers, and I'll show you the sum, difference,",0dh,0ah
			    BYTE    "product, quotient, and remainder.",0
sContinue		BYTE    "Do you want to try again?",13,10 ; asci codes for CrLf 
				BYTE    "Enter 1 to go again:",13,10 ; asci codes for CrLf 
				BYTE    "    Enter 0 to quit: ",0
continueProg	DWORD   ?
sInput1		    BYTE	"First number: ",0        ;
userInput1	    DWORD   ?
sInput2		    BYTE	"Second number: ",0        ;
userInput2	    DWORD   ?
sInvalidInput   BYTE    "The second number must be less than the first!",0
sAddition       BYTE	" + ",0
AddResult       DWORD   0
sSubtraction    BYTE	" - ",0
SubResult       DWORD   0
sMultiplication BYTE	" x ",0
MultResult      DWORD    0
sDivide			BYTE    " / ",0
quotient		DWORD   0
sRemainder		BYTE    " remainder ",0
quotXdivisor	DWORD   0         ; quotient TIMES divisor
ModResult		DWORD   0
sEqual          BYTE    " = ",0
sGoodBye        BYTE    "Impressed? Bye!", 0

.code
main PROC
	call ProgramIntroduction		; Display program description
	call GetUserInput				; Input the two integers
	call DisplayResults				; Displays each expression and their values
	call GoodBye					; Allows user to exit or restart the program
main ENDP

;-----------------------------------------------------
ProgramIntroduction PROC
; Displays the program's title, my name, and information
; regarding extra credit completed.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	 mov    eax,1
   mov    ebx,4
label6:
   mul    ebx
   call   WriteDec
   call   CrLf
   inc    ebx
   cmp    eax,40
   jbe    label6
   mov    eax,ebx
   call   WriteDec
   call   CrLf
ProgramIntroduction ENDP

;-----------------------------------------------------
GetUserInput PROC
; Asks the user for two integers and then stores them.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov edx,OFFSET sAskForInput
	call WriteString				; Displays instructions to enter input
	call CrLf
	call CrLf

	mov edx,OFFSET sInput1			
	call WriteString				; Displays 'First Number: '
	call ReadInt					; get an integer for the first input
	mov UserInput1, eax				; store the integer
	
	mov edx,OFFSET sInput2 
	call WriteString				; Displays 'Second Number: '
	call ReadInt					; get an integer for the second input
	mov UserInput2, eax				; store the integer
	call CrLf
GetUserInput ENDP
;-----------------------------------------------------
DisplayResults PROC
; Displays the first user input, an operator such as 
; addition, subtraction, multiplication, and division
; to form an expression and then calculates and displays
; the value of each expression.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov ebx,UserInput1
	cmp eax, ebx
	ja L1                           ; jump when UserInput2 > UserInput1
	jb L2	                        ; jump when UserInput1 > UserInput2
L1:									; UserInput2 > UserInput1
	mov edx,OFFSET sInvalidInput    ; 2nd # entered cannot be > 1st # entered
	call WriteString				 
	call CrLf
	call CrLf
	call GoodBye					; Allows user to exit or restart the program 
L2:									; UserInput1 > UserInput2
;Addition Result
 ;Expression
	mov eax, UserInput1
	call WriteDec					; Displays first integer entered
	mov edx,OFFSET sAddition
	call WriteString				; Displays '+'
	mov eax, UserInput2
	call WriteDec					; Displays second integer entered
	mov edx,OFFSET sEqual
	call WriteString				; Displays '='
 ;Value
	mov eax, UserInput1
	add eax, UserInput2				; Adds both integers to obtain the sum
	mov AddResult, eax				; Stores sum in AddResult
	mov edx,OFFSET AddResult         
	call WriteDec					; Displays the sum
	call CrLf

;Subtraction Result
 ;Expression
	mov eax, UserInput1				; Displays first integer entered
	call WriteDec
	mov edx,OFFSET sSubtraction
	call WriteString				; Displays '-'
	mov eax, UserInput2
	call WriteDec					; Displays second integer entered
	mov edx,OFFSET sEqual
	call WriteString				; Displays '='
 ;Value
	mov eax, UserInput1
	sub eax, UserInput2				; Subtracts UserInput2 from UserInput2
	mov SubResult, eax              ; Stores result in SubResult
	mov edx,OFFSET SubResult
	call WriteDec					; Displays result of subtraction
	call CrLf

;Multiplication Result
 ;Expression
	mov eax, UserInput1				; Displays first integer entered
	call WriteDec
	mov edx,OFFSET sMultiplication
	call WriteString				; Display 'x'
	mov eax, UserInput2
	call WriteDec					; Displays second integer entered
	mov edx,OFFSET sEqual
	call WriteString				; Displays '='
 ;Value
	mov eax, UserInput1
	mov ebx, UserInput2
	mul ebx							; Multiplies UserInput1 and UserInput2
	mov MultResult, eax             ; Stores the product of UserInput1 and UserInput2
	mov edx,OFFSET MultResult
	call WriteDec					; Displays the value of the product
	call CrLf

;Quotient Result
 ;Expression
	mov eax, UserInput1
	call WriteDec					; Displays first integer entered
	mov edx,OFFSET sDivide	
	call WriteString				; Displays '\'
	mov eax, UserInput2
	call WriteDec					; Displays second integer entered
	mov edx,OFFSET sEqual
	call WriteString				; Displays '='
 ;Value
	xor edx, edx
	mov eax, UserInput1
	mov ecx, UserInput2
	div ecx                         ; Divides UserInput1 by UserInput2
	mov quotient, ecx				; Stores how many times ecx goes into eax
	call WriteDec                   ; Displays the quotient
	mov edx,OFFSET sRemainder       
	call WriteString				; Displays 'remainder'

;Remainder Result
	mul ecx						    ; Calculates quotient * divisor
	mov quotXdivisor, eax			; Stores the product of quotient * divisor

	mov eax, UserInput1
	sub eax, quotXdivisor           ; Subtracts UserInput1 by the quotient * divisor for the remainder
	mov ModResult, eax              ; Stores the value of the remainder
	call WriteDec					; Displays the value of the remainder
	call CrLf
	call CrLf
DisplayResults ENDP
;-----------------------------------------------------
GoodBye PROC
; Asks the user if they want to restart or quit the
; program.
; Receives: nothin
; Returns: nothing
;-----------------------------------------------------
	mov edx, OFFSET sGoodBye        
	call WriteString				; Displays final message
	call CrLf
	call CrLf
	mov edx, OFFSET sContinue
	call WriteString				; Asks the user to restart or quit the program
	call ReadInt					; Reads their input
	mov continueProg, eax           ; Stores their input
	cmp continueProg, 0             ; Compares input to 0
	jnz L3                          ; Jumps to L3 if user entered 1 to restart
	jz L4                           ; Jumps to L4 if user entered 0 to quit
L3:									; User Input = 1, restarting program
	call Clrscr                     ; Clear the console screen
	call ProgramIntroduction		; Display program description
	call GetUserInput				; Input the two integers
	call DisplayResults				; Displays each expression and their values
	call GoodBye					; Allows user to exit or restart the program
L4:									; User Input = 0, exiting program
	exit
GoodBye ENDP
END main
