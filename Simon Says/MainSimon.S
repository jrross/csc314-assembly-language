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
menu:	.asciz	"MAIN MENU\nPick a mode:\nGreen - Simon\nBlue - Mastermind\nRed - Whack-a-Mole\nYellow - Power Down\n"
	.align	2
yplay:	.asciz	"omxplayer yellow.wav"
	.align	2
bplay:	.asciz	"omxplayer blue.wav"
	.align	2
rplay:	.asciz	"omxplayer red.wav"
	.align	2
gplay:	.asciz	"omxplayer green.wav"
	.align	2
splay:	.asciz	"omxplayer success.wav"
	.align	2
fplay:	.asciz	"omxplayer failure.wav"
	.align	2
mplay:	.asciz	"omxplayer menuSelect.wav"
	.align	2
array:	.skip	200
	.align	2
clear:	.asciz	"clear"
	.align	2

	.text

@@@ enable/disable the internal pullup/pulldown resistors
@@@ set_pud(gpio_pin_num, direction)
@@@ direction: 0=float, 1=pull down, 2=pull up
set_pud:stmfd	sp!,{r0-r3}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r3,[r3]			@ load address of the gpio device
	@@ Enable the internal pull-up resistors on button pins
 	@@ Store direction in GPPUD
 	str	r1,[r3,#GPPUD]
 	mov	r2,#SHORT_DELAY
w1:	subs	r2,r2,#1
 	bcc	w1
 	@@ Write to GPPUDCLK0 to clock the signals into GPIO 21,22,23,24
 	mov	r2,#1
	lsl	r2,r2,r0
 	str	r2,[r3,#GPPUDCLK0]
 	mov	r2,#SHORT_DELAY
w2:	subs	r2,r2,#1
 	bcc	w2
	@@ Write to GPPUD to remove the control signal
 	mov	r2,#0
 	str	r2,[r3,#GPPUD]
 	@@ Write to GPPUDCLK0/1 to remove the clock 
 	@@ Write to GPPUDCLK0 to clock the signals into GPIO 21,22,23,24
 	mov	r2,#0
 	str	r2,[r3,#GPPUDCLK0]
	ldmfd	sp!,{r0-r3}
	mov	pc,lr

	
@@@ pin_offest finds the offset to the correct GPFSEL register
@@@ it returns the offset in r3, and the shift amount in r0
pin_offset:	
	subs	r0,r0,#10		@ pins 0-9 are in GPFSEL0
	movlt	r3,#GPFSEL0
	blt	have_offset
	subs	r0,r0,#10		@ pins 10-19 are in GPFSEL1
	movlt	r3,#GPFSEL1
	blt	have_offset
	subs	r0,r0,#10		@ pins 20-29 are in GPFSEL2
	movlt	r3,#GPFSEL2
	blt	have_offset
	subs	r0,r0,#10		@ pins 30-39 are in GPFSEL3
	movlt	r3,#GPFSEL3
	blt	have_offset
	subs	r0,r0,#10		@ pins 40-49 are in GPFSEL4
	movlt	r3,#GPFSEL4
	blt	have_offset
	sub	r0,r0,#10		@ pins 40-49 are in GPFSEL5
	mov	r3,#GPFSEL5
have_offset:
	add	r0,r0,#10	@ make 0<=r0<=9
	add	r0,r0,r0,asl #1 @ r0 *= 3
	mov	pc,lr

@@@ gpio_dir_input sets the pin specified in r0 to be an input pin
gpio_dir_input:
	stmfd	sp!,{lr}
	@@ Load the Base Address of the GPIO device
	ldr	r1,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r1,[r1]			@ load address of the gpio device
	bl	pin_offset 		@ get the offset in r3 and shift in r0
	add	r1,r1,r3		@ get pointer to the FPFSEL register
	ldr	r3,[r1]			@ read the FPFSEL register
	mov	r2,#7			@ create bit mask for 3 bits we need to clear
	lsl	r2,r2,r0
	mvn	r2,r2
	and	r2,r2,r3		@ clear the 3 bits 
	str	r2,[r1]			@ write the FPFSEL register
	str	r2,[r1]			@ write the FPFSEL register
	ldmfd	sp!,{pc}

@@@ gpio_dir_output sets the pin specified in r0 to be an output pin
gpio_dir_output:
	stmfd	sp!,{lr}
	@@ Load the Base Address of the GPIO device
	ldr	r1,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r1,[r1]			@ load address of the gpio device
	bl	pin_offset 		@ get the offset in r3 and shift in r0
	add	r1,r1,r3		@ get pointer to the FPFSEL register
	ldr	r3,[r1]			@ read the FPFSEL register
	mov	r2,#7			@ create bit mask for 3 bits we need to clear
	lsl	r2,r2,r0
	mvn	r2,r2	
	and	r3,r2,r3		@ clear the 3 bits
	mov	r2,#1			@ create bit mask for the bit we need to set
	lsl	r2,r2,r0	
	orr	r2,r2,r3		@ set the 3 bits
	str	r2,[r1]			@ write the FPFSEL register
	ldmfd	sp!,{pc}
	
	.global	main
main:	stmfd	sp!,{r4-r12,lr}

	@@ map the devices into our address space
	bl	IO_init

	@@ Load the Base Address of the GPIO device
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device

	@@ Set the direction bits for the pins
	mov	r0,#17
	bl	gpio_dir_output		@ green LED
	mov	r0,#18
	bl	gpio_dir_output		@ blue LED
	mov	r0,#27
	bl	gpio_dir_output		@ red LED
	mov	r0,#13
	bl	gpio_dir_output		@ yellow LED
	mov	r0, #21
	bl	gpio_dir_input		@ yellow Button
	mov	r0, #22
	bl	gpio_dir_input		@ green Button
	mov	r0,#23
	bl	gpio_dir_input		@ blue Button
	mov	r0,#24
	bl	gpio_dir_input		@ red Button
	

	mov r0,#21
	mov	r1, #2
	bl	set_pud

	mov	r0,#22
	mov	r1,#2
	bl	set_pud

	mov	r0,#23
	mov	r1,#2
	bl	set_pud

	mov	r0,#24
	mov	r1,#2
	bl	set_pud
mainstrt:
	ldr	r0, =clear		@ clear anything on the screen
	bl	system
	ldr	r0, =menu		@ display main menu
	bl	printf
	
mainMenu:
	ldr	r0,[r4,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	bleq	playYmenu		@ play menu sound and display yellow
	beq	shutDown		@ if yellow is pressed exit program
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	bleq	playGmenu		@ play menu sound and display green	
	beq	simonSays		@ if green go to simon says game
	beq	mainstrt		@ reset
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	bleq	playBmenu		@ play menu sound and display blue
	bleq	mastermind		@ if blue go to mastermind game
	beq	mainstrt		@ reset
	tst	r0,#(1<<24)		@ check state of pin 24	RED
	bleq	playRmenu		@ play menu sound and display red
	bleq	whack			@ go to whack a mole
	beq	mainstrt		@ reset
	b	mainMenu
	
	

simonSays:
	bl	displayYellow		@ cycle through four colors
	bl	displayRed
	bl	displayBlue
	bl	displayGreen
	bl	makeArray		@ creates an array of 50 random values
	mov	r0, #2
	bl	sleep			@ pause for 2 seconds before starting the round

	mov	r7, #0			@ initialize audio to not be played
	mov	r11, #0			@ start off on round 1 (0 will be incremented)
	b	simonloop

success:
	ldr	r0, =splay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system

simonloop:	
	mov	r6, #0			@ reset i = 0
	add	r11, r11, #1		@ increment total count
	mov	r0, r11
	bl	playPattern		@ play pattern with total count times
	mov	r8, #4			@ indicate the user has not chosen an option
readloop:
	cmp	r6, r11
	bge	success
	@@ Read the state of the buttons
	@@ Read GPIO Level Register 0 (GPLEV0)
	ldr	r0,[r4,#GPLEV0]

	mov	r1,#0			@ will be used to set outputs
	mov	r2,#0			@ will be used to clear outputs

	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
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

	cmp	r7, #0			@ indicates to skip audio
	bne	nosound			@ this prevents audio from playing twice successively

	tst 	r0, #(1<<13)		@ if yellow LED currently active
	ldreq	r0, =yplay		@ play yellow tone
	bleq	system
	ldreq	r0, =clear		@ clears text put to screen
	bleq	system
	moveq	r8, #0			@ put 0 in r8 to indicate yellow was pressed
	mov	r7, #1			@ indicate to skip audio next loop
	beq 	readloop		@ return to top of loop

	tst 	r0, #(1<<27)		@ if red LED currently active
	ldreq	r0, =rplay		@ play red tone
	bleq	system
	ldreq	r0, =clear		@ clears text put to screen
	bleq	system
	moveq	r8, #1			@ put 1 in r8 to indicate red was pressed
	mov	r7, #1			@ indicate to skip audio next loop
	beq 	readloop		@ return to top of loop
 
	tst 	r0, #(1<<17)		@ if green LED currently active
	ldreq	r0, =gplay		@ play green tone
	bleq	system
	ldreq	r0, =clear		@ clears text put to screen
	bleq	system
	moveq	r8, #3			@ put 3 in r8 to indicate green was pressed
	mov	r7, #1			@ indicate to skip audio next loop
	beq 	readloop		@ return to top of loop

	tst 	r0, #(1<<18)		@ if blue LED currently active
	ldreq	r0, =bplay		@ play blue tone
	bleq	system
	ldreq	r0, =clear		@ clears text put to screen
	bleq	system
	moveq	r8, #2			@ put 2 in r8 to indicated blue was pressed
	mov	r7, #1			@ indicate to skip audio next loop
	beq 	readloop		@ return to top of loop

nosound:
	mov	r7, #0			@ reset sound so will play next iteration
	cmp	r8, #4
	beq	readloop		@ if user has not chosen go back to biginning
	ldr	r9, =array
	add	r3, r9, r6, lsl #2	@ get address for array[i]
	ldr	r3, [r3]		@ get value for array[i]
	add	r6, r6, #1		@ i++
	cmp	r3, r8			@ check if user input was correct
	mov	r8, #4
	beq	readloop		@ if correct continue on
	
	ldr	r0, =fplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	b	mainstrt

shutDown:	
	ldmfd	sp!,{r4-r12,pc}

	.global	displayYellow
displayYellow:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	mov 	r5, #0
	orr 	r1, #(1<<13)
	orr 	r5, #(1<<13)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr 	r0, =yplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	displayRed
displayRed:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<27)
	orr 	r5, #(1<<27)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =rplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	displayBlue
displayBlue:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<18)
	orr 	r5, #(1<<18)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =bplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	displayGreen
displayGreen:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<17)
	orr 	r5, #(1<<17)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =gplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins	
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

makeArray:
	stmfd	sp!,{r4,r5,lr}
	mov	r5, #0			@ i = 0
	ldr	r4, =array		@ load address of array into r4
	mov	r0, #0
	bl	time			@ use time(NULL) togenerate a seed
	bl	srand			@ set seed with srand
randloop:
	cmp 	r5, #50			@ while i < 50
	beq	fin
	mov	r0, r5			@ copy i to r0
	bl	rand			@ get a random value
	mov 	r1, #3			
	and 	r1, r1, r0		@ take randVal % 3 to get 1 of 4 vals
	add	r3, r4, r5, lsl #2	@ i*4 bytes
	str	r1, [r3]		@ store random value
	add	r5, r5, #1		@ i++
	b	randloop

fin:
	ldmfd	sp!,{r4,r5,lr}
	mov	pc,lr

playPattern:
	stmfd	sp!,{r4-r6, lr}
	mov	r4, r0			@ store number of loops in r4
	ldr	r5, =array		@ store address to array in r5
	mov	r6, #0			@ initialize i =0 in r6
playloop:
	cmp	r6, r4			@ check if it has gone through total loops
	bge	quitplay
	add	r3, r5, r6, lsl #2	@ get address for array[i]
	ldr	r3, [r3]		@ get value for array[i]
	cmp	r3, #0 
	bleq	displayYellow		@ if val = 0 play the yellow
	addeq	r6, r6, #1		@ increment i
	beq	playloop		@ return to top of loop
	cmp	r3, #1
	bleq	displayRed		@ if val = 1 play the red
	addeq	r6, r6, #1		@ increment i
	beq	playloop		@ return to top of loop
	cmp	r3, #2
	bleq	displayBlue		@ if val = 2 play the blue
	addeq	r6, r6, #1		@ increment i
	beq	playloop		@ return to top of loop
	cmp	r3, #3
	bleq	displayGreen		@ if val = 3 play the green
	addeq	r6, r6, #1		@ increment i
	beq	playloop		@ return to top of loop
quitplay:
	ldmfd	sp!,{r4-r6,lr}
	mov	pc, lr


	.global	playYmenu
playYmenu:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	mov 	r5, #0
	orr 	r1, #(1<<13)
	orr 	r5, #(1<<13)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr 	r0, =mplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	playRmenu
playRmenu:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<27)
	orr 	r5, #(1<<27)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =mplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	playBmenu
playBmenu:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<18)
	orr 	r5, #(1<<18)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =mplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	.global	playGmenu
playGmenu:
	stmfd	sp!,{r4,r5,lr}
	ldr	r4,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r4,[r4]			@ load address of the gpio device
	mov	r1, #0
	orr 	r1, #(1<<17)
	orr 	r5, #(1<<17)
	str	r1,[r4,#GPCLR0]		@ clear pins
	ldr	r0, =mplay
	bl	system
	ldr	r0, =clear		@ clears text put to screen
	bl	system
	str	r5,[r4,#GPSET0]		@ set pins	
	ldmfd	sp!,{r4,r5,lr}
	mov	pc, lr

	
