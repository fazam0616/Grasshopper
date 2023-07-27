# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
.eqv BASE_ADDRESS 0x10008000

#Defining platform types
.eqv PLATHOR 0
.eqv PLATVERT 1
.eqv PLATUPL 2
.eqv PLATUPR 3
.eqv PLATMV 1 #Defines the scalar value for what a single unit length/offset represents


.eqv LENGTH 256
.eqv HEIGHT 256

.data
platforms:	.space	8

.text
.globl main
main:
	li $s0, BASE_ADDRESS # $t0 stores the base address for display
	li $s1, 0x32a89d # $s1 stores the blue colour code
	li $s2, 0xa86232 # $s2 stores the platform colour code
	li $s3, LENGTH
	li $s4, HEIGHT
	
	move $a0, $s1
	
	jal fillScrn
			
	li $t0, 10	#X pos
	li $t1, 35	#Y pos
	li $t2, 0	#Current Dir
	li $t3, PLATHOR	#Movement Type
	li $t4, 5	#Length
	
	addi $sp, $sp, 4
	sw $t0, 0($sp)
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4
	sw $t4, 0($sp)
	
	jal mkPlt
	
	move $t0, $v0
	move $a0, $t0
	
	move $a1, $s2
	jal drwPlt
MAIN:	
	move $a0 $v0
	jal updtPlt
	#jal mvPltR
	move $a0, $v0
	j MAIN
	j QUIT
	
updtPlt:#Updates platfrom position, and does partial redraws
	move $s4, $ra
	jal pltMv
	move $t1 $v0
	
	li $t0, PLATHOR
	beq $t1, $t0 updtH
	
	li $t0, PLATVERT
	beq $t1, $t0, updtV
	
	li $t0, PLATUPL
	beq $t1, $t0, updtUL
	
	li $t0, PLATUPR
	beq $t1, $t0, updtUR
updtH:
	jal pltFX
	move $t0, $v0
	li $t1, 15
	beqz $t0, updtFlipH
	beq $t0, $t1 updtFlipH
	j updtHPos
updtFlipH:
	li $t1, 128		#Get mask for dir flag
	xor $a0, $a0, $t1
updtHPos:
	li $t1, 128		#Get mask for dir flag
	and $t1, $a0, $t1	#Extract dir flag 
	beqz $t1, updtL
	jal mvPltR
	j updtEND
updtL:
	jal mvPltL
	j updtEND
updtV:
updtUL:
updtUR:
updtEND:
	jr $s4
	
drwPlt:	#Draws *entire* platform stored in a0, w/ colour stored in a1
	#Retrieves platform data
	#lw $a0, 0($sp)
	#addi $sp, $sp, -4
	
	#Stores original $ra
	move $t4, $ra
	
	#Calculate current x,y pos
	jal pltTX
	li $t1, 4
	mult $v0, $t1
	mflo $t3
	
	jal pltTY
	move $t1, $v0
	move $t0, $t3
	
	#initialize pixel cursor pos
	li $v0, LENGTH
	li $t2, BASE_ADDRESS
	mult $t1, $v0
	mflo $v0
	add $t0, $t0, $v0
	add $t0, $t0, $t2
	
	jal pltLen
	li $t3, PLATMV
	mult $v0, $t3
	mflo $v0
	li $t3, 4
	mult $v0, $t3
	mflo $v0
	
	move $t3, $a0
	
	move $a0, $t0
	move $a2, $a1
	move $a1, $v0
	
	jal fill
	
	move $v0, $t3
	jr $t4

fillScrn:#Fill whole screen w/ colour in a0
	move $t0, $s0
	mult $s3, $s4
	mflo $t1
	div $t1, $t1 4
	add $t1, $t1, $s0
flScrnLoop:
	bgt $t0, $t1, flScrEnd
	sw $a0, 0($t0)
	addi $t0, $t0, 4
	j flScrnLoop
flScrEnd:
	jr $ra

fill:	#Fills from $a0 to ($a0+$a1) with colour $a2
	move $t0, $a1
	add $t0, $t0, $a0
fillLoop:
	bgt $a0, $t0, fillLoopEnd
	sw $a2, 0($a0)
	#addi $a0, $a0, 32768
	addi $a0, $a0, 4
	j fillLoop
fillLoopEnd:
	jr $ra

mkPlt:	#This function generates a platform at pos (a0, a1), with direction a2, dirtype a3, len a4
	lw $t4, 0($sp)
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $t0, 0($sp)
	addi $sp, $sp, -4
	
	move $t5, $zero
	sll $t0,$t0,24 #Range should be 0 ~ 256
	sll $t1,$t1,16 #Range should be 0 ~ 256
	sll $t2,$t2,7 #Range should be 0 ~ 1
	sll $t3,$t3,5 #Range should be 0 ~ 4
	sll $t4,$t4,1 #Range should be 0 ~ 16
	
	or $t5, $t0, $t1
	or $t5, $t5, $t2
	or $t5, $t5, $t3
	or $t5, $t5, $t4
	ori $t5, $t5, 1
	move $v0, $t5
	jr $ra

