@@@ pcDuino version
@@@ This program reads from three buttons, connected to GPIO2-4, and
@@@ controls three leds, connected to GPIO5-7

@@@ We define a mapping from the pcDuino port number (0-13)
@@@ to the hardware registers and bit locations for each port.

	.equ	PORTA, 0x000	@ offset to port A registers
	.equ	PORTB, 0x024	@ offset to port B registers
	.equ	PORTC, 0x048	@ offset to port C registers
	.equ	PORTD, 0x06C	@ offset to port D registers
	.equ	PORTE, 0x090	@ offset to port E registers
	.equ	PORTF, 0x0B4	@ offset to port F registers
	.equ	PORTG, 0x0D8	@ offset to port G registers
	.equ	PORTH, 0x0FC	@ offset to port H registers
	.equ	PORTI, 0x120	@ offset to port I registers
	
	@@ Within each port, the registers are arranged as follows:
	.equ	GPCFG0,  0x00	@ offset to cfg0 register
	.equ	GPCFG0,  0x04	@ offset to cfg1 register
	.equ	GPCFG0,  0x08	@ offset to cfg2 register
	.equ	GPCFG0,  0x0C	@ offset to cfg3 register
	.equ	GPDAT,   0x10	@ offset to data register
	.equ	GPDRV0,  0x14	@ offset to multi-drive 0 register
	.equ	GPDRV1,  0x18	@ offset to multi-drive 1 register
	.equ	GPPULL0, 0x1C	@ offset to pull up/down 0 register
	.equ	GPPULL1, 0x20	@ offset to pull up/down 1 register

	@@ Now we define a look-up table which maps pcDuino
	@@ ports to their hardware port offset and pin number.
	.data

gpio0:	.word	PORTI, 19	@ port offset and pin number
gpio1:	.word	PORTI, 18	@ port offset and pin number
gpio2:	.word	PORTH, 7	@ port offset and pin number
gpio3:	.word	PORTH, 6	@ port offset and pin number
gpio4:	.word	PORTH, 8	@ port offset and pin number
gpio5:	.word	PORTB, 2	@ port offset and pin number
gpio6:	.word	PORTI, 3	@ port offset and pin number
gpio7:	.word	PORTH, 9	@ port offset and pin number
gpio8:	.word	PORTH, 10	@ port offset and pin number
gpio9:	.word	PORTH, 5	@ port offset and pin number
gpio10:	.word	PORTI, 10	@ port offset and pin number
gpio11:	.word	PORTI, 12	@ port offset and pin number
gpio12:	.word	PORTI, 13	@ port offset and pin number
gpio13:	.word	PORTI, 11	@ port offset and pin number

	.text

