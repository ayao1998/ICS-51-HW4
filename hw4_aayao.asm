# Aaron Yao
# aayao

.include "hw4_helpers.asm"

.text

##########################################
#  Part #1 Functions
##########################################
initBoard:
	# each cell of the display is specified by a half-word (2 bytes) the 
	#lower byte contains the ascii character to be displayed at the cell position
	#upper byte contains th ebackground and foreground color information for the cell
	# 8 rows 8 columns half word ( 2 bytes per sq)
	# mmio bytes starts at 0xffff0000 to 0xffff007f for the 8x8 board
	
	#$a0 = fg which is byte, foreground color
	# $a1 = darkbg which is byte for dark squares
	#$a2 = lightbg which is byte for light squares
	
	#need 1 byte for dark color squares
	#need 1 byte for light color squares
	#need 1 byte for E

	addi $sp $sp, -4
	sw $ra, 0($sp)
	
	sll $a1, $a1, 4 #dark bg shifted to bits 4-7
	sll $a0, $a0, 4 #shift fg 
	srl $a0, $a0, 4 #shift back to get all 0's
	add $a1, $a1, $a0 # add fg foreground color to last 
	
	sll $a2, $a2, 4 #shift light bg to bits 4-7
	add $a2, $a2, $a0 #add fg foreground color to last 4 bits
	
	li $t0, 0xffff0000 #starting address of board
	li $t2, 'E'
	li $t3, 0 #flip color order
	
	li $t1, 0 #counter
boardInitA:
	li $t3, 0
loopA:
	beq $t1, 32, setupDone
	beq $t3, 4, boardInitB
	sb $t2, ($t0) #save the E char
	addi $t0, $t0, 1 #increment address
	sb $a2, ($t0) # store the light color
	addi $t0, $t0, 1 #increment address
	sb $t2, ($t0) #save the E char
	addi $t0, $t0, 1 #increment address
	sb $a1, ($t0) #dark char
	addi $t0, $t0, 1 #increment address
	
	addi $t3, $t3 1 #color flip counter
	
	addi $t1, $t1, 1 #incrment count
	j loopA
	
boardInitB:
	li $t3, 0 #reset color flip counter
loopB:
	beq $t1, 32, setupDone
	beq $t3, 4, boardInitA
	sb $t2, ($t0) #save the E char
	addi $t0, $t0, 1 #increment address
	sb $a1, ($t0) # store the dark color
	addi $t0, $t0, 1 #increment address
	sb $t2, ($t0) #save the E char
	addi $t0, $t0, 1 #increment address
	sb $a2, ($t0) #light char
	addi $t0, $t0, 1 #increment address
	
	addi $t3, $t3 1 #color flip counter
	
	addi $t1, $t1, 1 #incrment count
	j loopB
	
setupDone:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

setSquare:
	# $a0 = int row
	# $a1 = int col
	# $a2 = char piece
	# $a3 = int player
	# stack: byte fg
	#prologue
	
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	lb $s0, 8($sp) #put foreground color into $s0

	#error checking
	bgt $a0, 7, errorInput
	blt $a0, 0, errorInput
	bgt $a1, 7, errorInput
	blt $a1, 0, errorInput
	bgt $a3, 2, errorInput
	blt $a3, 1, errorInput
	bgt $s0, 15, errorInput
	
	li $t9, 0xffff0000 #chess board address
	li $t0, 8
	mul $a0, $a0, $t0 #multply rows by 8 
	add $a0, $a0, $a1 #add to colmuns 
	li $t0, 2
	mul $a0, $a0, $t0 #multiply by 2 since were doing halfword, not byte
	add $a0, $a0, $t9 # get the address of the square
	sb $a2, ($a0) #store at the address
	addi $a0, $a0, 1  #move to next byte to change foreground color
	lb $t3, ($a0) #get byte
	srl $t3, $t3, 4 #get rid of the bottom 4 bits
	sll $t3, $t3, 4
	beq $a2, 'E', empty #check if empty char
	
	beq $a3, 1, white #check if white or black player
	li $s0, 0 #set black otherwise
	j empty
