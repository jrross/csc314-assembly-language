

/* color_to_gray will allocate a new grayimage structure and fill it
   with the grayscale equivalent of the given image.

   The C prototype is:

   grayimage *color_to_gray(rgbimage *image);

*/
	.text
	.global	color_to_gray
color_to_gray:

	/* Fill in the code to allocate a new grayimage, then convert
	   each pixel from the given rgbimage from color to grayscale,
	   and store it in the grayimage. */

	stmfd	sp!, {r4-r12, lr}

	ldr	r6, [r0]	@storing the pointer to an array.
	ldr	r8, [r0, #4]	@storing the width
	ldr	r7, [r0, #8]	@storing the height
	
	mov	r0, r8		@move width into r0 to pass to function
	mov	r1, r7		@move height into r1 to pass to function
	bl	allocate_grayimage	@create grey image structure, stored in r0
	ldr	r12, [r0]	@dereference array

	mov	r9, #0		@initialize i to zero

loop:	cmp	r9, r7		@compare i to height
	bge	temp		@exit the loop. no more columns
	ldr	r10, [r6, r9, lsl #2]	@dereference to the pixels
	ldr	r1, [r12, r9, lsl #2]	@store in array multiplied by 4 (row)
	mov	r5, #0		@initialize j to zero

loop2:	cmp	r5, r8		@compare j to width
	bge	temp2		@if equal step out
	add	r2, r5, r5, lsl #1	@prepares j*3 (for colors)
	add	r4, r10, r2	@steps through the row	with 3*j
	ldrb	r2, [r4]	@load red into r2
	ldrb	r3, [r4, #1]	@load green into r3 j++ for this time only

	mov	r11, #54
	mul	r2, r2, r11	@multiply red by 54
	mov	r11, #184
	mul	r3, r3, r11	@multiply green by 184
	add	r2, r2, r3	@add r2 and r3, store in r2
	mov	r11, #18
	ldrb	r3, [r4, #2]	@load blue into r4 j++ for this time only
	mul	r3, r3, r11	@multiply blue by 18
	add	r2, r2, r3	@add r2 and r3, store in r2 
	lsr	r2, #8		@divide by 256
	strb	r2, [r1, r5]	@store into row plus j
	add	r5, r5, #1	@increment j
	b	loop2
		

temp2:	add	r9, r9, #1	@i++
	b	loop		@return back to first loop

temp:	
	ldmfd	sp!, {r4-r12, lr}
	mov	pc,lr		@ return
	
	.end
