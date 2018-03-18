TITLE Program6   (project6.asm)

; Author: Jonathan Perry
; CS 271 / Project #6B  Date: 6/11/17

; Description: This is a program that asks the user to calculate the
; number of combinations of r items taken from a set of n items. The 
; program generates a random problem for the user with n falling between
; 3 and 12, and r between 1 and n. Once the problem is generated and
; displayed onto the screen, the number of combinations is calculated 
; and then the user is asked to enter in their answer. Finally, the 
; program compares the user's answer to the actual answer and reports
; whether or not the student got the answer correct/incorrect and what
; the actual answer was.

INCLUDE Irvine32.inc

.data
n		           DWORD    ?
r	               DWORD    ?
result             DWORD    ?
string_answer      DWORD    ?
int_answer         DWORD    ?
userInput          BYTE     ?
count              DWORD    0
correct_answers    DWORD    ?
incorrect_answers  DWORD    ?
strSize            DWORD    ?

; CONSTANTS
LO = 3
HI = 12
MIN = 0
MAX = 9

;-----------------------------------------------------
mWriteString MACRO text
; Description: This is a macro that receives a string
; and displays that string to the console.
; Receives: a string of text
; Returns: nothing
;-----------------------------------------------------
	LOCAL string ; local label
.data
	string BYTE text,0				; define the string
.code
	push edx
	mov edx,OFFSET string           ; move the string into edx
	call WriteString                ; display the string
	pop edx
ENDM

.code
main PROC
	call Randomize
	call introduction				; Outputs the program title and the programmer's name
again:
	mov int_answer, 0
	inc count
	call CrLf
	
	mWriteString "Problem: "
	mov eax, count                  ; move count to eax to display the current problem
	call WriteDec                   ; display current problem
	call CrLf

	push OFFSET r					; Push r to receive random value from 1 to n
	push OFFSET n					; Push n to receive random value from 3 to 12
	call showProblem				; does not return n or r in eax
									; but stores values into n and r

	mWriteString "Number of elements in the set: "
	mov eax, n						; move n into eax to display n
	call WriteDec					; outputs n
	call CrLf                

	mWriteString "Number of elements to choose from the set: "
	mov eax, r						; move r into eax to display r
	call WriteDec					; Displays r
	call CrLf

	mWriteString "How many ways can you choose? "
	push OFFSET string_answer       ; ebp + 16
	push OFFSET int_answer          ; ebp + 12
	push strSize                    ; ebp + 8
	call getdata					; user's answer is stored in eax
	call CrLf

	push r							; esp + 12        = ebp + 16
	push n							; esp + 8         = ebp + 12
	push OFFSET result				; esp + 4         = ebp + 8
	call combinations				; esp = return @  = ebp + 4
									; result is stored in eax
	push r							; esp + 16       = ebp + 20
	push n							; esp + 12       = ebp + 16
	push int_answer				    ; esp + 8       = ebp + 12
	push result						; esp + 4       = ebp + 8
	call showResults

	mWriteString "Another problem? (y/n): "
	call ReadChar                   ; reads in a character from keyboard input
	call WriteChar                  ; displays the character to the screen
	call CrLf

	cmp al, 89                      ; see if the user entered an uppercase 'Y'
	je again                        ; restart the program if they entered 'Y'
	jmp checkInput                  ; jmp to see if the user entered a lowercase 'y'
checkInput:
	cmp al, 121                     ; see if the user entered an lowercase 'y'
	je again						; restart the program if they entered 'y'
	jmp endProgram                  ; end the program for anything entered other than 'Y' or 'y'
endProgram:
	mWriteString "You had.."
	call CrLf

	mov eax, correct_answers
	call WriteDec                   ; displays the total number of correct answers obtained
	mWriteString " correct answers."
	call CrLf

	mov eax, incorrect_answers
	call WriteDec                   ; displays the total number of inccorrect answers obtained
	mWriteString " incorrect answers."
	call CrLf

	mWriteString "OK ... goodbye."
	call CrLf
	invoke exitProcess, 0		
