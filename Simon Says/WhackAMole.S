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
count:	.asciz	"omxplayer countdown.wav"
	.align	2
done:	.asciz	"omxplayer MolesPopped.wav"
	.align	2
clear:	.asciz	"clear"
	.align	2
cont:	.asciz	"Press any button to return to Main Menu\n"
	.align	2
timer:	.asciz	"Your time is: %ld.%u seconds\n"
	.align	2
temp:	.skip	1000
	.align	2
optn:	.asciz	"Choose your number of moles:\nGreen - 10\nBlue - 20\nRed - 50\nYellow - 100\n"
	.text

	.global	whack
whack:	stmfd	sp!, {r4-r8,lr}
	ldr	r7,=gpiobase		@ load pointer to the address of the gpio device
	ldr	r7,[r7]			@ load address of the gpio device
	ldr	r0, =optn		@ display whackamole menu
	bl	printf
	bloop:
	ldr	r0,[r7,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	bleq	playYmenu		@ play menu sound
	moveq	r3, #100		@ use 100 "moles"
	beq	startgame		@ if active continue
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	bleq	playGmenu		@ play menu sound
	moveq	r3, #10			@ use 10 "moles"
	beq	startgame		@ if active continue
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	bleq	playBmenu		@ play menu sound
	moveq	r3, #20			@ use 20 "moles"
	beq	startgame		@ if active continue
	tst	r0,#(1<<24)		@ check state of pin 24	RED
	bleq	playRmenu		@ play menu sound
	moveq	r3, #50			@ use 50 "moles"
	beq	startgame		@ if active continue
	b	bloop			@ loop up

startgame:
	mov	r5, #4			@ r5 will contain previous random val, start w/ 4
	mov	r4, #0			@ r4 will be loop counter, start at 0
	mov	r6, r3			@ r6 will be number of "moles"
	ldr	r0, =count		@ play ready-set-go sound
	bl	system
	ldr	r0, =clear		@ clear command prompt
	bl	system
	ldr	r0, =temp		@ load address to hold time
	bl	timer_start		@ start the timer in the C code
	mov	r8, r0			@ store the returned value in r8

loop:	
	orr 	r1, #(1<<17)		@ pin for green
	orr 	r1, #(1<<18)		@ pin for blue
	orr 	r1, #(1<<27)		@ pin for red
	orr 	r1, #(1<<13)		@ pin for yellow
	str	r1,[r7,#GPSET0]		@ turn off all LEDS
	mov	r1, #0			@ remove previous
	cmp	r4, r6			@ check if hit number of "moles"
	bge	end			@ if >= quit out
	mov	r0, r5			@ move random value to r0
	bl	getRandVal		@ generate a random value
	mov	r5, r0			@ save value in r5

	cmp	r5, #0
	orreq 	r1, #(1<<13)		@ if val = 0 display the yellow
	cmp	r5, #1
	orreq 	r1, #(1<<27)		@ if val = 1 display the red
	cmp	r5, #2
	orreq 	r1, #(1<<18)		@ if val = 2 display the blue
	cmp	r5, #3
	orreq 	r1, #(1<<17)		@ if val = 3 display the green
	str	r1,[r7,#GPCLR0]		@ turn on corresponding LED

buttonLoop:
	ldr	r0,[r7,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	moveq	r3, #0			@ indicate yellow
	beq	break			@ if it is move to next color
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	moveq	r3, #3			@ indicate green
	beq	break			@ if it is move to next color
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	moveq	r3, #2			@ indicate blue
	beq	break			@ if it is move to next color
	tst	r0,#(1<<24)		@ check state of pin 24	RED
	moveq	r3, #1			@ indicate red
	beq	break			@ if it is move to next color
	
	b	buttonLoop
	
break:	cmp	r3, r5			@ check if it was the correct button
	bne	buttonLoop		@ if wrong button return
	add	r4, r4, #1		@ i++
	b	loop			@ go to top of loop

end:
	mov	r0, r8			@ get initial time value
	ldr	r0, [r0]		@ dereference
	bl	timer_end_sec		@ get the seconds elapsed time
	mov	r4, r0			@ hold in r4
	mov	r0, r8			@ get initial time value
	ldr	r0, [r0]		@ dereference
	bl	timer_end_nano		@ get the nanoseconds elapsed time
	mov	r5, r0			@ hold in r5
	ldr	r0, =done		@ play short jingle
	bl	system
	ldr	r0, =clear		@ clear command prompt
	bl	system		
	ldr	r0, =timer		@ get print statement
	mov	r1, r4			@ move seconds to r1
	mov	r2, r5			@ move nanoseconds to r2
	bl	printf			@ print out time taken
	ldr	r0, =cont		@ print prompt to return to main menu
	bl	printf
bloop2:
	ldr	r0,[r7,#GPLEV0]		@ read state of the buttons
	tst	r0,#(1<<21)		@ check state of pin 21 YELLOW
	bleq	playYmenu		@ play menu sound
	beq	quitout			@ if active quit
	tst	r0,#(1<<22)		@ check state of pin 22 GREEN
	bleq	playGmenu		@ play menu sound
	beq	quitout			@ if active quit
	tst	r0,#(1<<23)		@ check state of pin 23 BLUE
	bleq	playBmenu		@ play menu sound
	beq	quitout			@ if active quit
	tst	r0,#(1<<24)		@ check state of pin 24	RED
	bleq	playRmenu		@ play menu sound
	beq	quitout			@ if active quit
	b	bloop2			@ loop up
	
quitout:
	mov	r0, #1
	bl	sleep			@ prevent from automatically selecting
	ldmfd	sp!, {r4-r8,lr}
	mov	pc, lr
	
@@Will be passed previous value to prevent repeats
getRandVal:
	stmfd	sp!,{r4,lr}
	mov	r4, r0			@ copy over previous value
	mov	r0, #0			@ NULL
	bl	time			@ get seed with time(NULL)
	bl	srand			@ set seed

randloop:
	bl	rand			@ generate random value
	mov	r1, #3
	and	r0, r0, r1		@ get random value % 3
	cmp	r4, r0			@ check if it's the same of the previous
	bne	exit			@ if not the same quit out
	b	randloop

exit:
	ldmfd	sp!,{r4,lr}
	mov	pc, lr