white:
	li $s0, 0xF
empty:
	add $t3, $t3, $s0 #add foreground color
	sb $t3, ($a0) #store color
	li $v0, 0 #success return value
	j epilogueSS
errorInput:
	li $v0, -1
	
epilogueSS:
	#epilogue
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

initPieces:
	addi $sp, $sp, -16
	sw $sp, 4($sp)
	sw $ra, 8($sp)
	sw $s0, 12($sp)

	li $a0, 0
	li $a1, 0
	li $a2, 'R'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 1
	li $a2, 'H'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 2
	li $a2, 'B'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 3
	li $a2, 'Q'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 4
	li $a2, 'K'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 5
	li $a2, 'B'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 6
	li $a2, 'H'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 0
	li $a1, 7
	li $a2, 'R'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare

	li $s0, 0
setPawns:
	beq $s0, 8, setPawns2
	li $a0, 1
	move $a1, $s0
	li $a2, 'p'
	li $a3, 2
	li $t0, 0
	sb $t0, 0($sp)
	jal setSquare
	addi $s0, $s0, 1
	j setPawns
setPawns2:
	li $s0, 0
whitePawns:
	beq $s0, 8, setWhite
	li $a0, 6
	move $a1, $s0
	li $a2, 'p'
	li $a3, 1
	li $t0, 1
	sb $t0, 0($sp)
	jal setSquare
	addi $s0, $s0, 1
	j whitePawns
	
setWhite:
	
	li $a0, 7
	li $a1, 0
	li $a2, 'R'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 1
	li $a2, 'H'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 2
	li $a2, 'B'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 3
	li $a2, 'Q'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 4
	li $a2, 'K'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 5
	li $a2, 'B'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 6
	li $a2, 'H'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
	
	li $a0, 7
	li $a1, 7
	li $a2, 'R'
	li $a3, 1
	li $t0, 0xF
	sb $t0, 0($sp)
	jal setSquare
		

	lw $sp, 4($sp)
	lw $ra, 8($sp)
	lw $s0, 12($sp)
	addi $sp, $sp, 16
	jr $ra

mapChessMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	blt $a0, 65, inputFail
	bgt $a0, 72, inputFail
	blt $a1, 49, inputFail
	bgt $a1, 56, inputFail
	li $t0, 48
	div $a1, $t0
	mfhi $v0
	li $t0, 8
	sub $v0, $t0, $v0
	sll $v0, $v0, 8
	li $t0, 65
	div $a0, $t0
	mfhi $t0
	add $v0, $v0, $t0
	j moveMapped
	
inputFail:
	li $v0, 0xFFFF
moveMapped:
	sw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

loadGame:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	
	
	li $s1, 0 #black counter
	li $s2, 0 # white counter
	
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall

	bltz $v0, cantOpen

	move $s0, $v0 # save the file descriptor
readIn:
	move $a0, $s0 #file descriptor for syscall 14
	move $a1, $sp #stack for buffer
	li $a2, 5 # 1 piece at a time
	li $v0, 14
	syscall

	#check $v0 at this point
	beqz $v0, fileDone #reached end of file
	#may need to handle negative case

	#string will have format 1pC4 - 0sp 1sp 2sp 3sp
	
	#need to map chess move next
	lb $a0, 2($sp) #letter
	lb $a1, 3($sp) #number
	jal mapChessMove
	sh $v0, 4($sp) # move result is on stack as  row, col
	lb $a0, 5($sp) #row
	lb $a1, 4($sp) #col
	lb $a2, 1($sp) #piece
	lb $a3, 0($sp) # ASCII representation of 0 or 1
	addi $a3, $a3, -48 #to get 0 or 1
	addi $sp, $sp, -4
	beq $a3, 2, blackPiece
	addi $s2, $s2, 1 #increment counter 
	j whitePiece
