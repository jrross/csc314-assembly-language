	.equ	SHORT_DELAY,	50
	@@  These are the offsets for the GPIO registers that we will use
	.equ	GPFSEL0,   0x0000
	.equ	GPFSEL1,   0x0004
	.equ	GPFSEL2,   0x0008
	.equ	GPFSEL3,   0x000C
	.equ	GPFSEL4,   0x0010
	.equ	GPFSEL5,   0x0014
	.equ	GPSET0,    0x001C
	.equ	GPSET1,    0x0020
	.equ	GPCLR0,    0x0028	
	.equ	GPCLR1,    0x002c	
	.equ	GPLEV0,    0x0034

	.equ	GPPUD,     0x0094
	.equ	GPPUDCLK0, 0x0098
 	.equ	GPPUDCLK1, 0x009C 	

	.data
optn1:	.asciz	"Choose your desired sequence length:\nGreen - 4\nBlue - 5\nRed - 6\nYellow - 7\n"
	.align	2
optn2:	.asciz	"Choose the number of attempts:\nGreen - 5\nBlue - 4\nRed - 3\nYellow - 2\n"
	.align	2
corr:	.asciz	"omxplayer correct.mp3"
	.align	2
incorr:	.asciz	"omxplayer incorrect.wav"
	.align	2
win:	.asciz	"omxplayer patternComplete.wav"
	.align	2
lose:	.asciz	"omxplayer patternIncorrect.wav"
	.align	2
fail:	.asciz	"omxplayer failure.wav"
	.align	2
array:	.skip	80
	.align	2
clear:	.asciz	"clear"
	.align	2

	.text
	.global mastermind
