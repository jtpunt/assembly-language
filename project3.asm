TITLE Program2   (project2.asm)

; Author: Jonathan Perry
; CS 271 / Project #2  Date: 5/07/17

; Description: This is a program that prompts the user to enter their name and then greets them by their name.
; Then, the program continually prompts the user to enter numbers between -1 and -100, until they enter in a number
; outside of that range. Lastly, the program displays the sum and average of those numbers to user entered before
; exiting the program.

INCLUDE Irvine32.inc
BUFMAX = 128 ; maximum buffer size

.data
sProgramTitle	   BYTE		"Welcome to the Integer Accumulator by Jonathan Perry",0
sExtraCredit	   BYTE     "**EC: Program numbers the lines during user input",0
sAskForUserName    BYTE		"What is your name? ", 0
sInput1			   BYTE		"Hello, ",0        ; 
userName		   BYTE		BUFMAX+1 DUP(0)
bufSize			   DWORD	?
sInfoPrompt        BYTE     "Please enter numbers in [-100, -1].",0dh,0ah
				   BYTE     "Enter a non-negative number when you are finished to see results.", 0
sEnterNumbers      BYTE     "Enter Number: ", 0
sNumbersEntered    BYTE     "You entered ", 0
sValidNumbers      BYTE     " valid numbers.", 0
sSumInfo		   BYTE     "The sum of your valid numbers is ", 0
sAvgInfo		   BYTE     "The rounded average is ", 0
sum       		   DWORD    0
quotient      	   DWORD    0
i                  DWORD    0
sThankPlayer       BYTE     "Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ", 0
sPeriod  		   BYTE     ".", 0

.code
main PROC
	call introduction				; Outputs the program title and the programmer's name
	call userInstructions			; Prompts the user to enter their name and then greets the user by their name.
	call getUserData				; Prompts the user to enter numbers
	call showComposites             ; Calculates the sum and average of all integers entered
	call farewell					; Tells the user goodbye and then exits the program
	invoke exitProcess, 0
main ENDP
;-----------------------------------------------------
introduction PROC
; Outputs the program title and the programmer's name.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------
	pushad							; Save 32-bit registers
	mov edx,OFFSET sProgramTitle	
	call WriteString				; Displays program's title
	call CrLf

	mov edx,OFFSET sExtraCredit
	call WriteString				; Displays extra-credit details
	call CrLf
	call CrLf
introduction ENDP
;-----------------------------------------------------
userInstructions PROC
; Prompts the user to enter their name and then greets
; the user by their name.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------
	mov edx,OFFSET sAskForUserName
	call WriteString				; Asks the user to enter their name

	mov ecx,BUFMAX					; maximum character count
	mov edx,OFFSET userName			; point to the buffer
	call ReadString					; input the string
	mov bufSize,eax					; save the length

	mov edx,OFFSET sInput1
	call WriteString				; Displays "Hello, "

	mov edx, OFFSET userName        ; Displays what's in the buffer
	call WriteString                ; Displays the users' name
	call Crlf
	call Crlf
userInstructions ENDP
;-----------------------------------------------------
getUserData PROC
; Continually prompts the user to enter numbers between -1 and -100, until they enter in a number
; outside of that range. Each time a valid number is entered, the variable i is incremented by 1
; (to keep count of valid numbers entered) and the valid number is added on to sum.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov edx,OFFSET sInfoPrompt
	call WriteString				; Displays information to the user
	call Crlf
L1:
	mov eax, i						
	add eax, 1						; i starts at 0 in the beginning, so we want to display i + 1
	call WriteInt				    ; Numbers the line during user input

	mov edx, OFFSET sPeriod  
	call writeString                ; Displays a period

	mov edx, OFFSET sEnterNumbers    
	call writeString                ; Prompts the user to enter a number
	call ReadInt					; Read in the next integer entered
	cmp eax, -1				        ; See if the number entered is > -1
	jg L3							; Jump to L3 if the number entered is > -1

	cmp eax, -100				    ; See if the number entered is < -100
	jl L3                           ; Jump to L3 if the number entered is <-100
	jge L2                          ; Jump to L2 to add the input to the sum if the number entered is >=-100
L2:
	inc i							; Increment i to keep count of each iteration through the loop
    add sum, eax					; sum += integer entered
	jmp L1

L3:
	cmp i, 0                        ; See if there are 0 iterations through the loop
	je L4							; Jump to L4 if there have been 0 iterations 
									; - meaning, the user entered an number >-1 and <-100
									; at the beginning, and sum is still 0.
	mov edx, 0						; Clear the dividend
	mov eax, sum					; Move the dividend to eax
	cdq								; Extends AX into DX
	mov ebx, i						; Mov the divisor to ebx
	idiv ebx
	mov quotient, eax	            ; Save the quotient
L4:									; exit the loop
	
getUserData ENDP
;-----------------------------------------------------
displayResults PROC
; Calculates and then displays all of the Fibonacci numbers
; up to and including the nth term. The results are displayed
; 5 terms per line with at least 5 space between terms.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------
	mov edx, OFFSET sNumbersEntered
	call WriteString                ; Displays 'You entered'

	mov eax, i					    
	call WriteInt                   ; Displays how many numbers between -1 and -100 have been entered

	mov edx, OFFSET sValidNumbers
	call WriteString				; Displays ' valid numbers.'
	call Crlf

	mov edx, OFFSET sSumInfo
	call WriteString				; Displays information to the user

	mov eax, sum
	call WriteInt			; Displays information to the user
	call Crlf

	mov edx, OFFSET sAvgInfo
	call WriteString				; Displays 'The sum of your valid numbers is'

	mov eax, quotient
	call WriteInt       			; Displays the quotient

	mov edx, OFFSET sPeriod
	call WriteString				; Displays '.'
	call Crlf
displayResults ENDP
;-----------------------------------------------------
farewell PROC
; Displays a parting message that includes the user's name,
; and then terminates the program.
; Receives: Nothing 
; Returns: Nothing
;-----------------------------------------------------
	mov edx,OFFSET sThankPlayer
	call WriteString				; Displays "Hello, "

	mov edx, OFFSET userName        ; Display the buffer
	call WriteString                ; Displays the users' name

	mov edx, OFFSET sPeriod
	call WriteString				; Displays information to the user
	call Crlf
	call Crlf
	exit
farewell ENDP
END main