@@@ void set_pud(int pcDuino_pin_num, int direction)
@@@ enable/disable the internal pullup/pulldown resistors
@@@ direction: 0=float, 1=pull down, 2=pull up
set_pud:stmfd	sp!,{r0-r4}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpio0	@ load pointer to mapping table
	add	r3,r3,r0,lsl #3 @ calculate pointer to table entry
	ldr	r4,[r3]		@ load port offset
	ldr	r3,[r3,#4]	@ load pin number

	ldr	r0,=gpiobase	@ load ptr to the address of the gpio device
	ldr	r0,[r0]		@ load address of the gpio device
	add	r0,r0,r4	@ add offset to base address of the port

	cmp	r3,#15		@ add offset to get the
	addle	r0,r0,#GPPULL0	@ address of the correct
	addgt	r0,r0,#GPPULL1	@ pull up/down register
	subgt	r3,#16		@ and adjust pin number
	mov	r3,r3,lsl #1	@ calculate shift amount

	ldr	r2,[r0]		@ read the register
	mov	r4,#0b11
	bic	r2,r2,r4,lsl r3 @ clear the field
	cmp	r1,#1
	moveq	r4,#0b10
	movgt	r4,#0b01
	orrgt	r2,r2,r4,lsl r3 @ set for pull-up
	str	r2,[r0]		@ write back to register
	
	ldmfd	sp!,{r0-r4}
	mov	pc,lr

@@@ void gpio_dir_input(int pcDuino_pin_num)
@@@ gpio_dir_input sets the pcDuino gpio pin specified in
@@@ r0 to be an input pin
gpio_dir_input:
	stmfd	sp!,{r0-r4}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpio0	@ load pointer to mapping table
	add	r3,r3,r0, lsl #3@ calculate pointer to table entry
	ldr	r4,[r3]		@ load port offset
	ldr	r3,[r3,#4]	@ load pin number

	ldr	r0,=gpiobase	@ load ptr to the address of the gpio device
	ldr	r0,[r0]		@ load address of the gpio device
	add	r0,r0,r4	@ add offset to base address of the port

	asr	r4,r3,#3	@ calculate offset to get the address 
	add	r0,r0,r4,lsl #2	@ of the correct cfg register
	and	r3,r3,#0b111	@ and adjust pin number
	mov	r3,r3,lsl #2	@ calculate shift amount

	ldr	r2,[r0]		@ read the register
	mov	r4,#0b111
	bic	r2,r2,r4,lsl r3 @ clear the field
	str	r2,[r0]		@ write back to register
	
	ldmfd	sp!,{r0-r4}
	mov	pc,lr

@@@ void gpio_dir_output(int pcDuino_pin_num)
@@@ gpio_dir_output sets the pcDuino gpio pin specified in
@@@ r0 to be an output pin
gpio_dir_output:
	stmfd	sp!,{r0-r4}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpio0	@ load pointer to mapping table
	add	r3,r3,r0, lsl #3@ calculate pointer to table entry
	ldr	r4,[r3]		@ load port offset
	ldr	r3,[r3,#4]	@ load pin number

	ldr	r0,=gpiobase	@ load ptr to the address of the gpio device
	ldr	r0,[r0]		@ load address of the gpio device
	add	r0,r0,r4	@ add offset to base address of the port

	asr	r4,r3,#3	@ calculate offset to get the address 
	add	r0,r0,r4,lsl #2	@ of the correct cfg register
	and	r3,r3,#0b111	@ and adjust pin number
	mov	r3,r3,lsl #2	@ calculate shift amount

	ldr	r2,[r0]		@ read the register
	mov	r4,#0b111
	bic	r2,r2,r4,lsl r3 @ clear the field
	mov	r4,#0b001
	orr	r2,r2,r4,lsl r3 @ set for output
	str	r2,[r0]		@ write back to register
	
	ldmfd	sp!,{r0-r4}
	mov	pc,lr

@@@ int gpio_read_pin(int pcDuino_pin_num)
@@@ gpio_read_pin returns the current state of the pcDuino gpio pin
@@@ specified
gpio_read_pin:
	stmfd	sp!,{r4}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpio0	@ load pointer to mapping table
	add	r3,r3,r0,lsl #3 @ calculate pointer to table entry
	ldr	r4,[r3]		@ load port offset
	ldr	r3,[r3,#4]	@ load pin number

	ldr	r0,=gpiobase	@ load ptr to the address of the gpio device
	ldr	r0,[r0]		@ load address of the gpio device
	add	r0,r0,r4	@ add offset to base address of the port
	
	add	r0,r0,#GPDAT	@ get address of data register
	ldr	r2,[r0]		@ read the register
	lsr	r0,r2,r3	@ shift correct bit to lsb
	and	r0,r0,#1	@ clear all other bits

	ldmfd	sp!,{r4}
	mov	pc,lr

@@@ void gpio_set_pin(int pcDuino_pin_num)
@@@ gpio_read_pin sets the current state of the pcDuino gpio pin
@@@ specified (the pin must be configured for output)
gpio_set_pin:
	stmfd	sp!,{r4}
	@@ Load the Base Address of the GPIO device
	ldr	r3,=gpio0	@ load pointer to mapping table
	add	r3,r3,r0, lsl #3@ calculate pointer to table entry
	ldr	r4,[r3]		@ load port offset
	ldr	r3,[r3,#4]	@ load pin number

	ldr	r0,=gpiobase	@ load ptr to the address of the gpio device
	ldr	r0,[r0]		@ load address of the gpio device
	add	r0,r0,r4	@ add offset to base address of the port
	
	add	r0,r0,#GPDAT	@ get address of data register
	ldr	r2,[r0]		@ read the register
	mov	r4,#1
	bic	r2,r2,r4,lsl r3 @ clear the bit
	orr	r2,r2,r1,lsl r3 @ give it the desired value
	str	r2,[r0]		@ write bits back to register

	ldmfd	sp!,{r4}
	mov	pc,lr

@@@ exit_func resets all pins to input and disables pull-up/down
exit_func:
	stmfd	sp!,{r0,lr}
	@@ Set the direction bits for the pins
	mov	r0,#2		@ Port 2
	bl	gpio_dir_input	@ set for input
	mov	r0,#3		@ Port 3
	bl	gpio_dir_input	@ set for input
	mov	r0,#4		@ Port 4
	bl	gpio_dir_input	@ set for input
	mov	r0,#5		@ Port 5
	bl	gpio_dir_input	@ set for input
	mov	r0,#6		@ Port 6
	bl	gpio_dir_input	@ set for input
	mov	r0,#7		@ Port 7
	bl	gpio_dir_input	@ set for input

	@@ enable pull-up resistors on input ports
	mov	r0,#2		@ Port 2	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	mov	r0,#3		@ Port 3	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	mov	r0,#4		@ Port 4	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	mov	r0,#5		@ Port 5	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	mov	r0,#6		@ Port 6	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	mov	r0,#7		@ Port 7	
	mov	r1,#0		@ Disable Pull-up/down
	bl	set_pud
	ldmfd	sp!,{r0,pc}
@@@ this function is called on interrupt (ctrl-c)
int_func:
	stmfd	sp!,{lr}
	mov	r0,#0
	bl	exit		@ call normal exit(0) function
	ldmfd	sp!,{pc}
	
@@@ main: configure pins, then watch the inputs and set the outputs
	.global	main
main:	stmfd	sp!,{r4,lr}

	ldr	r0,=exit_func	@ handle normal exit 
	bl	atexit		@ by shutting down ports
	mov	r0,#2		@ route interrupt signal (ctrl-c)
	ldr	r1,=int_func	@ through normal exit function
	bl	signal
	
	@@ map the devices into our address space
	bl	IO_init

	@@ Set the direction bits for the pins
	mov	r0,#2		@ Port 2
	bl	gpio_dir_input	@ set for input
	mov	r0,#3		@ Port 3
	bl	gpio_dir_input	@ set for input
	mov	r0,#4		@ Port 4
	bl	gpio_dir_input	@ set for input
	mov	r0,#5		@ Port 5
	bl	gpio_dir_output	@ set for output
	mov	r0,#6		@ Port 6
	bl	gpio_dir_output	@ set for output
	mov	r0,#7		@ Port 7
	bl	gpio_dir_output	@ set for output

	@@ enable pull-up resistors on input ports
	mov	r0,#2		@ Port 2	
	mov	r1,#2		@ Enable Pull-up
	bl	set_pud

	mov	r0,#3		@ Port 3	
	mov	r1,#2		@ Enable Pull-up
	bl	set_pud

	mov	r0,#4		@ Port 4	
	mov	r1,#2		@ Enable Pull-up
	bl	set_pud

	@@ Read the state of the buttons and
	@@ set the ouputs to the same state.
loop:
	mov	r0,#2		@ Pin 2
	bl	gpio_read_pin	@ read it
	mov	r1,r0		@ copy pin state to r1
	mov	r0,#5		@ set state of pin 5
	bl	gpio_set_pin

	mov	r0,#3		@ Pin 3
	bl	gpio_read_pin	@ read it
	mov	r1,r0		@ copy pin state to r1
	mov	r0,#6		@ set state of pin 6
	bl	gpio_set_pin

	mov	r0,#4		@ Pin 4
	bl	gpio_read_pin	@ read it
	mov	r1,r0		@ copy pin state to r1
	mov	r0,#7		@ set state of pin 7
	bl	gpio_set_pin

	b	loop

	ldmfd	sp!,{r4,pc}