blackPiece:
	addi $s1, $s1, 1 #increment counter
whitePiece:
	li $t0, 0x2 #random fg color
	sb $t0, 0($sp)
	jal setSquare
	addi $sp, $sp, 4
	j readIn

cantOpen:
	li $v0, -1
	li $v1, -1
	j epilogueE

fileDone:
	li $v0, 16
	move $a0, $s0 #file descriptor
	syscall

	move $v0, $s2 #number of white pieces
	move $v1, $s1 # number of black pieces

epilogueE:
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 24
	jr $ra
	

##########################################
#  Part #2 Functions
##########################################

getChessPiece:
	#each square is structured as : piece (char) and fg color (byte/int) 
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	
	
	sh $a0, 0($sp)
	lbu $t1, 1($sp) # row
	lbu $t2, 0($sp) # column
	
	li $t0, 8
	mul $t1, $t1, $t0 # row *8
	add $t1, $t2, $t1 # row*8 + col
	
	li $t0, 2
	mul $t1, $t1, $t0 # (row*8+col)*2 bc of halfword
	
	addi $t1, $t1, 0xffff0000 # sp address + (row*8+col)*2
	
	lbu $v0, 0($t1) # piece (char)
	beq $v0, 'E', emptySq #check if empty square
	lbu $v1, 1($t1) # fgcolor(int) 
	li $t5, 1
	and $v1, $v1, $t5 #to get just a 0 or a f, since fg color is lower 4 bits and bg is higher 4 bits
	beqz $v1, pieceBlack
	li $v1, 1 #white value
	j epilogueF
pieceBlack:
	li $v1, 2 #black value
	j epilogueF
emptySq:
	li $v0, 'E'
	li $v1, -1
epilogueF:
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

validBishopMove:
	# (int,char) validBishopMove(short from, short to, int player, short& capture)
	
	#1. prologue
	#2. error checking
	# 	decode from and to from their 2 byte values into registers.
	#2a. check if from = to. return error if true
	#2b. check if its a legal diagonal move
	#2c. check if there is a piece in the way between from and to
	#2d. check if player's piece is in to
	#3. check if to is empty or to has enemy piece in it.
	#4. do return value stuff
	#5. epilogue
	
	#PROLOGUE
	addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s0, 32($sp)
	sw $s1, 28($sp)
	sw $s2, 24($sp)
	sw $s3, 20($sp)
	sw $s4, 16($sp)
	sw $s5, 12($sp)
	sw $s6, 8($sp)
	#decode from and to
	# $a0 = from
	# $a1 = to
	move $s6, $a1
	move $s5, $a3
	move $s4, $a2
	bgt $a2, 2, invalidInput #checking if player is valid
	blt $a2, 1, invalidInput
	
	beq $a0, $a1, invalidMove #branch if $a0 = $a1 since they're same position
	sh $a0, 0($sp) #from
	sh $a1, 4($sp) #to
	lb $s0, 0($sp) #should be from row
	lb $s1, 1($sp) #should be from col
	lb $s2, 4($sp) #should be to row
	lb $s3, 5($sp) #should be to col
	
	#split into cases: forwards and backwards
	#first check if the move will be on the board
	#also check validity of inputs
	
	bgt $s0, 7, invalidInput
	blt $s0, 0, invalidInput
	bgt $s1, 7, invalidInput
	blt $s1, 0, invalidInput
	bgt $s2, 7, invalidInput
	blt $s2, 0, invalidInput
	bgt $s3, 7, invalidInput
	blt $s3, 0, invalidInput
	
	#a diagonal move always changes the same amount in both x and y direction
	sub $t0, $s0, $s2 # t0 = s0-s2 (rows)
	sub $t1, $s1, $s3 # t1 = s1-s3 (cols)
	mul $t2, $t0, $t0 #square to eliminate neg
	mul $t3, $t1, $t1 #square 
	bne $t2, $t3, invalidMove #if they're not equal then the move is not diagonal
	
	#check if player's piece is in to
	move $a0, $s6 #put to into register, may need to preserve $a0 somewhere
	jal getChessPiece
	beq $v1, $s4, invalidMove #if player # is the same in to, move is invalid.

	#determine which direction move is in
	bgt $s0, $s2, forwards#from row is greater than to row, move is forwards
	#otherwise move is backwards
	bgt $s1, $s3, backLeft#from col is greater than to col, move is left
	#if you reach here the the move is backwards to the right
