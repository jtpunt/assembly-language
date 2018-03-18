TITLE Program5   (project5.asm)

; Author: Jonathan Perry
; CS 271 / Project #5  Date: 5/28/17

; Description: This is a program that aks the user how many numbers they want randomly 
; generated and validates that the input entered is in the range from 10 to 200. After
; validation, each number that's generated is stored into an array and the unsorted
; values of the array are then displayed. Finally, the array's valeus are sorted from
; largest to smallest to display both the median value and the sorted values of the
; array.

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999
.data
sProgramIntro	   BYTE		"Sorting Random Integers                  Programmed by Jonathan Perry",0dh,0ah
                   BYTE     "This program generates random numbers in the range [100 .. 999]",0dh,0ah
				   BYTE     "displays the original list, sorts the list, and calculates the",0dh,0ah
				   BYTE     "median value. Finally, it displays the list sorted in descending order.",0dh,0ah
				   BYTE      "**Extra Credit: Quick Sort recursive algorithm used.",0
sEnterNumber       BYTE     "How many numbers should be generated? [10  .. 200]: ",0
sInvalidInput      BYTE     "Invalid input", 0
arraySize   	   DWORD    ?
randomNumber       DWORD    ?
sUnsortedDisplay   BYTE     "The unsorted random numbers:",0
sMedianDisplay     BYTE     "The median is ",0
sSortedDisplay     BYTE     "The sorted list:",0
myArray			   DWORD	HI DUP(?)
counter            DWORD    0

.code
main PROC
	call Randomize
	push OFFSET sProgramIntro
	call introduction				; Outputs the program title and the programmer's name

	mov	edx,OFFSET sEnterNumber
	call WriteString		        ; Prompts the user to enter input
	push OFFSET arraySize
	call getData					; Prompts the user to enter a number between 0 and 400

    cmp arraySize, MIN              ; Range-based validation
	jl L1                           ; Jump to L1 if inputEntered is less than 10
	cmp arraySize, MAX              ; Else, do another range-based validation
	jg L1                           ; Jump to L1 when inputEntered is greather than 200
	jmp L2                          ; Jump to L2 to continue the program

L1: mov edx,OFFSET sInvalidInput
	call WriteString				; Displays information to the user
	call CrLf
	mov	edx,OFFSET sEnterNumber
	call WriteString				; Prompt user to enter an integer
	push OFFSET arraySize
	call getData					; Prompts the user to enter a number between 0 and 400

	cmp arraySize, MIN 
	jl L1                           ; Jump to L1 when inputEntered is less than 10
	cmp arraySize, MAX
	jg L1                           ; Jump to L1 when inputEntered is greather than 200
	jmp L2                          ; Jump to L2 to continue the program

L2: push OFFSET myArray             ; Continue with Program
	push arraySize                  ; Push the value of arraySize to the stack
	call fillArray                  ; Fill the array with random integers from 100-999

    call CrLf
	push OFFSET sUnsortedDisplay    ; Push the address of the sUnsortedDisplay prompt to the stack
	push OFFSET myArray             ; Push the adress of the array to the stack to display it's values
	push arraySize                  ; Push the value of arraySize to the stack to use as a counter
	call displayList	            ; Displays all values of the array

	push OFFSET myArray             ; Push the adress of the array to the stack to sort values from largest to smallest
	push arraySize                  ; Push the value of arraySize to the stack to use as a counter
	call sortList                   ; Resorts the values in the array from largest to smallest


	call CrLf
	call CrLf
	push OFFSET sMedianDisplay      ; Push the address of the sMedianDisplay prompt to the stack
	push OFFSET myArray             ; Push the adress of the array to the stack to find the median value
	push arraySize                  ; Push the value of arraySize to the stack to use as a counter
	call displayMedian              ; Displays the median value of the array

	call CrLf
	push OFFSET sSortedDisplay      ; Push the address of the sSortedDisplay prompt to the stack
	push OFFSET myArray             ; Push the adress of the array to the stack to display it's values
	push arraySize                  ; Push the value of arraySize to the stack to use as a counter
	call displayList                ; Displays all values of the array

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
    push ebp
	mov	ebp, esp
	mov edx, [ebp+8]        ; Move the prompt to edx
	call WriteString		; Displays program's title
	call CrLf
	call CrLf
	pop ebp
	ret 4
