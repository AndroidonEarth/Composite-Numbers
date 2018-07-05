TITLE Composite Numbers     (Program4.asm)

; Author: Andrew Swaim			swaima@oregonstate.edu
; CS271-400		Program 4      2/18/2018
; Description: A program to calculate composite numbers. First, the user is instructed to enter 
;	the number of composites to be displayed, and is prompted to enter an integer in the 
;	range [1 .. 400]. The user enters a number, n, and the program verifies that 0 < n < 401. 
;	If n is out of range, the user is re-prompted until s/he enters a value in the specified range. 
;	The program then calculates and displays all of the composite numbers up to and including the
;	n-th composite. The results are displayed 10 composites per line with at least 3 spaces 
;	between the numbers.

INCLUDE Irvine32.inc

;Constants.
UPPER_LIMIT = 400
LOWER_LIMIT	= 1
TERMS_PER_LINE = 10
FIRST_PRIME = 2
SECOND_PRIME = 3

.data
program			BYTE	"Composite Numbers	Programmed by Andrew Swaim",0
ecNote1			BYTE	"**EC1: Output columns are aligned!",0
ecNote2			BYTE	"**EC3: Saves/checks against discovered prime divisors for better efficiency!",0
rules1			BYTE	"Enter the number of composite numbers you would like to see.",0
rules2			BYTE	"I'll accept orders for up to 400 composites.",0
prompt			BYTE	"Enter the number of composites to display [1 .. 400]: ",0
error			BYTE	"Out of range. Try again.",0
goodbye			BYTE	"Results certified by Andrew Swaim.   Goodbye.",0
fiveSpace		BYTE	"     ",0
fourSpace		BYTE	"    ",0
threeSpace		BYTE	"   ",0
input			DWORD	?			;To hold the user input.
validFlag		DWORD	?			;Flag to validate user input.
primes			DWORD	100 DUP(?)	;Array to hold the already discovered primes.
numOfPrimes		DWORD	2			;Counter for the primes array
nextTerm		DWORD	4			;Starting term/first composite = 4
newLineAccum	DWORD	0			;To determine if 10 terms have printed to move to next line

.code
main PROC

	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP

;------------------------------------------------------------------------------
; introduction
; Displays an the introduction to the program.
; Receives: none
; Returns: none
; Preconditions: none
; Postconditions: Prints program name and author name, indication of extra credit,
;	and user instructions to the console.
; Registers changed: edx
;------------------------------------------------------------------------------
introduction PROC
;Display program and author name.
	mov		edx,OFFSET program
	call	WriteString
	call	Crlf

;Indicate extra credit.
	mov		edx,OFFSET ecNote1
	call	WriteString
	call	Crlf
	mov		edx,OFFSET ecNote2
	call	WriteString
	call	Crlf
	call	Crlf

;User instructions.
	mov		edx,OFFSET rules1
	call	WriteString
	call	Crlf
	mov		edx,OFFSET rules2
	call	WriteString
	call	Crlf
	call	Crlf
	ret

introduction ENDP

;------------------------------------------------------------------------------
; getUserData
; Prompts the user to enter a number between [1 .. 400], and then validates the
;	user input. If validation fails, continues to prompt the user again until
;	a valid input is entered.
; Receives: none
; Returns: none
; Preconditions: none
; Postconditions: prints prompt to console, gets user input, and calls validate
;	to validate the input.
; Registers changed: edx, eax
;------------------------------------------------------------------------------
getUserData PROC

;Prompt for, get, and validate number.
	getInput:
		mov		edx,OFFSET prompt
		call	WriteString
		call	ReadInt
		call	validate
		cmp		validFlag,0
		je		getInput
		ret

getUserData ENDP

;------------------------------------------------------------------------------
; validate
; Validates that the user input is between [1 .. 400], and if so sets the valid
;	flag to 1(true) and stores the user input, and if not sets the valid flag 
;	to 0(false) and displays an error message.
; Receives: none
; Returns: none
; Preconditions: user input is in eax to validate.
; Postconditions: changes validFlag and either changes input variable or prints
;	an error message to the console.
; Registers changed: edx
;------------------------------------------------------------------------------
validate PROC

	;Validate number is >= 1.
		cmp		eax,LOWER_LIMIT
		jl		errorMessage
	;Validate number is <= 400 (Upper limit).
		cmp		eax,UPPER_LIMIT
		jg		errorMessage
	;If validation passed, store number in input and set validFlag.
		add		input,eax
		mov		validFlag,1

	continue:
		ret

	errorMessage:
	;Display error message and set validFlag.
		mov		edx,OFFSET error
		call	WriteString
		call	Crlf
		mov		validFlag,0
		jmp		continue

