TITLE Program2   (project2.asm)

; Author: Jonathan Perry
; CS 271 / Project #4  Date: 5/15/17

; Description: This is a program that prompts the user to enter a number for the amount
; of composite numbers to be displayed and then validates that it's within 1 and 400
; before printing out the user specified amount of composite numbers.

INCLUDE Irvine32.inc

UPPERLIMIT = 400
.data
sProgramTitle	   BYTE		"Composite Numbers      Programmed by Jonathan Perry",0
sInfoPrompt        BYTE     "Enter the number of composite numbers you would like to see.",0dh,0ah
				   BYTE		"Ill accept orders for up to 400 composites.", 0
sEnterNumbers      BYTE     "Enter the number of composites to display [1 .. 400]: ",0
sOutOfRange        BYTE     "Out of range. Try again.", 0
inputEntered   	   DWORD    ?
sCertified         BYTE     "Results certified by Jonathan. GoodBye.", 0
sPeriod  		   BYTE     ".", 0
sSpaces			   BYTE		"   ",0
compositeNumber    DWORD    ?


.code
main PROC
	call introduction				; Outputs the program title and the programmer's name
	call getUserData				; Prompts the user to enter a number between 0 and 400
	call showComposites             ; Displays the composites back to the user
	call farewell					; Tells the user goodbye and then exits the program
main ENDP
;-----------------------------------------------------
introduction PROC
; Outputs the program title, the programmer's name, and
; program information.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------
	mov edx,OFFSET sProgramTitle	
	call WriteString				; Displays program's title
	call CrLf
	call CrLf

	mov edx,OFFSET sInfoPrompt
	call WriteString				; Displays information to the user
	call Crlf
	call CrLf
introduction ENDP
;-----------------------------------------------------
getUserData PROC
; Promps the user to enter in a number in the range of
; 1 and 400 amd validates that their user input is within
; that range.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov edx, OFFSET sEnterNumbers    
	call writeString                ; Prompts the user to enter a number
	call ReadInt
	mov inputEntered, eax

	cmp inputEntered, UPPERLIMIT    ; Compare the input entered to 400
	jle L1                          ; Jump to L1 to compare input to 1
L2:	
	mov edx,OFFSET sOutOfRange
	call WriteString				; Displays information to the user
	call Crlf
	call CrLf

	mov edx, OFFSET sEnterNumbers    
	call writeString                ; Prompts the user to enter a number
	call ReadInt
	mov inputEntered, eax
	cmp inputEntered, UPPERLIMIT    
	jg L2                           ; Jump to L2 to tell user they're out of range
	jmp L1                          ; Jump to L1 to compare input to 1
L1:
	cmp inputEntered, 1
	jl L2
	mov inputEntered, eax
	ret
getUserData ENDP
;-----------------------------------------------------
showComposites PROC
; This is a function that displays each composite number
; with spaces in between each number and newlines after
; 10 numbers have been printed on one line.
; Receives: Nothing
; Returns: Nothing
;-----------------------------------------------------
	pushad
    mov	eax, 4                       ; 4 is the lowest composite number possible
	mov	ebx, 2                       ; 2 is the lowest possible divisor for composite numbers
	mov	ecx, inputEntered            ; set the counter to the amount of numbers the user wants to display
	mov esi, 0                       ; Secondary iteration to keep count of many numbers have been displayed
	mov	compositeNumber, eax
L3:
	call getComposites               ; Call getComposites to find the next composite number
	mov	eax, compositeNumber           
	call WriteDec                    ; Print the composote number out to the screen
	inc	compositeNumber              ; Increment to find the next composite number

	inc	esi                          ; Increase the secondary iteration for each composite number that's printed
	mov	eax, esi
	mov	ebx, 10
	cdq
	div	ebx                          ; Divides the secondary loop counter by the max numbers per line (10)

	cmp	edx, 0                       ; Compare the remainder to 0 to see how many numbers have been printed
	jne	printSpaces                  ; Add a space if less than 10 numbers have been printed on the current line
	call CrLf                        ; Print a newline if 10 numbers have been printed 
	jmp	Continue

printSpaces:
	mov	edx, OFFSET sSpaces
	call WriteString                 ; Displays "  "

Continue:
	mov	ebx, 2                       ; Reset ebx back to the lowest possible divisor for composite numbers
	mov	eax, compositeNumber         ; Move the next number to be checked into eax
	loop L3                          ; Start the next iteration
	popad
	ret                              ; Iterations based on user input complete
showComposites ENDP
;-----------------------------------------------------
getComposites PROC
; This is a function that looks for the next composite
; number, and if it is found, it is returned to the 
; showComposite procedure that called it.
; Receives: Nothing
; Returns: Composite Number
;-----------------------------------------------------
	pushad
L4:
	cmp	ebx, eax                     ; Compare ebx to eax to see if the number is composite
	je NoCompositesFound             ; Jump if it cannot be composite
	cdq
	div	ebx
	cmp	edx, 0                       ; Compare the remainder to 0 to see if the number is composite
	jne	NotComposite                 
	popad
	ret								 ; the number is composite, return back to showComposites procedure

NoCompositesFound:
	inc	compositeNumber              ; Increment the composite number by 1
	mov	eax, compositeNumber         ; Move it into eax
	mov	ebx, 2                       ; Set edx back to 2 (the lowest possible divisor for composite numbers)
	jmp	L4                           ; Loop back to look again for a composite number

NotComposite:
	mov	eax, compositeNumber
	inc	ebx                          ; Increment the divisor
	jmp	L4                           ; Loop back to look again for a composite number
getComposites ENDP
;-----------------------------------------------------
farewell PROC
; Displays a parting message that includes the user's name,
; and then terminates the program.
; Receives: Nothing 
; Returns: Nothing
;-----------------------------------------------------
	call Crlf
	call Crlf
	mov edx,OFFSET sCertified
	call WriteString				; Displays "Results certified..."

	mov edx, OFFSET sPeriod
	call WriteString				; Displays "."
	call Crlf
	invoke exitProcess, 0
farewell ENDP
END main
