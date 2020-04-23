		
		#######################################################################
		# Important: do not put any other data before the frameBuffer         #
		# Also: the Bitmap Display tool must be connected to MARS and set to  #
		#   display width in pixels: 512				      #
		#   display height in pixels: 256                                     #
		#   base address for display: 0x10010000 (static data)                #
		#######################################################################
.data
frameBuffer: 	.space 0x80000
color: 		.word 0x00ff0000
.text

# drawing a rectangle; left x-coordinate is 100, width is 25
# top y-coordinate is 200, height is 50. Coordinate system starts with
# (0,0) at the display's upper left corner and increases to the right
# and down. 
li $a0,200	#y
li $a1,50	#height
li $a2,100	#x
li $a3,25	#length
jal rectangle
li $v0,10
syscall

rectangle:
# $a0 is xmin 
# $a1 is width 
# $a2 is ymin  
# $a3 is height 

beq $a1,$zero,rectangleReturn # zero width: draw nothing
beq $a3,$zero,rectangleReturn # zero height: draw nothing


lw $t0, color
la $t1,frameBuffer
add $a1,$a1,$a0 # simplify loop tests by switching to first too-far value
add $a3,$a3,$a2
li $t7, 200

sll $a0,$a0,2 # scale x values to bytes (4 bytes per pixel)
sll $a1,$a1,2
sll $a2,$a2,11 # scale y values to bytes (512*4 bytes per display row)
sll $a3,$a3,11
sll $t7, $t7, 11 #final end height for shape after movement


addu $t2,$a2,$t1 # translate y values to display row starting addresses
addu $a3,$a3,$t1
addu $a2,$t2,$a0 # translate y values to rectangle row starting addresses
addu $a3,$a3,$a0
addu $t2,$t2,$a1 # and compute the ending address for first rectangle row
addu $t7, $t7, $t1 #adds framebuffer to end height
addu $t7, $t7, $a0 #adds end height and y value
move $t5, $a2	#starting pixel
move $t6, $t2 	#end of row
li $t4,0x800 # bytes per display row

rectangleYloop:
move $t3,$a2 # pointer to current pixel for X loop; start at left edge

rectangleXloop:
sw $t0,($t3)
addiu $t3,$t3,4
bne $t3,$t2,rectangleXloop # keep going if not past the right edge of the rectangle

addu $a2,$a2,$t4 # advance one row worth for the left edge
addu $t2,$t2,$t4 # and right edge pointers
bne $a2,$a3,rectangleYloop # keep going if not off the bottom of the rectangle


rectangleAdjust:
move $s0, $t5
move $t3, $a2


drawLine:
li $v0, 32
la $a0, 5
SYSCALL

sw $t0,($t3) # draws new line
sw $zero, ($s0)	# erases old line
addiu $t3,$t3,4
addiu $s0, $s0, 4
bne $t3, $t2, drawLine

addu $a2,$a2,$t4 # advace one row worth for the left edge
addu $t2,$t2,$t4 # and right edge pointers
addu $t5, $t5,$t4 # moves top pointer down one line
bne $a2,$t7,rectangleAdjust # keep going if not off the bottom of the rectangle

rectangleReturn:
jr $ra