#BACK RIGHT
	#increment both row and col until to coordinates are found
	#at each set of coordinates check for non 'E' char
	addi $s0, $s0, 1
	addi $s1, $s1, 1
backRightLoop:
	beq $s0, $s2, validBish
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidMove #move is invalid if square does not contain E
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	j backRightLoop
	
backLeft:
	#increment both row and col until to coordinates are found
	#at each set of coordinates check for non 'E' char
	addi $s0, $s0, 1
	addi $s1, $s1, -1
backLeftLoop:
	beq $s0, $s2, validBish
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidMove #move is invalid if square does not contain E
	addi $s0, $s0, 1
	addi $s1, $s1, -1
	j backLeftLoop
	
forwards:
	bgt $s1, $s3, forwardsLeft
	#if you reach here the move is forwards to the right
#FORWARDS RIGHT
	#increment both row and col until to coordinates are found
	#at each set of coordinates check for non 'E' char
	addi $s0, $s0, -1
	addi $s1, $s1, 1
forwardsRightLoop:
	beq $s0, $s2, validBish
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidMove #move is invalid if square does not contain E
	addi $s0, $s0, -1
	addi $s1, $s1, 1
	j forwardsRightLoop
	
forwardsLeft:
	#increment both row and col until to coordinates are found
	#at each set of coordinates check for non 'E' char
	addi $s0, $s0, -1
	addi $s1, $s1, -1
forwardsLeftLoop:
	beq $s0, $s2, validBish
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidMove #move is invalid if square does not contain E
	addi $s0, $s0, -1
	addi $s1, $s1, -1
	j forwardsLeftLoop
	
invalidInput:
	li $v0, -2
	li $v1, '\0' 
	j epilogueG
invalidMove:
	li $v0, -1
	li $v1, '\0' 
	j epilogueG
validBish:	
	#check if enemy piece is in the space
	move $a0, $s6
	jal getChessPiece
	beq $s4, 1, whiteChoices
	#if youre here then player is black, need to figure out if getchessPiece returned -1 or 2
	bne $v1, 1, noCap #if its not the opposite 
	j cap
whiteChoices:
	bne $v1, 2, noCap #player is white, if piece is no black then no capture
	j cap #cap may not be necessary
noCap:	
	li $v0, 0
	li $v1, '\0'
	j epilogueG
cap:
	#store capture location in address
	sh $s6, 0($s5) #s6 is to, $s5 is address
	move $v1, $v0
	li $v0, 1
epilogueG:
	lw $ra, 36($sp)
	lw $s0, 32($sp)
	lw $s1, 28($sp)
	lw $s2, 24($sp)
	lw $s3, 20($sp)
	lw $s4, 16($sp)
	lw $s5, 12($sp)
	lw $s6, 8($sp)
	addi $sp, $sp, 40
	jr $ra

