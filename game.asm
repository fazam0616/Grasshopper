# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
.eqv BASE_ADDRESS 0x10008000

#Defining platform types
.eqv PLATNOTH 0
.eqv PLATHEAL 1
.eqv PLATDMG 2
.eqv PLATFALL 2
.eqv PLATHOR 0
.eqv PLATVERT 1
.eqv PLATUPL 2
.eqv PLATUPR 3
.eqv PLATMV 2 #Defines the scalar value for what a single 


.eqv LENGTH 256
.eqv HEIGHT 256

.data
platforms:	.space	8

.text
.globl main
main:
	li $s0, BASE_ADDRESS # $t0 stores the base address for display
	li $s1, 0x32a89d # $t3 stores the blue colour code
	li $s2, 0xa86232 # $t3 stores the platform colour code
	
MAIN:	
	li $t0, 128
	li $t1, 128
	li $t2, PLATNOTH
	li $t3, PLATHOR
	li $t4, 6
	
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
	jal drwPlt
	
	j MAIN
	
drwPlt:	#Draws *entire* platform stored in a0
	#Retrieves platform data
	lw $a0, 0($sp)
	addi $sp, $sp, -4
	
	#Stores original $ra
	move $t4, $ra
	
	#Calculate current x,y pos
	jal pltX
	move $t0, $v0
	jal pltY
	move $t1, $v0
	
	jal pltFX
	li $t2, PLATMV
	mult $v0, $t2
	mflo $v0
	add $t0, $t0, $v0
	
	jal pltFY
	mult $v0, $t2
	mflo $v0
	add $t1, $t1, $v0
	
	#initialize pixel cursor pos
	li $v0, LENGTH
	li $t2, BASE_ADDRESS
	mult $t1, $v0
	mflo $v0
	add $t2, $t2, $v0
	add $t2, $t2, $t0
	
	jal pltLen
	li $t3, PLATMV
	mult $v0, $t3
	mflo $v0
	li $t3, 4
	mult $v0, $t3
	mflo $v0
	
	move $t3, $t2
	add $t3, $t3, $v0
drwPltLoop:
	bgt $t2, $t3, drwPltLoopEnd
	sw $s2, 0($t2)
	addi $t2, $t2, 4
	j drwPltLoop
drwPltLoopEnd:
	move $v0, $a0
	jr $t4

mkPlt:	#This function generates a platform at pos (a0, a1), with type a2, dir a3, len a4
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
	sll $t2,$t2,6 #Range should be 0 ~ 4
	sll $t3,$t3,4 #Range should be 0 ~ 4
	sll $t4,$t4,1 #Range should be 0 ~ 8
	
	or $t5, $t0, $t1
	or $t5, $t5, $t2
	or $t5, $t5, $t3
	or $t5, $t5, $t4
	ori $t5, $t5, 1
	move $v0, $t5
	jr $ra

pltLen:	#Return platform length
	srl $v0, $a0, 1
	andi $v0, 7 #Mask to remove irrelevant data
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

getPC:	#Get current pc value
	move $v0, $ra
	jr $ra

QUIT:	li $v0, 10
	syscall
