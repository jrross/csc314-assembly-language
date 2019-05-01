@@This program takes three values, and calculates the the values for f(x) at a certain number
@@of points which is provided from the provided lower bound to the provided upper bound for the
@@ function (x^3 - x^2 -2x)/((x-2)^4/11)+3)
	.data
msg1:	.asciz	"Enter value for lower limit of x: "
msg2:	.asciz	"Enter value for upper limit of x: "
msg3:	.asciz	"Enter value for number of rows: "
msg4:	.asciz	"x      | f(x)\n"
msg5:	.asciz	"    | "
endl:	.asciz	"\n"
scan:	.asciz	"%s"
	.align	2
scani:	.asciz	"%d"
	.align	2
const1:	.asciz	"0.0909090909"	@reciprocal of 11
temp:	.skip	400
low:	.word	0
high:	.word	0
size:	.word	0

	.text

fx:	stmfd	sp!,{r4-r11,lr}
	
	mov	r4, r0			@hold x in r4
	smull	r1, r0, r4, r4		@square a S(15,16), result is S(31,32)
	lsl	r0, #16			@shift integer portion left 16
	lsr	r1, #16			@shift fraction portion right 16
	orr	r5, r0, r1		@r5 contains x^2 (combined previous)
	smull	r1, r0, r4, r5		@multiply x * x^2
	lsl	r0, #16
	lsr	r1, #16
	orr	r6, r0, r1		@r6 contains x^3
	mov	r7, r4, lsl #1		@r7 holds 2*x
	sub	r5, r6, r5		@r5 holds x^3 - x^2
	sub	r5, r5, r7		@r5 holds numerator for total division
	
	mov	r0, #2
	lsl	r0, #16
	sub	r4, r4, r0		@r4 is now x - 2
	smull	r1, r0, r4, r4		@(x-2)^2
	lsl	r0, #16
	lsr	r1, #16
	orr	r4, r1, r0
	smull	r1, r0, r4, r4		@(x-2)^4
	lsl	r0, #16
	lsr	r1, #16
	orr	r4, r1, r0
	
	ldr	r0, =const1		@load reciprocal of 11
	mov	r1, #16			
	bl	strtoSfixed		@turn reciprocal into fixed point number
	smull	r1, r0, r4, r0		@multiply 1/11 * r4
	lsl	r0, #16
	lsr	r1, #16
	orr	r4, r1, r0
	mov	r0, #3			@add 3 to running total
	lsl	r0, #16
	add	r4, r0, r4		@r4 holds denominator for total division
	
	mov	r0, #0			@i=0
	mov	r6, #0			@clear r6
	cmp	r5, #0			@check if numerator is negative
	movlt	r6, #-1			@move 1 into r6
loop2:	cmp	r0, #16			@shift left by 1 16 times
	bge	cont			@if i >= 16 quit
	lsls	r5, #1			@shift by one marking for overflow
	lsl	r6, #1			@shift overflow by 1
	adccs	r6, r6, #0		@add carry to r6
	add	r0, r0, #1		@increment by 1
	b	loop2

cont:	mov	r1, r6
	mov	r0, r5
	mov	r3, #0
	cmp	r4, #0
	moveq	r0, #0
	beq	end			@if denominator is 0 exit and return 0
	movlt	r3, #-1			@if denominator is negative, set first bit of r3 to 1
	mov	r2, r4
	bl	sdiv64

end:	ldmfd	sp!,{r4-r11,lr}
	mov	pc, lr

	.globl main
main:	stmfd	sp!,{r4-r7,lr}

	ldr	r0, =msg1		@prompt for lower limit
	bl	printf
	ldr	r0, =scan		@scan lower limit
	ldr	r1, =temp
	bl	scanf
	ldr	r0, =temp		@load low value
	mov	r1, #16			@use 16 fraction bits
	bl	strtoSfixed		@call to convert to fixed point
	ldr	r1, =low		@load address for low
	str	r0, [r1]		@store fixed point number in low

	ldr	r0, =msg2		@prompt for upper limit
	bl	printf
	ldr	r0, =scan		@scan upper limit
	ldr	r1, =temp
	bl	scanf
	ldr	r0, =temp		@load high value
	mov	r1, #16			@use 16 fraction bits
	bl	strtoSfixed		@call to convert to fixed point
	ldr	r1, =high		@load address for high
	str	r0, [r1]		@store fixed point number in high

	ldr	r0, =msg3		@prompt for size
	bl	printf
	ldr	r0, =scani		@scan size
	ldr	r1, =size
	bl	scanf

	ldr	r4, =low		@low in r4
	ldr	r5, =high		@high in r5
	ldr	r6, =size		@size in r6
	ldr	r4, [r4]
	ldr	r5, [r5]		@dereference
	ldr	r6, [r6]
	mov	r0, r4			@copy r4 into r0
	mov	r1, r5			@copy r5 into r1
	sub	r7, r1, r0		@r7 = high - low
	
	mov	r2, r6			@copy of r6 inside r2
	sub	r2, r2, #1		@size - 1
	lsl	r2, #16			@convert size to fixed point
	mov	r0, #0			@ j = 0
	mov	r1, #0			@ clear r1

loop3:	cmp	r0, #16			@shift left by 1 16 times
	bge	cont2			@if i >= 16 quit
	lsls	r7, #1			@shift by one marking for overflow
	lsl	r1, #1			@shift overflow by 1
	adccs	r1, r1, #0		@add carry to r1
	add	r0, r0, #1		@increment by 1
	b	loop3

cont2:	mov	r0, r7
	mov	r3, #0
	bl	udiv64
	mov	r10, r0			@this holds increment amount
	mov	r9, #0			@ i = 0
	ldr	r0, =msg4
	bl	printf

loop:	cmp	r9, r6			@check if i>= size
	bge	exit			@exit
	mov	r0, r4			@print out x value
	mov	r1, #16			
	bl	printS
	ldr	r0, =msg5		@ending for print statement
	bl	printf
	mov	r0, r4			@move x to r0
	bl	fx			@find f(x)
	mov	r1, #16			@print out result
	bl	printS
	ldr	r0, =endl		@print \n
	bl	printf
	mov	r1, r10			@make copy of r10 in r1
	add	r4, r4, r1 		@go up by increment amount
	add	r9, r9, #1		@i++
	b	loop
exit:
	ldmfd	sp!,{r4-r7,lr}
	mov	pc, lr

	.end