#This set of functions will save positions in $t5
mvPltU:
	li $t0, -1
	sll $t0, $t0, 8
	add $a0, $a0, $t0
	move $v0, $a0
	jr $t5

mvPltL:
	move $t5, $ra #Storing caller pos
	
	#Set new left-end to platform
	jal pltTX
	move $t0, $v0
	li $t1, 4
	mult $t0, $t1
	mflo $t0
	add $t4, $t0, $s0
	
	jal pltTY
	move $t1, $v0
	mult $t1, $s3
	mflo $t1
	add $t4, $t4, $t1	
	
	move $t6, $a0
	move $a0, $t4
	li $a1, PLATMV
	li $a2, 4
	mult $a1, $a2
	mflo $a1
	move $a2, $s2
	sub $a0, $a0, $a1 #Offset in left direction
	
	jal fill
	
	move $a0, $t6
	
	#Set old right-end to nothing
	jal pltLen
	move $t1, $v0
	li $v0, PLATMV
	mult $t1, $v0
	mflo $t1
	li $v0, 4
	mult $t1, $v0
	mflo $t1
	add $t4, $t4, $t1
	
	move $a0, $t4
	li $a1, PLATMV
	li $t3, 4
	mult $a1, $t3
	mflo $a1
	move $a2, $s1
	sub $a0, $a0, $a1 #Offset in left direction
	
	jal fill
	move $a0, $t6
	
	#Update offset position
	li $t0, 1
	sll $t0, $t0, 12
	sub $a0, $a0, $t0
	move $v0, $a0
	jr $t5

mvPltR:
	move $t5, $ra #Storing caller pos
	
	#Set old left-end to nothing
	jal pltTX
	move $t0, $v0
	li $t1, 4
	mult $t0, $t1
	mflo $t0
	add $t4, $t0, $s0
	
	jal pltTY
	move $t1, $v0
	mult $t1, $s3
	mflo $t1
	add $t4, $t4, $t1	
	
	move $t6, $a0
	move $a0, $t4
	li $a1, PLATMV
	li $a2, 4
	mult $a1, $a2
	mflo $a1
	move $a2, $s1
	
	jal fill
	
	move $a0, $t6
	
	#Set new right-end to platform
	jal pltLen
	move $t1, $v0
	li $v0, PLATMV
	mult $t1, $v0
	mflo $t1
	li $v0, 4
	mult $t1, $v0
	mflo $t1
	add $t4, $t4, $t1
	
	move $a0, $t4
	li $a1, PLATMV
	li $t3, 4
	mult $a1, $t3
	mflo $a1
	move $a2, $s2
	
	jal fill
	move $a0, $t6
	
	#Update offset position
	li $t0, 1
	sll $t0, $t0, 12
	add $a0, $a0, $t0
	move $v0, $a0
	jr $t5

mvPltD:
	li $t0, 1
	sll $t0, $t0, 8
	add $a0, $a0, $t0
	move $v0, $a0
	jr $ra

pltMv:	#Return platform movement type
	srl $v0, $a0, 5
	andi $v0, 3 #Mask to remove irrelevant data
	jr $ra	

pltLen:	#Return platform length
	srl $v0, $a0, 1
	andi $v0, 15 #Mask to remove irrelevant data
	jr $ra	

pltFX:	#Return platform x offset
	srl $v0, $a0, 12
	andi $v0, 15 #Mask to remove irrelevant data
	jr $ra
	
pltFY:	#Return platform y offset
	srl $v0, $a0, 8
	andi $v0, 15 #Mask to remove irrelevant data
	jr $ra
	
pltX:	#Return platform start x
	srl $v0, $a0, 24
	jr $ra

pltY:	#Return platform start y	
	srl $v0, $a0, 16
	andi $v0, 255 #Mask to remove irrelevant data
	jr $ra	

pltTX:
	move $t0, $ra
	jal pltX
	move $t1, $v0
	jal pltFX
	li $t2, PLATMV
	mult $v0, $t2
	mflo $v0
	add $v0, $t1, $v0
	jr $t0

pltTY:
	move $t0, $ra
	jal pltY
	move $t1, $v0
	jal pltFY
	li $t2, PLATMV
	mult $v0, $t2
	mflo $v0
	add $v0, $t1, $v0
	jr $t0

getPC:	#Get current pc value
	move $v0, $ra
	jr $ra

QUIT:	li $v0, 10
	syscall
