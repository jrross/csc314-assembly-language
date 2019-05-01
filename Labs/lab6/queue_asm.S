@Simple enque and deque functions for a c++ queue class
@int enque(int item):
@_ZN5queue5enqueEi

@int deque(int &item):
@_ZN5queue5dequeERi

@int isfull()
@_ZN5queue6isfullEv

@int isempty()
@_ZN5queue7isemptyEv

	@endindex 212
	.text
	.global _ZN5queue5enqueEi @r1 will contain item, r0 is ptr
	.global _ZN5queue5dequeERi @r1 will contain address of item

_ZN5queue5enqueEi:
	stmfd	sp!, {r4-r6, lr}
	mov	r5, r0		@move pointer to class contents to r5
	mov	r6, r1		@move integer to be stored to r6
	bl	_ZN5queue6isfullEv
	cmp	r0, #1		@check return of isfull for 1 or 0
	beq	quit		@if returned 1, exit function
	ldr	r3, [r5, #212]	@load r3 with the end index
	str	r6, [r5, r3, lsl #2]	@store item into array[endindex]
	
	add	r3, r3, #1	@endindex++
	cmp	r3, #52		@compare endindex with 52
	movge	r3, #0		@if greater than or equal to, set to 0
	str	r3, [r5, #212]	@store endindex

	ldr	r3, [r5, #216]	@load nitems into r3
	add	r3, r3, #1	@nitems++ 
	str	r3, [r5, #216]	@store nitems


	mov	r0, #1		@set to return 1
	b	finish

quit:	mov	r0, #0		@set to retun 0

finish:	ldmfd	sp!, {r4-r6, lr}
	mov	pc,lr		@ return



_ZN5queue5dequeERi:
	stmfd 	sp!, {r4-r6, lr}
	mov 	r5, r0		@move pointer to class contents to r5
	mov	r6, r1		@move address of item to be removed to r6
	bl	_ZN5queue7isemptyEv
	cmp	r0, #1
	beq	quit2		@if the queue is empty, quit

	ldr	r1, [r5, #208]	@load front index into r1
	ldr	r6, [r5, r1, lsl #2]	@load item to be removed into r6
	add	r1, r1, #1	@frontindex++
	cmp	r1, #52		@check if frontindex >= MAX_QUEUE_SIZE
	movge	r1, #0;		@if >=, frontindex = 0
	str	r1, [r5, #208]	@store frontindex

	ldr	r2, [r5, #216]	@load nitems into r2
	sub	r2, r2, #1	@nitems--
	str	r2, [r5, #216]	@store nitems
	mov	r0, r6		@move item to r0 to be returned
	b	quit3		@finish up
	


quit2:	mov	r0, #0

quit3:	ldmfd	sp!, {r4-r6, lr}
	mov	pc, lr		@return
	.end

