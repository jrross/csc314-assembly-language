@@This program takes three values, and calculates the the values for f(x) at a certain number
@@of points which is provided from the provided lower bound to the provided upper bound for the
@@ function (x^3 - x^2 -2x)/((x-2)^4/11)+3)

	.data
print:	.asciz	"%f"
	.align	2
head:	.asciz	"    x       f(x)\n"
endl:	.asciz	"\n"
	.align	2
scan:	.asciz	"%lf"
	.align	2
scan2:	.asciz	"%d"
	.align	2
divd:	.asciz	" | "
	.align	2
msg1:	.asciz	"Enter lowest value: "
	.align	2
msg2:	.asciz	"Enter largest value: "
	.align	2
msg3:	.asciz	"Enter size: "
	.align	2
min:	.word	0
	.word	0
max:	.word	0
	.word	0
size:	.word	0
 
	.text
findx:	stmfd	sp!,{r4-r11,lr}
	vmul.f64	d1, d0, d0	@d1 contains x^2
	vmul.f64	d2, d0, d1	@d2 contains x^3
	vadd.f64	d3, d0, d0	@d3 contains 2x
	vsub.f64	d2, d2, d1	@x^3 - x^2
	vsub.f64	d2, d2, d3	@d2 contains numerator

	mov	r0, #2			@prepare constant numbers
	mov	r1, #11
	mov	r2, #3	
	vmov	s3, r0			@move into single registers
	vmov	s6, r1
	vmov	s10, r2
	vcvt.f64.s32	d1, s3		@d1 contains #2
	vcvt.f64.s32	d3, s6		@d3 contains #11
	vcvt.f64.s32	d5, s10		@d5 contains #3
	vsub.f64	d1, d0, d1	@x-2
	vmul.f64	d1, d1 ,d1	@x-2^2
	vmul.f64	d1, d1, d1	@x-2^4
	vdiv.f64	d1, d1, d3	@ ^/11
	vadd.f64	d1, d1, d5	@ d1 contains denominator
	
	vdiv.f64	d0, d2, d1	@numerator / denominator	

	ldmfd		sp!,{r4-r11,lr}
	mov		pc, lr





	.globl main
main:	stmfd	sp!,{r4-r11,lr}

	ldr	r0, =msg1		@scan in min
	bl	printf
	ldr	r0, =scan
	ldr	r1, =min
	bl	scanf
	
	ldr	r0, =msg2		@scan in max
	bl	printf
	ldr	r0, =scan
	ldr	r1, =max
	bl	scanf

	ldr	r0, =msg3		@scan in size
	bl	printf
	ldr	r0, =scan2
	ldr	r1, =size
	bl	scanf
	
	ldr	r4, =min		@load addresses
	ldr	r5, =max
	ldr	r6, =size	
	vldr.f64	d4, [r4]	@dereference
	vldr.f64	d5, [r5]
	ldr	r6, [r6]
	sub	r6, r6, #1		@size--
	vmov	s2, r6

	vcvt.f64.s32	d2, s2
	vsub.f64	d8, d5, d4	@high - low
	vdiv.f64	d8, d8, d2	@this holds increment amount
	mov	r4, #0			@this holds i
	ldr	r0, =head
	bl	printf
	
loop:	cmp	r4, r6			@compare i to size
	bgt	exit			@if done with loop exit
	vmov	s2, r4			@move i into a single register
	vcvt.f64.s32	d10, s2		@convert to double float
	vmul.f64	d1, d10, d8	@i*increment amount
	vadd.f64	d0, d4, d1	@increment from low value
	tst	sp,#4			@print out
	vmovne	r1, r2, d0
	vmoveq	r2, r3, d0
	ldr	r0, =print
	bl	printf
	
	ldr	r0, =divd
	bl	printf

	vadd.f64	d0, d4, d10	@increment from low value
	bl	findx			@calculate x value
	tst	sp,#4			@print out
	vmovne	r1, r2, d0
	vmoveq	r2, r3, d0
	ldr	r0, =print
	bl	printf
	ldr	r0, =endl
	bl	printf
	add	r4, r4, #1		@increment i
	b	loop	

exit:
	ldmfd	sp!,{r4-r11,lr}
	mov	pc, lr

	.end