introduction ENDP
;-----------------------------------------------------
getData PROC
; Description: Receives the address of the variable from 
; the stack to store the user's input and then receives 
; integer input from the user and stores that input into 
; the address of the variable on the stack.

; Receives: [ebp+8]: arraySize, stores integer input
; Returns: eax = the user entered integer input for
;          the size of the array.
;-----------------------------------------------------
	push	ebp
	mov	ebp,esp
	call	ReadInt			; get user's number
	mov	ebx,[ebp+8]		    ; address of inputEntered in ebx
	mov	[ebx],eax			; store in global variable
	pop	ebp                 ; return eax
	ret	4
getData ENDP

 ;***************************************************************
 fillArray	PROC
 ; Description: This function fills an array with randomly generated 
 ; integers in the range from 100 - 999 and then return the array.

 ; Receives: [ebp+12]: address of an array on system stack
 ;			 [ebp+8 ]: value of arraySize on system stack
 ; Returns: The array filled with randomly generated integers
 ;***************************************************************
	push ebp
	mov	ebp, esp
	mov	ecx, [ebp+8]		 ; count in ecx
	mov	edi, [ebp+12]		 ; address of array in edi
	mov ebx, 0               ; Set ebx to 0, or the first element of the array will be 0 and not a random integer

again:
	mov eax, HI - 99         ; Move 999 - 99 (900) to eax
	call RandomRange         ; Returns an integer in the range from 0 to 899
	add eax, 100             ; Add 100 to the randomly generated number so that the number falls between 100 to 999
	mov	[edi], eax           ; Store the integer in the array
	add	edi, 4               ; Move to the next subscript of the array            
	inc ebx                  ; Loop until ebx = ecx counter
	loop again
	
	pop	ebp
	ret	8
fillArray	ENDP

 ; CITE: Irvine, Kip R. "Searching and Sorting Integer Arrays." Assembly Language for X86 Processors. 
 ;		 Boston: Pearson, 2015. N. pag. Print.
 ;       P.375 Bubble Sort Example
 ;***************************************************************
 sortList	PROC
 ; Description: The is a function that uses a bubble sort recursive 
 ; algorithm to sort an array of 32-bit integers in ascending order.
 ;
 ; Receives: [ebp+12]: address of an array on system stack
 ;			 [ebp+8 ]: value of arraySize on system stack
 ; Returns: The array values sorted from largest to smallest
 ;***************************************************************
	push ebp
	mov	ebp,esp
	mov	ecx,[ebp+8]			 ; count in ecx
	dec ecx					 ; decrement count by 1

L1: mov	edi,[ebp+12]		 ; address of array in edi
	push ecx				 ; save outer loop count

L2: mov eax,[edi]		     ; Move array value to eax
	cmp [edi+4],eax		     ; compare a pair of values
	jg L3			         ; if [EDI] <= [EDI+4], no exchange occurs
	xchg eax,[edi+4]         ; exchange the pair
	mov [edi],eax

L3: add edi,4				 ; move both pointers forward
	loop L2					 ; inner loop
	pop ecx					 ; retrieve outer loop count
	loop L1					 ; else repeat outer loop

L4: pop ebp
	ret 8