main ENDP
;-----------------------------------------------------
introduction PROC
; Description: Outputs the program title, the programmer's 
; name, and program information.
; Receives: [ebp+8] =  sProgramIntro, displays intro
; Returns: Nothing
;-----------------------------------------------------
	mWriteString "Welcome to the Combinations Calculator"
	call CrLf
	mWriteString "		Implemented by Jonathan Perry"
	call CrLf
	call CrLf
	mWriteString "I'll give you a combinations problem. You enter your answer,"
	call CrLf
	mWriteString  "and I'll tell you if you're right."
	call CrLf
	mWriteString  "**EC: 1) Each problem is numbered and when the program quits,"
	call CrLf
	mWriteString  "the number of correct/incorrect answers obtained is displayed."
	call CrLf
	ret
introduction ENDP

r_param EQU [ebp + 12]
n_param EQU [ebp + 8]
;-----------------------------------------------------
showProblem PROC
; Description: Generates a random problem for the student
; to guess the number of combinations of r items taken
; from a set of n items. The function generates random
; random problems with n in [3 .. 12] and r in [1 .. n].
; Receives: [ebp+8] =  n
;			[ebp+12] = r
; Returns: Nothing
; Result: [ebp+8] receives random integer for n
;         [ebp+12] receives random integer for r
;-----------------------------------------------------
	push ebp
	mov	ebp, esp
	mov	ebx, n_param				; n
	mov ecx, r_param				; r

	mov eax, HI - 2					; Move 12 - 2 (10) to eax
	call RandomRange				; Returns an integer in the range from 0 to 9
	add eax, LO						; Add 3 to the randomly generated number so that the number falls between 3 to 12
	mov	[ebx], eax					; Store the integer in the offset of n

	call RandomRange				; Returns an integer in the range from 0 to eax (n), where eax is between 0 to 11
	add eax, 1						; Add 1 so we get a number in the range of 1 to  n, where n is between 3 and 12
	mov	[ecx], eax					; Store the integer in the offset of r

	pop ebp
	ret 8                           ; clean up the stack
showProblem ENDP

student_answer EQU [ebp + 16]
integer_answer EQU [ebp + 12]
;-----------------------------------------------------
getData PROC
; Description: Prompts the user for their answer on the
; number of combinatons of r items taken from a set of
; n items. However, this function reads their input in
; as a string and then converts it to an integer. 
; (Assuming a valid integer was entered)
; Receives: [ebp + 16] = string_answer      
;			[ebp + 12] = int_answer          
;			[ebp + 8 ] = strSize                    
; Returns: eax = the students answer
;          [ebp+8] = eax
;-----------------------------------------------------
	push ebp
	mov ebp, esp
readInput:
	mov edx, student_answer			; move the address of the student's answer (string) into edx
	mov ecx, MAX
	call ReadString					; read the string
	cmp eax, MAX + 1				; compare the length of the string to 10 (9 + 1)
	jg invalidInput					; jump if the length is > 10
	mov ecx, eax					; Use the length of the string to loop through each character
	mov esi, student_answer			; Looks at the next character in the string

readNextChar:						; loop looks at each char in the string
    mov ebx, integer_answer			; move the address of integer_answer into ebx, to store the converted string
    mov eax, [ebx]					; move address of answer into eax
    mov ebx, 10d					; move 10 into ebx
    mul ebx							; multiply answer by 10

    mov ebx, integer_answer			; move address of answer into ebx
    mov [ebx], eax					; add product to answer
    mov al, [esi]					; move value of char into al register
    inc esi							; incrase esi to move to the next char
    sub al, 48d						; subtract 48 to get the integer 

    cmp al, MIN     				; Check to make sure the integer isn't less than 0
    jl invalidInput
    cmp al, MAX						; Check to make sure the integer isn't greater than 9
    jg invalidInput

    mov ebx, integer_answer			; move address of answer into ebx
    add [ebx], al					; add the integer to the integer_answer
    loop readNextChar               ; convert the next character to an integer
	jmp done                        

invalidInput:						; reset registers and variables to 0 to read in next character
    mov al, 0                       ; move 0 into al to reset al to store a different integer
    mov eax, 0                      ; move 0 into eax to read in the next integer
    mov ebx, integer_answer         ; move the address of integer_answer into ebx
    mov [ebx], eax                  ; move 0 into integer_answer
    mov ebx, student_answer         ; move the address of student_answer into ebx
    mov [ebx], eax                  ; move 0 into student_answer
    mWriteString "There was an error on converting the string to an integer."
	call CrLf
	mWriteString "Please enter in an integer: "
    jmp readInput