mastermind:
	stmfd	sp!, {r4-r12,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r0, #1			@ break for a second after coming in
	bl	sleep			@ to prevent from automatically selecting blue
	ldr	r0, =optn1
	bl	printf			@ display options
@@This is the sequence length selection
select:
	ldr	r0,[r4,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	beq	vhard			@ if yellow make array of 15
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	beq	easy			@ if green make array of 5
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	beq	normal			@ if blue make array of 7
	tst	r0,#(1<<24)		@ check state of pin 24 RED
	beq	hard			@ if red make array of 10
	b	select

easy:	mov	r0, #4
	mov	r5, #4			@ mark that easy was selected
	bl	makeArray		@ create random array of size 4
	bl	playGmenu		@ give indicator it was selected
	b	pause			@ go to guess selection

normal:	mov	r0, #5
	mov	r5, #5			@ mark that normal was selected
	bl	makeArray		@ create random array of size 5
	bl	playBmenu		@ give indicator it was selected
	b	pause			@ go to guess selection

hard:	mov	r0, #6			
	mov	r5, #6			@ mark that hard was selected
	bl	makeArray		@ create random array of size 6
	bl	playRmenu		@ give indicator it was selected
	b	pause			@ go to guess selection

vhard:	mov	r0, #7
	mov	r5, #7			@ mark that very hard was selected
	bl	makeArray		@ create random array of size 7
	bl	playYmenu		@ give indicator it was selected
	b	pause			@ go to guess selection

pause:	mov	r0, #1
	bl	sleep			@ prevent button from being entered twice
	ldr	r0, =optn2
	bl	printf			@ display options

@@this is the section to select the number of guesses you would like
select2:
	ldr	r0,[r4,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	beq	vhard2			@ if yellow set guesses to 2
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	beq	easy2			@ if green set guesses to 5
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	beq	norm2			@ if blue set guesses to 3
	tst	r0,#(1<<24)		@ check state of pin 24 RED
	beq	hard2			@ if red set guesses to 4
	b	select2

easy2:	mov	r6, #5			@ set guesses to 5
	bl	playGmenu
	b	startGame		@ go to start of game

norm2:	mov	r6, #4			@ set guesses to 4
	bl	playBmenu	
	b	startGame		@ go to start of game

hard2:	mov	r6, #3			@ set guesses to 3
	bl	playRmenu			
	b	startGame		@ go to start of game

vhard2:	mov	r6, #2			@ set guesses to 2
	bl	playYmenu
	b	startGame		@ go to start of game


startGame:
	mov	r0, #1
	bl	sleep			@short break before displaying sounds
	bl	displayRG
	mov	r8, #0
	mov	r7, #0
	b	readloop

@@ r5 holds length of sequences
@@ r6 holds number of sequences
@@ r7 holds internal i
@@ r8 holds external j
@@ r9 indicates button press
@@ r10 indicates whether current sequence has had an error
@@ r11 used to prevent going off twice
outerloop:
	mov	r2, #0			@ set r2 to zero
	orr	r2, #(1<<17)		@ set bits for LEDs
	orr	r2, #(1<<18)
	orr	r2, #(1<<27)
	orr	r2, #(1<<13)
	str	r2,[r4,#GPSET0]		@ turn off all LEDs
	cmp	r10, #0			@check if sequence was correct
	beq	victory			@player has won
	ldrne	r0, =fail		@play fail sound
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system			
	mov	r7, #0			@reset i
	add	r8, r8, #1		@increment j
	cmp	r8, r6			@check how many sequences it's been through
	bge	defeat			@if used all turns exit
	mov	r10, #0
	
@@ Read the state of the buttons
@@ Read GPIO Level Register 0 (GPLEV0)

readloop:
	ldr	r0,[r4,#GPLEV0]

	mov	r1,#0			@ will be used to set outputs
	mov	r2,#0			@ will be used to clear outputs

	tst	r0,#(1<<21)		@check state of pin 21 YELLOW
	orreq	r1, r1, #(1<<13)	@ if should be set (LED off)
	orrne	r2, r2, #(1<<13)	@ if should be clear (LED on)

	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	orreq	r1,r1,#0x20000		@ if should be set (LED off)
	orrne	r2,r2,#0x20000		@ if should be clear (LED on)

	tst	r0,#(1<<23)		@ check state of pin 23	BLUE
	orreq	r1,r1,#0x40000		@ if should be set (LED off)
	orrne	r2,r2,#0x40000		@ if should be clear (LED on)

	tst	r0,#(1<<24)		@ check state of pin 24	RED
	orreq	r1,r1,#0x8000000	@ if should be set (LED off)
	orrne	r2,r2,#0x8000000	@ if should be clear (LED on)

	str	r2,[r4,#GPSET0]		@ set some pins
	str	r1,[r4,#GPCLR0]		@ clear some pins
	
	cmp	r11, #1
	beq	skiponce		@skip to avoid double playing

	tst 	r0, #(1<<13)		@if yellow LED currently active
	moveq	r9, #0			@change to 0 to indicate yellow
	moveq	r11, #1			@indicate to skip next
	beq 	increment		@return to top of loop

	tst 	r0, #(1<<27)		@if red LED currently active
	moveq	r9, #1			@change to 1 to indicate red
	moveq	r11, #1			@indicate to skip next
	beq 	increment		@return to top of loop
 
	tst 	r0, #(1<<17)		@if green LED currently active
	moveq	r9, #3			@change to 3 to indicate green
	moveq	r11, #1			@indicate to skip next
	beq 	increment		@return to top of loop

	tst 	r0, #(1<<18)		@if blue LED currently active
	moveq	r9, #2			@change to 2 to indicate blue
	moveq	r11, #1			@indicate to skip next
	beq 	increment		@increment
	
skiponce:
	mov	r11, #0			@set to not skip
	b	readloop		@loop back to top

increment:
	ldr	r0, =array
	add	r0, r0, r7, lsl #2	@ value of i*4 bytes
	ldr	r0, [r0]		@ dereference
	cmp	r0, r9			@ compare button to actual value
	ldreq	r0, =corr		@ play correct sound if correct
	ldrne	r0, =incorr		@ play incorrect sound if incorrect
	movne	r10, #1			@ indicate an error in the sequence
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	add	r7, r7, #1		@ increment i
	cmp	r7, r5			@ checks if at end of sequence
	bge	outerloop		@ if finished with sequence go to outer loop
	b	readloop
	
victory:
	ldr	r0, =win		@ play winning sound
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	mov	r5, #0			@ set r5 to zero
	orr	r5, #(1<<17)		@ set bits for LEDs
	orr	r5, #(1<<18)
	orr	r5, #(1<<27)
	orr	r5, #(1<<13)
	str	r5,[r4,#GPSET0]		@ turn off all LEDs
	b	end	

defeat:
	ldr	r0, =lose		@ play losing sound
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	mov	r5, #0			@ set r5 to zero
	orr	r5, #(1<<17)		@ set bits for LEDs
	orr	r5, #(1<<18)
	orr	r5, #(1<<27)
	orr	r5, #(1<<13)
	str	r5,[r4,#GPSET0]		@ turn off all LEDs
	b	end
	
end:
	mov	r0, #1			@ pause for a second before returning
	bl	sleep			@ to main menu
	ldmfd	sp!, {r4-r12,lr}
	mov	pc, lr

@@creates an array for the size provided
makeArray:
	stmfd	sp!,{r4-r6,lr}
	mov	r6, r0			@move array size to r6
	mov	r5, #0			@i = 0
	ldr	r4, =array		@load address of array into r4
	mov	r0, #0
	bl	time			@use time(NULL) to generate a seed
	bl	srand			@set seed with srand
randloop:
	cmp 	r5, r6			@while i < size of array
	beq	fin
	mov	r0, r5			@copy i to r0
	bl	rand			@get a random value
	mov 	r1, #3			
	and 	r1, r1, r0		@take randVal % 3 to get 1 of 4 vals
	add	r3, r4, r5, lsl #2	@i*4 bytes
	str	r1, [r3]		@store random value
	add	r5, r5, #1		@i++
	b	randloop

fin:
	ldmfd	sp!,{r4-r6,lr}
	mov	pc,lr

displayRG:	
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<17)		@ orr the state of the pin for green LED
	orr 	r5, #(1<<17)		@ orr the state of the pin for green LED
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =corr		@ play sound
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	mov	r1, #0
	orr 	r1, #(1<<27)		@ orr the state of the pin for red LED
	orr 	r5, #(1<<27)		@ orr the state of the pin for red LED
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =incorr		@ play sound
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins	
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.end
