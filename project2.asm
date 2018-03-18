TITLE Program2   (project2.asm)

; Author: Jonathan Perry
; CS 271 / Project #2  Date: 4/23/17

; Description: This is a program that displays a certain number of 
; Fibonacci numbers based on input specified by the user who is
; executing the program.

INCLUDE Irvine32.inc
BUFMAX = 128 ; maximum buffer size

.data
sProgramTitle	   BYTE		"Fibonacci Numbers",0
sName			   BYTE		"Programmed by Jonathan Perry",0  
sAskForUserName    BYTE		"What's your name? ", 0
sInput1			   BYTE		"Hello, ",0        ; 
userName		   BYTE		BUFMAX+1 DUP(0)
bufSize			   DWORD	?
sInfoPrompt        BYTE     "Enter the number of Fibonacci terms to be displayed",0dh,0ah
				   BYTE     "Give the number as an integer in the range [1 .. 46].", 0
sAskForFibTerms    BYTE     "How many Fibonacci terms do you want? ", 0
sOutOfRange        BYTE     "Out of range. Enter a number in [1 .. 46]", 0
fibTerms   		   DWORD    ?
i                  DWORD    0
count              DWORD    0
initialFib         DWORD    1
fibNumbers		   DWORD    1
sSpaces			   BYTE     "     ", 0
sResultsCert       BYTE     "Results certified by Jonathan Perry", 0
sGoodBye		   BYTE     "Goodbye, ", 0
sPeriod  		   BYTE     ".", 0

.code
main PROC
	call introduction				; Outputs the program title and the programmer's name
	call userInstructions			; Prompts the user to enter their name and then greets the user by their name.
	call getUserData				; Prompts the user to enter the number of Fibonacci terms to be displayed. 
	call displayFibs                ; Calculates and then displays all of the Fibonacci numbers up to and including the nth term
	call farewell					; Tells the user goodbye and then exits the program
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
	mov edx,OFFSET sName			
	call WriteString				; Displays my name
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

	mov edx, OFFSET userName        ; Display the buffer
	call WriteString                ; Displays the users' name
	call Crlf
userInstructions ENDP
;-----------------------------------------------------
getUserData PROC
; Prompts the user to enter the number of Fibonacci terms
; to be displayed. Restricts the user to only entering 
; an integer between 1 and 46. Validates that the in
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov edx,OFFSET sInfoPrompt
	call WriteString				; Displays information to the user
	call Crlf
	call Crlf

	mov edx,OFFSET sAskForFibTerms
	call WriteString				; Asks the user to enter how many Fibonacci terms they want
	call ReadInt					; Reads the next integer
	mov fibTerms, eax				; Stores the integer

L1:
	cmp fibTerms, 46				; Compares the user input to 46
	jbe L2                          ; Exit loop if user input is <= 46
	mov edx, OFFSET sOutOfRange     
	call writeString                ; Tells the user that they're out of range
	call CrlF
	call Crlf

	mov edx,OFFSET sAskForFibTerms
	call WriteString				; Asks the user to enter how many Fibonacci terms they want

	call ReadInt					; get an integer for the first input
	mov fibTerms, eax				; store the integer
	cmp eax, 46					    ; Compares the user input to 46
	ja L1							; Continue loop if user input is > 46
L2:
	call Crlf
getUserData ENDP
;-----------------------------------------------------
displayFibs PROC
; Calculates and then displays all of the Fibonacci numbers
; up to and including the nth term. The results are displayed
; 5 terms per line with at least 5 space between terms.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------

	mov ecx, fibTerms                ; Conditional part of the for loop
	sub ecx, 1                       ; Initialization part of the for loop
	add ecx, 1                       ; Increments the iterator in the for loop
	mov esi, 0                       ; Secondary iteration to keep count of how many Fibonacci numbers have been displayed
L3:                                  ; Beginning statements of the for loop
	cmp esi, 5                       ; See if 5 Fibonacci numbers have been printed
	je L4
	jne L5
L4:	
	call Crlf 	                     ; Start the next Fibonacci numbers on the next line
	call Crlf 	
	mov esi, 0                       ; Reset counter to 0
L5:
	inc esi							 ; Increment counter
	mov eax, initialFib              ; a = initialFib
    mov ebx, fibNumbers              ; b = fibNumbers
	mov initialFib, ebx              ; a = b

	mov edx, eax                     
	add edx, ebx                     ; sum = a + b

	mov fibNumbers, edx              ; b = sum
	call WriteInt                    ; Displays the newly calculated Fibonacci number
	mov edx, OFFSET sSpaces          
	call WriteString				 ; Places 5 blank spaces between each number
	loop L3                          ; Loops back to beginning of for loop

	
	call Crlf 
	call Crlf
	mov edx, OFFSET sResultsCert
	call WriteString
	call Crlf

displayFibs ENDP
;-----------------------------------------------------
farewell PROC
; Displays a parting message that includes the user's name,
; and then terminates the program.
; Receives: Nothing 
; Returns: Nothing
;-----------------------------------------------------
	mov edx, OFFSET sGoodBye
	call WriteString

	mov edx, OFFSET userName        
	call WriteString

	mov edx, OFFSET sPeriod
	call WriteString
	call Crlf
	call Crlf
	exit
farewell ENDP
END main