done:
	pop ebp                         ; return eax, the string converted to an integer
	ret 12                          ; clean up the stack
getData ENDP

r_param		 EQU [ebp + 16]
n_param		 EQU [ebp + 12]
result_param EQU [ebp + 8 ]
;-----------------------------------------------------
combinations PROC
; Description: This function determines the factorial
; value of r, n, and (r-n)! to determine how many 
; combinations of r items can be taken from n items. 
; The formula(# of combinations): n!/r!(n-r)!
; Receives: [ebp+16] = r
;		    [ebp+12] = n
;			[ebp+8 ] = calculated result
; Returns: eax, the calculated result
;-----------------------------------------------------
	push ebp
	mov	ebp, esp

	push r_param                    ; push r onto the stack
	call factorial                  ; factorial of r! in eax
	mov ecx, eax                    ; move r-factorial to ecx register
	
	mov eax, n_param                ; move n to eax
	sub eax, r_param                ; subtract eax by r
	push eax                        ; push (r - n) onto the stack
	call factorial                  ; factorial of (r - n) in eax

	mul ecx						    ; eax = eax * ecx
	mov ecx, eax                    ; move (r-n)! to ecx

	push n_param				    ; push r onto the stack
	call factorial				    ; factorial of n! in eax

	idiv ecx						
	mov	ebx, result_param		    ; move the address of the result into ebx
	mov [ebx], eax                  ; move the value into result
	
	pop ebp						    ; return eax
	ret 12							; clean up the stack
combinations ENDP
;-----------------------------------------------------
factorial PROC
; Description: calculates a factorial
; Receives: [ebp+8] =  n, the factorial to calculate
; Returns: eax, the factorial of n, r, or (n-r)!
; CITE: Irvine, Kip R. "Calculating a Factorial" Assembly Language for X86 Processors. 
;		 Boston: Pearson, 2015. N. pag. Print.
;        P. 305 Factorial Through Recursion Example
;-----------------------------------------------------
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]				; get n
	cmp eax, 0						; n > 0?
	ja L1							; yes: continue
	mov eax, 1						; no: return 1 as the value of 0!
	jmp L2							; jump to return to the caller
L1: 
	dec eax
	push eax						; factorial(n1)
	call Factorial
ReturnFact:
	mov ebx, [ebp+8]			    ; get n, the factorial to calculate
	mul ebx							; eax = eax * ebx
L2: 
	pop ebp							; return eax
	ret 4							; clean up the stack
factorial ENDP

r_param		 EQU [ebp + 20]
n_param		 EQU [ebp + 16]
stud_answer  EQU [ebp + 12]
result_param EQU [ebp + 8]
;-----------------------------------------------------
showResults PROC
; Description: This function displays the student's answer,
; the calculated result, and whether or not the student
; got the answer correct. Each correct/incorrect answer
; is kept track of to display this information before
; the student exits the program.
; Receives: [ebp+8] = calculated result
;           [ebp+12] = student's answer/guess
;           [ebp+16] = n
;           [ebp+20] = r
; Returns: Nothing
;-----------------------------------------------------
	push ebp
	mov ebp, esp

	mWriteString "There are "
	mov eax, result_param          ; moves the calculated result into eax
	call WriteDec                  ; displays the calculated result

	mWriteString " combinations of "
	mov eax, r_param               ; moves r into eax
	call WriteDec                  ; displays r

	mWriteString " items from a set of "
	mov eax, n_param               ; moves n into eax
	call WriteDec                  ; displays n

	mov	al,'.'                     ; moves a period into al
	call WriteChar				   ; prints a period.
	call CrLf               

	mov ebx, result_param          ; move result_param into ebx
	mov eax, stud_answer           ; move the student's answer into eax
	cmp ebx, eax                   ; compare to see if the student is correct/incorrect
	je isEqual
	jmp notEqual
isEqual:
	inc correct_answers            ; increase the number of correct answers by 1
	mWriteString "You are correct!"
	jmp finished                   ; jump to return to the caller
notEqual:
	inc incorrect_answers
	mWriteString "You need more practice."
	jmp finished                   ; jump to return to the caller
finished:
	call CrLf
	pop ebp						   ; return EAX
	ret 16						   ; clean up stack
showResults ENDP
END main