validRookMove:
	
	#PROLOGUE
	addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s0, 32($sp)
	sw $s1, 28($sp)
	sw $s2, 24($sp)
	sw $s3, 20($sp)
	sw $s4, 16($sp)
	sw $s5, 12($sp)
	sw $s6, 8($sp)
	#decode from and to
	# $a0 = from
	# $a1 = to
	move $s6, $a1
	move $s5, $a3
	move $s4, $a2
	bgt $a2, 2, invalidRookInput #checking if player is valid
	blt $a2, 1, invalidRookInput
	
	beq $a0, $a1, invalidRookMove #branch if $a0 = $a1 since they're same position
	sh $a0, 0($sp) #from
	sh $a1, 4($sp) #to
	lb $s0, 0($sp) #from col
	lb $s1, 1($sp) #from row
	lb $s2, 4($sp) #to col
	lb $s3, 5($sp) #to row
	
	bgt $s0, 7, invalidRookInput
	blt $s0, 0, invalidRookInput
	bgt $s1, 7, invalidRookInput
	blt $s1, 0, invalidRookInput
	bgt $s2, 7, invalidRookInput
	blt $s2, 0, invalidRookInput
	bgt $s3, 7, invalidRookInput
	blt $s3, 0, invalidRookInput
	
	move $a0, $s6 #put to into register, may need to preserve $a0 somewhere
	jal getChessPiece
	beq $v1, $s4, invalidRookMove #if player # is the same in to, move is invalid.
	
	#a straight move always changes in only 1 direction
	sub $t0, $s0, $s2 # t0 = s0-s2 (rows)
	sub $t1, $s1, $s3 # t1 = s1-s3 (cols)
	beqz $t0, fb #forwards and backwards
	beqz $t1, lr #left and right
	bne $t2, $t3, invalidRookMove #if both are nonzero, the move is invalid
	
lr:
	bgt $s0, $s2, leftRook#from col is greater than to col, move is left
	#otherwise, move is right
	addi $s0, $s0, 1
rrLoop:
	beq $s0, $s2, validRook
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidRookMove #move is invalid if square does not contain E
	addi $s0, $s0, 1
	j rrLoop
	
leftRook:
	addi $s0, $s0, -1
lrLoop:
	beq $s0, $s2, validRook
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidRookMove #move is invalid if square does not contain E
	addi $s0, $s0, -1
	j lrLoop
fb:
	bgt $s1, $s3, forwardsRook#from row is greater than to row, move is forward
	#if you reach here the the move is backward
	addi $s1, $s1, 1
brLoop:
	beq $s1, $s3, validRook
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidRookMove #move is invalid if square does not contain E
	addi $s1, $s1, 1
	j brLoop
forwardsRook:
	#increment both row and col until to coordinates are found
	#at each set of coordinates check for non 'E' char
	addi $s1, $s1, -1
frLoop:
	beq $s1, $s3, validRook
	sll $a0, $s1, 8
	add $a0, $a0, $s0 #creating short for getChessPiece 
	jal getChessPiece
	bne $v0, 'E', invalidRookMove #move is invalid if square does not contain E
	addi $s1, $s1, -1
	j frLoop
	
invalidRookInput:
	li $v0, -2
	li $v1, '\0' 
	j epilogueH
invalidRookMove:
	li $v0, -1
	li $v1, '\0' 
	j epilogueH
validRook:	
	#check if enemy piece is in the space
	move $a0, $s6
	jal getChessPiece
	beq $s4, 1, whiteRookChoices
	#if youre here then player is black, need to figure out if getchessPiece returned -1 or 2
	bne $v1, 1, noRookCap #if its not the opposite 
	j rookCap
whiteRookChoices:
	bne $v1, 2, noCap #player is white, if piece is no black then no capture
	j cap #cap may not be necessary
noRookCap:	
	li $v0, 0
	li $v1, '\0'
	j epilogueH
rookCap:
	#store capture location in address
	sh $s6, 0($s5) #s6 is to, $s5 is address
	move $v1, $v0
	li $v0, 1
epilogueH:
	lw $ra, 36($sp)
	lw $s0, 32($sp)
	lw $s1, 28($sp)
	lw $s2, 24($sp)
	lw $s3, 20($sp)
	lw $s4, 16($sp)
	lw $s5, 12($sp)
	lw $s6, 8($sp)
	addi $sp, $sp, 40
	jr $ra
	jr $ra

