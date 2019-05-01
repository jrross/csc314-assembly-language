@program that reads in chars and outputs the checksum

	.data
str1:	.asciz	"Enter text (ctrl-D to end):"
	.align	2
str2:	.asciz	"\nThe checksum is %08X\n"
	.align 	2
str3:	.asciz	"%s\n"
	.align 	2
buffer:	.skip	4096
i:	.word	0
sum:	.word	0

	.text

checksum:	
	stmfd	sp!, {r4, r5, r6, lr}

	ldr	r6, =i		@load i into r6
	ldr	r6, [r6]	@load value of i into r6
	ldr	r4, =sum	@load sum into r4
	ldr	r4, [r4]	@load value of sum into r4
	mov	r6, #0		@initialize i to 0

loop2:	ldrb	r1, [r0, r6]	@load buffer[i] into r1
	cmp	r1, #0		@check if i = -1
	beq	exit2
	add	r4, r4, r1	@add sum + buffer[i] and store in r4	
	add	r6, r6, #1	@i++
	b	loop2

	
exit2:	ldr	r2, =sum	@load sum into r2
	str	r4, [r2]	@store r4 into address of r2
	mov	r0, r4		@move sum into r0 to pass back

	ldmfd	sp!, {r4, r5, r6, lr}
	mov	pc, lr		@return from main





	

	.globl main
main:	stmfd	sp!, {lr}
	
	ldr	r0, =str1	@load string into r0
	bl	printf		@print string
	
	ldr	r6, =i		@load i into r6
	ldr	r6, [r6]	@load value of i into r6
	ldr	r5, =buffer	@load address of buffer into r5

loop:	bl	getchar		@run getchar
	cmp	r0, #-1		@check if r0 = -1
	beq	exit		@exit if not equal
	strb	r0, [r5, r6]	@store r0 into buffer[i]
	add	r6, r6, #1	@i++
	bl	loop		@loop


exit:	mov	r0, #0		@put 0 in r0
	strb	r0, [r5, r6]	@store 0 in buffer[i]
	ldr	r0, =str3	@load string 3
	mov	r1, r5		@load r5 into r1
	bl	printf		@print string

	mov	r0, r5		@move r5 to r0 for argument
	
	bl	checksum	@call checksum
	
	mov	r1, r0		@move returned value
	ldr	r0, =str2	@load string to r0
	bl	printf		@print out the sum

	mov	r0, r5		@move r5 to r0 for argument
	bl	checksum	@call checksum
	
	mov	r1, r0		@move returned value
	ldr	r0, =str2	@load string to r0
	bl	printf		@print out the sum

	ldmfd	sp!, {lr}	@pop lr from stack
	mov	r0, #0		@load return value
	mov	pc, lr		@return from main
	.end

