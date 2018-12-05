	.data
	.align 2	
#Zapis tabel w zapisie stalo pozycyjnym gdzie dane slowo jest reprezentowane w postaci xxxx.xxx
angles:	.word 	#lookup	table	
00001100100100001111110110101010	
00000111011010110001100111000001
00000011111010110110111010111111
00000001111111010101101110101001
00000000111111111010101011011101
00000000011111111111010101010110
00000000001111111111111010101010
00000000000111111111111111010101
00000000000011111111111111111010
00000000000001111111111111111111
00000000000000111111111111111111
00000000000000011111111111111111
00000000000000001111111111111111
00000000000000000111111111111111
00000000000000000011111111111111
00000000000000000001111111111111

		.align 2
kvalues:	.word	#lookup	table
00001011010100000100111100110011
00001010000111101000100110110001
00001001110100010011000011011101
00001001101111011100100010100000
00001001101110001110110101100000
00001001101101111011011001111101
00001001101101110110100011000011
00001001101101110101010101010100
00001001101101110101000001111001
00001001101101110100111101000010
00001001101101110100111011110100
00001001101101110100111011100000
00001001101101110100111011011100
00001001101101110100111011011010
00001001101101110100111011011010
00001001101101110100111011011010

	.align 2
const:	.word
00110010010000111111011010101000	#	pi xxxx.xxx...
00011001001000011111101101010100	#	pi/2 xxxx.xxx...
11100110110111100000010010101100	#	-pi/2 xxxx.xxx...
beta:	.space	8

prompt:	.asciiz "Podaj kat w radianach\n"
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
	sll $t1, $t1, 28	#set $t1 xxxx.xxx...
	la $t8, angles		#adress of angles
	la $t9, kvalues		#addres of kvalues
	la $s2, const
	li $t0, 15 		#amount of iterations
	li $t5, 1 	#vector
	
				#checkangle
findangle:	
	lw $t2, 8($s2)
	blt $t1, $t2, addpi	#if beta < -pi/2 we need to add pi
	lw $t2, 4($s2)
	bgt $t1, $t2, subpi		#if beta > pi/2 we need to sub pi
	b cordic 		#good angle start CORDIC algorythm

addpi:
	lw $t2, ($s2)
	add $t1, $t1, $t2
	neg $t5, $t5 #negation
	b findangle
subpi:
	lw $t2, ($s2)
	add $t1, $t1, $t2
	neg $t5, $t5 #negation
	b findangle
	
#	$t0 - vector to work
#	$t7 - vector to work
#	$t1 - beta
#	$t2 - caount iterations
#	$t3 - poweroftwo 
#	$t4 - vector of sine
#	$t5 - vector of cosine
#	$t6 - angle
#	$s2- sigma
#	$s0 - negation
#	$s1 - N - amount of iterations


				#set all needed registers
cordic:	
	move  $s0, $t5
	li $t2, 1 		#count iterations 
	li $t3, 1 	#set poweroftwo = 1.0
	sll $t3, $t3, 28
	li $t4, 0	#start with vector sine of 0
	li $t5, 1	#start with vector cosine of 1.0
	sll $t5, $t5 ,28
	lw $t6, ($t8) 	#load first angle
	li $s2, 1	#set sigma = 1
	sll $s2, $s2, 28
loop:	
	bgt $t2, $t0, end
	li $s2, 1	#set sigma = 1
	sll $s2, $s2, 28
	blt $t1, 0, continue		#if beta < 0 
	neg $s2, $s2	#set sigma = -1
	addi $s2, $s2, 1
	#main loop
	
continue:
	mul $t0, $s2, $t3	#sigma*poweroftwo
	mul $t0, $t0, $t5
	add $t7, $t0, $t4
	mul $t0, $s2, $t3	#sigma*poweroftwo
	mul $t0, $t0, $t4
	sub $t5, $t5, $t0
	move $t4, $t7
	mul $t0, $s2, $t6
	sub $t1, $t1, $t0
	sra $t3, $t3, 1 #poweroftwo = poweroftwo/2
	addi $t8, $t8, 4
	addi $t9, $t9, 4	#Przesuwanie sie po tablicy kvalues and angles
	lw $6, ($t8)
	addi $t2, $t2, 1
	b loop

end:
	lw $t0, ($t9)
	mul $t4, $t4, $0
	mul $t4, $t4, $s2 # negacja
	
	
	li $v0, 1
	move $a0, $t4
	syscall
	
	
	li $v0, 10
	syscall