validate ENDP

;------------------------------------------------------------------------------
; showComposites
; Initializes the array with the first two prime numbers and sets the loop counter
;	using the user input. Then gets the next composite number and prints it to the
;	console, 10 composite numbers per row, followed by either formatted spaces 
;	of at least 3 spaces or a line break.
; Receives: none
; Returns: none
; Preconditions: input variable has been validated.
; Postconditions: changes primes, nextTerm, and newLineAccum.
; Registers changed: eax, ecx, edx, edi
;------------------------------------------------------------------------------
showComposites PROC

;Fill prime number array with first two numbers.
	call	Crlf
	mov		edi,OFFSET primes
	mov		eax,FIRST_PRIME
	stosd
	mov		eax,SECOND_PRIME
	stosd

;Initialize loop counter.
	mov		ecx,input

	printComposLoop:
	;Determine if nextTerm is composite, and if so print it to the screen.
		call	isComposite
		mov		eax,nextTerm
		call	WriteDec
		inc		nextTerm

	;Determine if line break is needed.
		inc		newLineAccum
		cmp		newLineAccum,TERMS_PER_LINE
		je		lineBreak

	;Or determine how many spaces to print if not new line.
		cmp		eax,100
		jae		threeSpaces
		cmp		eax,10
		jae		fourSpaces
		cmp		eax,1
		jae		fiveSpaces

	continue:
	;Loop again if able or return from procedure.
		loop	printComposLoop
		ret

	lineBreak:
	;Print a line break, reset line break accumulator, and continue the loop.
		call	Crlf
		mov		newLineAccum,0
		jmp		continue

	threeSpaces:
	;Print three spaces after the composite and continue the loop.
		mov		edx,OFFSET threeSpace
		call	WriteString
		jmp		continue

	fourSpaces:
	;Print four spaces after the composite and continue the loop.
		mov		edx,OFFSET fourSpace
		call	WriteString
		jmp		continue
	
	fiveSpaces:
	;Print five spaces after the composite and continue the loop.
		mov		edx,OFFSET fiveSpace
		call	WriteString
		jmp		continue

showComposites ENDP

;------------------------------------------------------------------------------
; isComposite
; Saves the current registers, sets the loop counter with number of primes, 
;	prepares edi and esi registers with prime number array to load and save to
;	to the array. Get a prime number and divides the term to be tested by the
;	prime num, checking edx to see if it divided evenly. If it does, simply return.
;	If none of the prime numbers divide evenly into the term, then the term is a
;	prime so save the new prime and inc to the next term. Continue this loop
;	until a composite number is found. Restore the registers before returning.
; Receives: none
; Returns: none
; Preconditions: inital term to be tested is in nextTerm.
; Postconditions: changes primes and nextTerm if initial term is not a composite.
; Registers changed: eax, ebx, ecx, edx, edi, esi (registers restored at the end)
;------------------------------------------------------------------------------
isComposite PROC
	
		pushad
		
	testForCompos:
	;Setup array and array counter.
		mov		ecx,numOfPrimes
		mov		esi,OFFSET primes
		mov		edi,esi

	testLoop:
	;Set/Reset term to test, and get and divide by next prime.
		lodsd	
		mov		ebx,eax
		mov		eax,nextTerm
		cdq
		div		ebx

	;If divided evenly then term is composite so exit procedure.
		cmp		edx,0
		je		compositeFound

	;If not, move to the next stored prime and loop again if able.
		add		edi,TYPE DWORD
		loop	testLoop
		
	;If no primes divided evenly into the term, term is a prime, 
	;so add to list and test again w/ next term.
		mov		eax,nextTerm
		stosd	
		inc		numOfPrimes
		inc		nextTerm
		jmp		testForCompos

	compositeFound:
		popad
		ret

isComposite ENDP

;------------------------------------------------------------------------------
; farewell
; Displays an the outro to the program.
; Receives: none
; Returns: none
; Preconditions: none
; Postconditions: Prints a farewell message to the console.
; Registers changed: edx
;------------------------------------------------------------------------------
farewell PROC
;Display the parting message
	call	Crlf
	call	Crlf
	mov		edx,OFFSET goodbye
	call	WriteString
	call	Crlf
	call	Crlf
	ret

farewell ENDP

END main
