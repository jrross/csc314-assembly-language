
	.data
msg:	.asciz	"stderr, bigint_mul_uint: Integer too large\n"
	.equ	bi_blks,0	@ offset to block pointer
	.equ	bi_size,4	@ offset to size int
	.equ	bi_struct_sz,8	@ size of the bigint struct

	.text
	.globl	bigint_mul_uint
	.type	bigint_mul_uint, %function

bigint_mul_uint:
	stmfd	sp!, {r4-r12,lr}

	mov	r4, r0		@store pointer to l in r4
	mov	r5, r1		@put r in r5
	ldr	r7, [r4,#bi_size]	@load size in r7

cont:	ldr	r6, [r4]
	cmp	r6, #0		@check first item cmp to 0
	blt	neg		@if less than perform operation
	mov	r6, #0		@indicate it was not negated
	b 	skip

neg:	bl	bigint_negate	@l = bigint_negate(l)
	mov	r4, r0
	mov	r6, #1		@indicate it was negated

skip:	mov	r8, #0		@initialize i = 0
	add	r12, r7, #1	@add 32 bits
	mov	r0, r12
	mov	r11, #0		@initialize j = 0	
	bl	bigint_alloc	@allocate a bigint of size * 2
	mov	r12, r0		@store pointer to allocated bigint in r12
	ldr	r9, [r0]	@dereference alloc
	ldr	r4, [r4]	@dereference l

loop:	cmp	r11,r7		@while ( j < r->size)
	bge	quit
	mov	r0, #0		@r0 = low-order of result
	mov	r1, r0		@r1 = higher order of result
	mov	r10, r8, lsl #2	@puts i*32 in r10 (size of ints to step through array)
	ldr	r2, [r4,r10]	@load l->blks[i] (low order of multiplicand) r2

	umull	r0, r1, r2, r5	@multiply, low is r0, high is r1

	ldr	r3, [r9, r10]
	adds	r3, r3, r0	@add to chunk
	add	r8, r8, #2	@i = i + 2
	mov	r11, r8, lsl #1	@ j = i * 2
	str	r3, [r9, r10]	@store first part in alloc->blks[i]
	add	r10, r10, #4	@i*32 + 32
	mov	r3, #0
	adcs	r3, r3, r1	@add to next chunk with carry
	str	r3, [r9, r10]	@store second part in alloc->blks[i+1]	
	b	loop		@return to top of outer loop

quit:	cmp	r6, #1		@check if was negated
	mov	r0, r12		@pointer to bigint in r0
	bleq	bigint_negate	@negate final bigint

finish:	ldmfd	sp!, {r4-r12,lr}
	mov	pc, lr

	.end