perform_move:
	# (int,char) perform_move(int player, short from, short to, byte fg, short& king_pos)
	
	#prologue
	#get chess piece at from position
	#check if piece and player match, otherwise error
	# use valid move function depending on the piece. possible error 
	# put the piece at the TO if valid (if pawn use P instead of p)
	# delete the from position
	#if king moved, save onto stack new spot
	#return values
	
	# $a0 = player
	# $a1 = short from
	# $a2 = short to
	# $a3 = byte fg
	
	addi $sp, $sp, -56
	sw $ra, 52($sp)
	sw $s0, 48($sp)
	sw $s1, 44($sp)
	sw $s2, 40($sp)
	sw $s3, 36($sp)
	sw $s4, 32($sp)
	sw $s5, 28($sp)
	sw $s6, 24($sp)
	sw $s7, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	
	#check inputs for player, from and to
	bgt $s0, 2, inputBad
	blt $s0, 1, inputBad
	
	#break apart from and to to check them
	sh $a1, 4($sp) #from
	sh $a2, 8($sp) #to
	lb $s5, 4($sp) #from col
	lb $s4, 5($sp) #from row
	lb $s7, 8($sp) #to col
	lb $s6, 9($sp) #to row

	#making sure inputs are good
	bgt $s4, 7, inputBad
	blt $s4, 0, inputBad
	bgt $s5, 7, inputBad
	blt $s5, 0, inputBad
	bgt $s6, 7, inputBad
	blt $s6, 0, inputBad
	bgt $s7, 7, inputBad
	blt $s7, 0, inputBad

	move $a0, $a1 #need short from to call getChessPiece, checking what piece is being moved
	jal getChessPiece #returns char piece and int player
	beq $v0, 'E', inputBad #no piece at this square
	bne $v1, $s0, inputBad #wrong player 
	#inputs should be good at this point
	
	#branch based on what the piece is
	
	move $a0, $s1 #from
	move $a1, $s2 #to
	move $a2, $s0 #player
	addi $a3, $sp, 4 #stack address, dont really need sp+4 or sp+8 anymore
	
	beq $v0, 'R', rookMove
	beq $v0, 'H', knightMove
	beq $v0, 'B', bishopMove
	beq $v0, 'Q', queenMove
	beq $v0, 'K', kingMove
	#default will be pawn, if this spot is reached move pawn
	beq $v0, 'p', lowerPawn
	li $v0, 80
	j pawnTime
lowerPawn:
	li $v0, 112
