	.data
	.equ	bi_blks,0	@ offset to block pointer
	.equ	bi_size,4	@ offset to size int
	.equ	bi_struct_sz,8	@ size of the bigint struct

	.text
	.globl	bigint_shift_left_chunk
	.type	bigint_mul, %function

bigint_shift_left_chunk:
	stmfd	sp!,{r4-r11,lr}
	mov	r4, r0		@bigint l in r4
	mov	r5, r1		@int chunks in r5
	ldr	r6, [r4,#bi_size]	@load l->size into r6
	add	r8, r6, r1	@ =l->size + chunks
	mov	r0, r8
	bl	bigint_alloc	@hold tmp in r0
	mov	r2, #0		@initialize to 0
	mov	r3, #0		@used to save #0

loopa:	cmp	r2, r5		@while ( i < chunks )
	bge	loopb
	mov	r9, r2, lsl #5	@i * 32
	str	r3, [r0, r9]	@tmp->blks[i] = 0
	add	r2, r2, #1	@i++
	b	loopa

loopb:	cmp	r2, r8
	bge	quit
	mov	r9, r2, lsl #5	@i * 32
	mov	r10, r3, lsl #5	@j * 32
	ldr	r10, [r4, r10]	@l->blks[j]
	str	r10, [r0, r9]
	add	r2, r2, #1
	add	r3, r3, #1
	b	loopb	
	


quit:	ldmfd	sp!, {r4-r11,lr}
	mov	pc, lr

	.end
	
	
