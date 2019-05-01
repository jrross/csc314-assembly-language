@this program takes a number of coins per each individual week and outputs the total added
@for four weeks, the weekly average, and the total amount that would be saved over a year.

	.data
msg:	.asciz	"Enter the number of pennies, nickels, dimes, and quarters for week %d: "
	.align	2
total:	.asciz	"Over four weeks you have collected %d pennies, %d nickels, %d dimes, and %d quarters.\n"
	.align	2
fin:	.asciz	"This comes to $%d.%.2d\n"
	.align	2
fin2:	.asciz	"Your weekly average is $%d.%.2d\n"
	.align	2
fin3:	.asciz	"Your estimated yearly savings is $%d.%.2d\n"
	.align	2
scan:	.asciz	"%d"

penny:	.word	0
nickel:	.word	0
dime:	.word	0
qrtr:	.word	0
m:	.word	0xA3D70A3D
m2:	.word	32768


	.text
average:
	stmfd	sp!,{r4, lr}
	ldr	r1, =m2		@n = 17 // m = 32768
	ldr	r1, [r1]	@load calculated value of m into r1
	mul	r0, r1		@multiply this by the number provided
	lsr	r0, #17		@shift this by n to the right
	ldmfd	sp!,{r4, lr}
	mov	pc, lr


convert:
	stmfd	sp!, {r4,lr}
	mov	r2, r0		@store initial value in r2
	ldr	r3,=0x51EB851F	@n = 37 // m = 41943
	smull	r0, r1, r3, r2	
	mov	r3, r2, asr #31
	rsb	r0, r3, r1, asr #5
	mov	r1, #100
	mul	r1, r1, r0
	sub	r1, r2, r1	
	ldmfd	sp!, {r4, lr}
	mov	pc, lr


	.globl main

main:	stmfd	sp!, {r4-r10, lr}
	mov	r4, #1		@i = 0
	mov	r5, #0		@r5 is pennies
	mov	r6, #0		@r6 is nickels
	mov	r7, #0		@r7 is dimes
	mov	r8, #0		@r8 is quarters

begin:	mov	r1, r4
	ldr	r0, =msg	@print message prompting for coins
	bl	printf

	ldr	r0, =scan
	ldr	r1, =penny	@scan in pennies
	bl	scanf

	ldr	r0, =scan
	ldr	r1, =nickel	@scan in nickels
	bl	scanf

	ldr	r0, =scan
	ldr	r1, =dime	@scan in dimes
	bl	scanf

	ldr	r0, =scan
	ldr	r1, =qrtr	@scan in quarters
	bl	scanf

	ldr	r0, =penny	@load penny amount added to r0
	ldr	r0, [r0]	
	add	r5, r5, r0	@update penny total

	ldr	r0, =nickel	@load nickel amount add to r0
	ldr	r0, [r0]
	add	r6, r6, r0	@update nickel total

	ldr	r0, =dime	@load dime amount added to r0
	ldr	r0, [r0]	
	add	r7, r7, r0	@update dime total

	ldr	r0, =qrtr	@load quarter amount added to r0
	ldr	r0, [r0]
	add	r8, r8, r0	@update quarter total
	
	cmp	r4, #4		@go through four times
	beq	cont		@continue on
	add	r4, r4, #1	@i++
	b	begin		@print next line	

cont:
	ldr	r0, =total	@load print statement
	mov	r1, r5		@load penny total to r1
	mov	r2, r6		@load nickel total to r2
	mov	r3, r7		@load dime total to r3
	mov	r4, r8		@move quarter total to r4
	str	r4, [sp, #-4]!	@store r4 on the stack
	bl	printf		@print totals
	add 	sp,sp,#4	@restore stack

	add	r6, r6, r6, lsl #2	@r6 = r6 * 5
	mov	r0, r7, lsl #1	@store r7 * 2 in r0
	add	r7, r0, r7, lsl #3	@r7 = r7 * 10
	mov	r0, r8, lsl #3	@store r8 * 8 in r0
	mov	r1, r8, lsl #4	@store r8 * 16 in r0
	add	r0, r1, r0	@store r8 * 24 in r0
	add	r8, r8, r0	@r8 = r8 * 25

	mov	r0, #0		@initialize r0 to 0
	add	r0, r0, r5	@add pennies to total
	add	r0, r0, r6	@add nickels to total
	add	r0, r0, r7	@add dimes to total
	add	r0, r0, r8	@add quarters to total

	mov	r4, r0		@store total value in r4
	bl	convert		@to change cents into dollars
	mov	r2, r1		@move cents to r2
	mov	r1, r0		@move dollars to r1
	ldr	r0, =fin	@load print statement
	bl 	printf

	mov	r0, r4		@move total value to r0
	bl	average		@call average on total value
	mov	r4, r0		@move average to r4
	bl	convert		@convert to dollars and cents
	mov	r2, r1		@move cents to r2
	mov	r1, r0		@move dollars to r1
	ldr	r0, =fin2	@load print statement
	bl	printf

	mov	r0, r4		@move total value to r0
	mov	r1, r0, lsl #5	@store r0 * 32 in r1
	mov	r2, r0, lsl #4	@store r0 * 16 in r2
	lsl	r0, #2		@multiply r0 by 4
	add	r0, r0, r1	@add all together to get r0 * 52
	add	r0, r0, r2	
	bl	convert		@convert into dollars and cents
	mov	r2, r1		@move cents to r2
	mov	r1, r0		@move dollars to r1
	ldr	r0, =fin3	@load print statement
	bl	printf

	
	mov	r0, #0		@return 0
	ldmfd	sp!, {r4-r10, lr}
	mov	pc, lr