pawnTime:
	sw $v0, 0($sp)
	jal validPawnMove
	bltz $v0, moveInvalid
	#check if captured piece or not
	sw $v0, 12($sp)
	sw $v1, 16($sp)
	#call setSquare
	addi $sp, $sp, -4
	move $t9, $s3
	sb $t9, 0($sp)
	move $a0, $s6
	move $a1, $s7
	li $a2, 'P'
	move $a3, $s0
	jal setSquare
	#clear from 
	move $a0, $s4
	move $a1, $s5
	li $a2, 'E'
	move $a3, $s0
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
rookMove:
	jal validRookMove
	bltz $v0, moveInvalid #check if a negative value is returned, which means move invalid
	sw $v0, 12($sp) #store either 0 for no cap or 1 for cap
	sw $v1, 16($sp) #store either letter of piece or '\0'
	#call setSquare
	addi $sp, $sp, -4 #make room on stack 
	move $t9, $s3
	sb $t9, 0($sp) #store fg color on stack
	move $a0, $s6 #to row
	move $a1, $s7 #to col
	li $a2, 'R' #rook 
	move $a3, $s0 #player
	jal setSquare
	#clear from 
	move $a0, $s4 #from row
	move $a1, $s5 #from col 
	li $a2, 'E' #empty char
	move $a3, $s0 #player
	#fg color and sp should be at the same position so no need to move/store it again
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
knightMove:
	jal validKnightMove
	bltz $v0, moveInvalid
	sw $v0, 12($sp)
	sw $v1, 16($sp)
	#call setSquare
	addi $sp, $sp, -4
	move $t9, $s3
	sb $t9, 0($sp)
	move $a0, $s6
	move $a1, $s7
	li $a2, 'H'
	move $a3, $s0
	jal setSquare
	#clear from 
	move $a0, $s4
	move $a1, $s5
	li $a2, 'E'
	move $a3, $s0
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
bishopMove:
	jal validBishopMove
	bltz $v0, moveInvalid
	sw $v0, 12($sp)
	sw $v1, 16($sp)
	#call setSquare
	addi $sp, $sp, -4
	move $t9, $s3
	sb $t9, 0($sp)
	move $a0, $s6
	move $a1, $s7
	li $a2, 'B'
	move $a3, $s0
	jal setSquare
	#clear from 
	move $a0, $s4
	move $a1, $s5
	li $a2, 'E'
	move $a3, $s0
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
queenMove:
	jal validQueenMove
	bltz $v0, moveInvalid
	sw $v0, 12($sp)
	sw $v1, 16($sp)
	#call setSquare
	addi $sp, $sp, -4
	move $t9, $s3
	sb $t9, 0($sp)
	move $a0, $s6
	move $a1, $s7
	li $a2, 'Q'
	move $a3, $s0
	jal setSquare
	#clear from 
	move $a0, $s4
	move $a1, $s5
	li $a2, 'E'
	move $a3, $s0
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
kingMove:
	jal validKingMove
	bltz $v0, moveInvalid
	#save new board position into memory at king_pos, address should be stored on stack
	lh $t0, 0($sp)
	sh $s2, 0($t0) #store 'to'
	sw $v0, 12($sp)
	sw $v1, 16($sp)
	#call setSquare
	addi $sp, $sp, -4
	move $t9, $s3
	sb $t9, 0($sp)
	move $a0, $s6
	move $a1, $s7
	li $a2, 'K'
	move $a3, $s0
	jal setSquare
	#clear from 
	move $a0, $s4
	move $a1, $s5
	li $a2, 'E'
	move $a3, $s0
	jal setSquare
	addi $sp, $sp, 4
	j epilogueI
	
inputBad:
	li $v0, -2
	li $v1, '\0'
	j actualEpilogueI
	
moveInvalid:
	li $v0, -1
	li $v1, '\0'
	j actualEpilogueI

epilogueI:
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	beqz $t0, noCapture
	#only go here if $t0 is 1, bc a capture happened.
	move $v0, $t0
	move $v1, $t1
	j actualEpilogueI
noCapture:
	li $v0, 0
	li $v1, '\0'
actualEpilogueI:
		
	lw $ra, 52($sp)
	lw $s0, 48($sp)
	lw $s1, 44($sp)
	lw $s2, 40($sp)
	lw $s3, 36($sp)
	lw $s4, 32($sp)
	lw $s5, 28($sp)
	lw $s6, 24($sp)
	lw $s7, 20($sp)
	addi $sp, $sp, 56
	jr $ra

##########################################
#  Part #3 Function
##########################################

check:
	
	# int check(int player, short opponentKingPos)
	# 1. prologue
	# check if inputs are valid
	# 2. iterate through each row, getChessPiece at each row
	# 3. when a piece matches plaayer input, use validMove to see if it can move to kingPos
	# 4. if yes, then gg return function
	# 5. if no keep going'
	# 6.epilogue
	addi $sp, $sp, -36
	sw $s5, 32($sp)
	sw $ra, 28($sp)
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)

	
	move $s0, $a0 # int player
	move $s1, $a1 # short opponentKingPos
	
	bgt $s0, 2, checkInputBad
	blt $s0, 1, checkInputBad
	sh $s1, 4($sp)
	lb $s3, 4($sp) # kingPos col
	lb $s4, 5($sp) # kingPos row
	
	bgt $s3, 7, checkInputBad
	blt $s3, 0, checkInputBad
	bgt $s4, 7, checkInputBad
	blt $s4, 0, checkInputBad

	li $s3, 0 #counter to 63
	#####