sortList ENDP

 ;***************************************************************
 displayMedian	PROC
 ; Description: The is a function that displays the median by first 
 ; looking at the number of elements in the array. If the number of elements 
 ; is even, the median is calculated by taking the average of two
 ; elements that make up the center positions of the array. If the
 ; number of elements in the array is odd, the median is calculated 
 ; by taking the value of the one element that takes the center position
 ; of the array. Finally, the median value is displayed to the user.
 ; 
 ; Receives: [ebp+16]: = sMedianDisplay
 ;           [ebp+12]: address of an array on system stack
 ;			 [ebp+8 ]: value of arraySize on system stack
 ; Returns: The array values sorted from largest to smallest
 ;***************************************************************
	push ebp
	mov	ebp, esp
	mov edx, [ebp+16]
	call WriteString		 ; Displays program's title
	mov	ecx, [ebp+8]		 ; count in ecx
	mov	edi, [ebp+12]		 ; address of array in edi
	mov edx, 0               ; reset edx back to 0

	mov eax, ecx             ; put the counter in eax
	mov ecx, 2               ; prepare the counter to be divided by 2
 	idiv ecx                 ; no remainder = even, remainder = odd
	cmp edx, 0
	je isEven                ; if EDX = 0, no remainder, therefore even
	jne isOdd                ; else EDX is > 0, therefore odd

; We have 1 value to receive from the array to find the median
isOdd:	
	mov ebx, 4               ; Move 4 (DWORD = 4 bytes) to ebx, so we can move between subscripts of the array
	mul ebx                  ; Multiply eax(position of median) * ebx
	mov ebx, [esi+eax]       ; Store the value of the median into ebx
	mov eax, ebx             ; Move the median value into eax
	jmp finished

; We have two values to receive from the array to find the median
isEven: 
	mov ebx, 4               ; Move 4 (DWORD = 4 bytes) to ebx, so we can move between subscripts of the array
	mul ebx                  ; Multiply eax(position of median) * ebx
	mov ebx, [esi+eax]       ; Store the value of the first value into ebx
	mov eax, [esi+eax-4]     ; Store the value of the second value into eax
	add eax, ebx             ; Find the sum of the two values
	cdq                      ; Extend eax into edx
	mov ebx, 2               ; Move 2 to ebx, so we can find the average
	idiv ebx

	cmp edx, 1               ; compare the remainder to 1 (because 50% of 2 (the divisor) is 1)
	jae roundUp              ; If edx is 1 or greater, then round up
	jmp finished             ; Else, edx is less than 1 and does not need to be rounded up

; When the remainder is > .50, we have to round up.
; When the remainder is < .50, we leave the median value alone.
roundUp:
	add eax, 1               ; Round eax up
	jmp finished             ; Jump to finished to display the median value

finished:
	call WriteDec            ; Display the median value
	mov	al,'.'               
	call WriteChar		     ; Prints a period.
	call CrLf
	pop ebp 
	ret 12
displayMedian ENDP
 ;***************************************************************
 displayList PROC
 ; Description: This is a function that displays a custom prompt
 ; that's received from the stack (along with the address of the array,
 ; and the number of elements in the array) and then displays all
 ; the values in the array, with 10 values display per line.
 ;
 ; Receives: [ebp+16]: = sUnsortedDisplay or sSortedDisplay prompts
 ;           [ebp+12]: address of an array on system stack
 ;			 [ebp+8 ]: value of arraySize on system stack
 ; Returns: Nothing
 ;***************************************************************
	push ebp
	mov	ebp,esp
	mov edx, [ebp+16]
	call WriteString		; Displays program's title
	call CrLf
	mov	edx,[ebp+8]		    ; count in edx
	mov	esi,[ebp+12]		; address of array in esi
	dec	edx

more:
	cmp counter, 10         ; Have 10 numbers been printed on 1 line already?
	je L3                   ; If so, jump to L3 to print a newline
	jmp L4                  ; else, continue on with printing values

L3:
	call CrLf
	mov counter, 0          ; Reset the counter
	jmp L4                  ; Continue with printing values

L4:
	mov	eax,[esi+edx*4]	    ; start with the last element
	call WriteDec			; Display it
	mov	al,' '              
	call WriteChar          ; Insert a space between printed values
	dec	edx                 ; Move closer towards the first element of the array
	inc counter             ; Increase counter to keep track of how many numbers have been printed
	cmp	edx,0               ; Have we reached the last element of the array?
	jge	more                ; Jump to more if we have not reached the last element
	mov counter, 0          ; Reset the counter
	pop	ebp
	ret	12
displayList ENDP
END main
