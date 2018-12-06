	.data
	.align 2	
#Zapis tabel w zapisie stalo pozycyjnym gdzie dane slowo jest reprezentowane w postaci xx.xxx
angles:	.word 	#lookup	table /pi	
0x3243f6a8#00110010010000111111011010101000
0x1DAC6704#00011101101011000110011100000100
0x0FADBAFC#00001111101011011011101011111100
0x07F56EA4#00000111111101010110111010100100
0x03FEAB74#00000011111111101010101101110100
0x01FFD558#00000001111111111101010101011000
0x00FFFAA8#00000000111111111111101010101000
0x007FFF54#00000000011111111111111101010100
0x003FFFE8#00000000001111111111111111101000
0x001FFFFC#00000000000111111111111111111100
0x000fffff#00000000000011111111111111111111
0x0007ffff#00000000000001111111111111111111
0x0003ffff#00000000000000111111111111111111
0x0001ffff#00000000000000011111111111111111
0x0000ffff#00000000000000001111111111111111
0x00007fff#00000000000000000111111111111111

		.align 2
kvalues:	.word	#lookup	table
0x2D413CCC#00101101010000010011110011001100
0x287A26C4#00101000011110100010011011000100
0x2744C374#00100111010001001100001101110100
0x26F72280#00100110111101110010001010000000
0x26E3B580#00100110111000111011010110000000
0x26DED9F4#00100110110111101101100111110100
0x26DDA30C#00100110110111011010001100001100
0x26DD5550#00100110110111010101010101010000
0x26DD41E4#00100110110111010100000111100100
0x26DD3D08#00100110110111010011110100001000
0x26DD3BD0#00100110110111010011101111010000
0x26DD3B80#00100110110111010011101110000000
0x26DD3B70#00100110110111010011101101110000
0x26DD3B68#00100110110111010011101101101000
0x26DD3B68#00100110110111010011101101101000
0x26DD3B68#00100110110111010011101101101000

prompt:	.asciiz "Podaj wartosc pierwszego bajtu kodu w postaci xx.xxxxxx \n"
cos:	.asciiz "\ncos: "
sin:	.asciiz "\nsin: "
	
	.text
	.globl main
main:
	li $v0, 4 
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	
	move $t1, $v0		#set $t1 to value of beta 
	sll $t1, $t1, 24	#set $t1 xx.xxx...
	la $t8, angles		#adress of angles
	la $t9, kvalues		#addres of kvalues
	li $s1, 15 		#amount of iterations
	
#	$t0 - vector to work
#	$t7 - vector to work
#	$t1 - beta
#	$t2 - caount iterations
#	$t3 - poweroftwo 
#	$t4 - vector of sine
#	$t5 - vector of cosine
#	$t6 - angle
#	$s2- sigma
#	$s1 - N - amount of iterations


				#set all needed registers
cordic:	
	li $t2, 1 		#count iterations 
	li $t3, 1 	#set poweroftwo = 1.0
	sll $t3, $t3, 30
	li $t4, 0	#start with vector sine of 0
	li $t5, 1	#start with vector cosine of 1.0
	sll $t5, $t5 ,30
	lw $t6, ($t8) 	#load first angle
	li $s2, 1	#set sigma = 1
	sll $s2, $s2, 30
loop:	
	bgt $t2, $s1, end
	li $s2, 1	#set sigma = 1
	sll $s2, $s2, 30
	bge $t1, 0, continue	#if beta >= 0 
	neg $s2, $s2		#set sigma = -1
	#addi $t2, $t2, 1	#count iterations
	#main loop
	
continue:
	mul $t0, $s2, $t3	#sigma*poweroftwo
	mfhi $t0
	sll $t0, $t0, 2
	mul $t0, $t0, $t5
	mfhi $t0
	sll $t0, $t0, 2
	add $t7, $t0, $t4
	mul $t0, $s2, $t3	#sigma*poweroftwo
	mfhi $t0
	sll $t0, $t0, 2
	mul $t0, $t0, $t4
	mfhi $t0
	sll $t0, $t0, 2
	sub $t5, $t5, $t0
	move $t4, $t7
	mul $t0, $s2, $t6
	mfhi $t0
	sll $t0, $t0, 2
	sub $t1, $t1, $t0
	sra $t3, $t3, 1 	#poweroftwo = poweroftwo/2
	addi $t8, $t8, 4
	addi $t9, $t9, 4	#Przesuwanie sie po tablicy kvalues and angles
	lw $t6, ($t8)
	addi $t2, $t2, 1	#count iterations
	b loop

end:
	li $v0, 4
	la $a0, sin
	syscall
	lw $t0, ($t9)
	mul $t4, $t4, $t0
	mfhi $t4
	sll $t4, $t4, 2
	sra $t4, $t4, 24
	li $v0, 1
	move $a0, $t4
	syscall
	
	li $v0, 4
	la $a0, cos
	syscall
	lw $t0, ($t9)
	mul $t5, $t5, $t0
	mfhi $t5
	sll $t5, $t5, 2
	sra $t5, $t5, 24
	li $v0, 1
	move $a0, $t5
	syscall
	
	
	
	li $v0, 10
	syscall