checkLoop:
	beq $s3, 63, boardEnd #leave loop once last square has been reached 
	
	li $t2, 8
	div $s3, $t2 # divide counter by 8, calculating the "from"
	mflo $a0 #row number
	mfhi $t3 # col number
	sll $a0, $a0, 8 # move to the left
	add $a0, $a0, $t3 # put them together (SHORT)
	sh $a0, 0($sp)
	jal getChessPiece
	move $s5, $v0 #get char piece
	move $s4, $v1 #get int player
	beq $s5, 'E', samePlayer
	beq $s5, 'K', samePlayer #can't put a king in check using a king
	#if here, theres a piece in the square
	bne $s4, $s0, samePlayer
	beq $s5, 'R', checkRook
	beq $s5, 'H', checkKnight
	beq $s5, 'B', checkBishop
	beq $s5, 'Q', checkQueen
	beq $s5, 'P', checkPawn
	beq $s5, 'p', checkPawn
	j samePlayer
checkPawn:
	lh $a0, 0($sp)
	move $a1, $s1 #kingpos = to
	move $a2, $s0 #player number
	move $a3, $sp #capture address
	beq $s5, 'p', singleMove
	li $t6, 80 #capital P otherwise
	j pawnChecker
singleMove:
	li $t6, 112
pawnChecker:
	sw $t6, 0($sp)
	jal validPawnMove
	beq $v0, 0, checkConfirmed # 0 also counts as check since it means validMove
	beq $v0, 1, checkConfirmed #leave because check has been found
	j samePlayer #if not then just increment again
	
checkRook:
	lh $a0, 0($sp)
	move $a1, $s1 #kingpos = to
	move $a2, $s0 #player number
	move $a3, $sp #capture address
	jal validRookMove
	beq $v0, 0, checkConfirmed # 0 also counts as check since it means validMove
	beq $v0, 1, checkConfirmed #leave because check has been found
	j samePlayer #if not then just increment again
checkKnight:
	lh $a0, 0($sp)
	move $a1, $s1 #kingpos = to
	move $a2, $s0 #player number
	move $a3, $sp #capture address
	jal validKnightMove
	beq $v0, 0, checkConfirmed # 0 also counts as check since it means validMove
	beq $v0, 1, checkConfirmed #leave because check has been found
	j samePlayer #if not then just increment again
checkBishop:
	lh $a0, 0($sp)
	move $a1, $s1 #kingpos = to
	move $a2, $s0 #player number
	move $a3, $sp #capture address
	jal validBishopMove
	beq $v0, 0, checkConfirmed # 0 also counts as check since it means validMove
	beq $v0, 1, checkConfirmed #leave because check has been found
	j samePlayer #if not then just increment again
checkQueen:
	lh $a0, 0($sp)
	move $a1, $s1 #kingpos = to
	move $a2, $s0 #player number
	move $a3, $sp #capture address
	jal validQueenMove
	beq $v0, 0, checkConfirmed # 0 also counts as check since it means validMove
	beq $v0, 1, checkConfirmed #leave because check has been found
samePlayer:
	addi $s3, $s3, 1 #increment square
	j checkLoop
	######
boardEnd:
	li $v0, -1
	j epilogueJ
checkInputBad:
	li $v0, -2
	j epilogueJ
checkConfirmed:
	li $v0, 0
epilogueJ:
	lw $s5, 32($sp)
	lw $ra, 28($sp)
	lw $s0, 24($sp)
	lw $s1, 20($sp)
	lw $s2, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	addi $sp, $sp, 36
	jr $ra
