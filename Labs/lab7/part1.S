@This program takes a number and outputs all the prime numbers between 1 and that number,
@and also prints the number of prime numbers found.


	.data
msg:	.asciz 	"Enter a number\n"
msg2:	.asciz	"The prime numbers are: "
msg3:	.asciz	"(NONE)"
msg4:	.asciz	"Total : %d\n"
endmsg:	.asciz	"\n"
str1:	.asciz	"%d"
	.align	2
str2:	.asciz	"%d, "
	.align	2
n:	.word	0

	.text
divide:	
	stmfd	sp!,{lr}
	mov	r2, r1		@move divisor to r2
	mov	r1, r0		@move dividend to r1
	mov	r0, #0		@clear r0
	mov	r3, #1		@"current" set to 1

loopc:	cmp	r2, #0		@while msb of r2 != 1
	blt	loopc2		@continue to next loop
	cmp	r2, r1		@check r2 < r1
	lslls	r2, r2, #1	@shift dividend left
	lslls	r3, r3, #1	@shift current left
	bls	loopc		@continue in loop

loopc2:	cmp	r1, r2		@if dividend >= divisor
	subhs	r1, r1, r2	@subtract divisor from dividend
	addhs	r0, r0, r3	@ set current in the result
	lsr	r2, r2, #1	@shift dividend right
	lsrs	r3, r3, #1	@ shift current bit right into carry
	bcc	loopc2		@ continue loop if carry clear	

	ldmfd	sp!,{lr}
	mov	pc, lr

isprime:
	stmfd	sp!,{r4, r5,lr}
	mov	r5, #2		@i = 2
	mov	r4, r0		@move number to check prime to r4
	cmp	r4, r5		@if number = 2
	beq	endb2		@exit out

loopb:	mov	r0, r4		@move number to check prime to r0
	mov	r1, r5		@move i to r1
	bl	divide		@call divide function
	cmp	r1, #0		@check if remainder = 0
	moveq	r0, #0		@if = 0, set to return 0
	beq	endb		@if = 0, exit function
	add	r5, r5, #1	@i++
	cmp	r5, r4		@check if i = provided number
	bne	loopb		@if not equal, continue through loop
	
endb2:	mov	r0, #1		@if nothing found, set to return 1

endb:	ldmfd	sp!,{r4, r5, lr}
	mov	pc, lr





	.globl	main
main:
	stmfd	sp!,{r4-r7, lr}
	
	mov	r7, #0		@initialize counter to 0
	ldr	r0, =msg	@load "enter a number"
	bl 	printf		@print to screen

	ldr	r0, =str1	@load %d
	ldr	r1, =n		@load address to store value into
	bl	scanf		@can in value and store it

	ldr	r0, =msg2	@load "the prime numbers are"
	bl	printf		@print to screen

	ldr	r5, =n		@load value into r5
	ldr	r5, [r5]	@dereference
	mov	r4, #2		@i = 2
	
	cmp	r5, #1		@if number entered is 1
	beq	ende		@end
	cmp	r5, #2		@if number entered is 2
	beq	ende		@end

loopa:	mov	r0, r4		@move i into r0
	bl	isprime		@check to see if the number is prime
	cmp	r0, #1		@if = prime
	addeq	r7, r7, #1	@increment counter
	beq	print		@print it out
rl:	add	r4, r4, #1	@i++
	cmp	r4, r5		@check if i = max number
	beq	enda		@exit out
	b	loopa		@continue through loop


print:	ldr	r0, =str2	@load ", " to be printed
	mov	r1, r4		@move i to be printed
	bl	printf		@print
	mov	r6, #1		@indicate a number has been printed
	b	rl		@return to loop

ende:	ldr	r0, =msg3
	bl	printf

enda:	
	ldr	r0, =endmsg
	bl	printf
	mov	r1, r7
	ldr	r0, =msg4
	bl	printf
	mov	r0, #0
	ldmfd	sp!,{r4-r7, lr}
	mov	pc,lr
