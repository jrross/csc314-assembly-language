@program that reads in chars and outputs the checksum (sum of ascii values)

	.data
str1:	.asciz	"Enter text (ctrl-D to end):"
	.align	2
str2:	.asciz	"\nThe checksum is %08X\n"
	.align 	2
str3:	.asciz	"%s\n"
	.align 	2
@buffer:	.skip	4096

	.text

checksum:	
	stmfd	sp!, {r4, r5, r6, lr}

	mov	r4, #0		@initialize sum to 0
	mov	r6, #0		@initialize i to 0

loop2:	ldrb	r1, [r0, r6]	@load buffer[i] into r1
	cmp	r1, #0		@check if i = -1
	beq	exit2
	add	r4, r4, r1	@add sum + buffer[i] and store in r4	
	add	r6, r6, #1	@i++
	b	loop2

	
exit2:	add	r6, r6, #1	@increment i by 1
	str	r4, [r0, r6]	@move i to sp + i
	mov	r0, r6		@move i into r0 to pass back

	ldmfd	sp!, {r4, r5, r6, lr}
	mov	pc, lr		@return from main





	

	.globl main
main:	stmfd	sp!, {lr}
	
	ldr	r0, =str1	@load string into r0
	bl	printf		@print string
	
	mov	r6, #0		@initialize i to 0
	sub	sp, sp, #4096	@subtract buffer from stack ptr

loop:	bl	getchar		@run getchar
	cmp	r0, #-1		@check if r0 = -1
	beq	exit		@exit if equal
	strb	r0, [sp, r6]	@store r0 into buffer[i]
	add	r6, r6, #1	@i++
	bl	loop		@loop


exit:	mov	r0, #0		@put 0 in r0
	str	r0, [sp, r6]	@store 0 in buffer[i] (null terminated)
	ldr	r0, =str3	@load string 3
	mov	r1, sp		@load sp into r1
	bl	printf		@print string

	mov	r0, sp		@move sp to r0 for argument
	
	bl	checksum	@call checksum
	
	mov	r5, r0		@move returned value to r5
	ldr	r1, [sp, r0]	@load sp + returned value (sum) into r1 for argument
	ldr	r0, =str2	@load string to r0
	bl	printf		@print out the sum

	mov	r0, sp		@move sp to r0 for argument
	
	bl	checksum	@call checksum
	
	mov	r5, r0		@move returned value to r5
	ldr	r1, [sp, r0]	@load sp + returned value (sum) into r1 for argument
	ldr	r0, =str2	@load string to r0
	bl	printf		@print out the sum


	add	sp, sp, #4096
	ldmfd	sp!, {lr}	@pop lr from stack
	mov	r0, #0		@load return value
	mov	pc, lr		@return from main
	.end

