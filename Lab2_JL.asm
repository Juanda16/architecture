.data
length:		.word	4	# Array 

eol:	.asciiz	"\n"


file_in:	.asciiz "sentences.txt"
file_out:	.asciiz "output.txt"
sentence:	.byte 0x0D, 0x0A #, 0x0D, 0x0A 
msg1:		.asciiz "Please Enter the sentence separator string: "
msg2:		.asciiz "\nSorted list of Sentences is: "
msg3:		.asciiz "\nFoud separator "
separator:      .space 20	



.align 2			#busca la siguiente posici�n de memoria mult de 4  para poner a input_buffer
input_buffer:	.space 5120	# Maximum input file size in Bytes
characters_to_read: .space 4
vectorA: 	.space 5120	# saved with the first letter addres of each sentences
sentence_cont:	.space 1280
char_p_s:	.space 100

    .align 2
coma:
    .asciiz ", "
    .align 2
set1:
    .space 69
    .align 2
set2:
    .space 69
    .align 2
set3:
    .space 138
    .align 2
    
new_line : 
    .asciiz "\n" 
    .align 5
		   
space_char: 
    .asciiz " "
    .align 5
		    
bracket1: 
    .asciiz "["
    .align 5
		  
bracket2: 
    .asciiz " ]"
    .align 5
		  
str_pointers: 
    .space 96 # more than: number of names(17) * 4bytes each address = 


    .text
    .globl main
    
main:
	la $t7, char_p_s	# Address of char_p_s
# Open (for reading) a file
	li $v0, 13		# System call for open file
	la $a0, file_in		# Input file name -> $a0 = argument
	li $a1, 0		# Open for reading (flag = 0)->depende si es solo lectura, escritura o apend
	#li $a2, 0		# Mode is ignored
	syscall			# Open a file (file descriptor returned in $v0)
	move $s0, $v0		# Copy file descriptor

# MessageDialog (for sentence separator) the user to type  
    	li $v0, 4
  	la $a0, msg1            #prints message1 to screen
    	syscall
    	li $v0, 12		#read string type by user (value saved in $vo)
    	syscall
    	#la $a0, separator	# load byte space into address
    	#li $a1, 20      	# allot the byte space for string (4)
    	move $t0, $v0   	# save string to t0
       	syscall                 
    	#move $s3, $v0		# System call for MessageDialog
    		
read:
# Read from previously opened file
	li $v0, 14		# System call for reading from file
	move $a0, $s0		# File descriptor (resultado de la apertura anteerior move $s0, $v0 )
	la $a1, input_buffer	# Address of input buffer
	li $a2, 5120		# Maximum number of characters to read
	syscall			# Read from file
	la $t3, input_buffer	# Copy Address of input buffer
	move $t1, $v0		# Copy number of characters read
	sw $t1,characters_to_read
	add $t4, $t3, $t1	# Limit to FOR
	li $t5, 0		#poner en cero el contador de caracteres por frase
	lb   $t2, ($t3)		# FOR --Copy value from addres
	la $a3, vectorA		# Address of vectorA 
	j load_vectorA 	#save first character of the first sentence on memory
	
   
    #bgt $t3, $t4 ,a_grater_b
    #beq $t3, $t4 ,a_equal_b
    
# PEGAR LLO SUYO AQUI *********
#recorrer para buscar la direcci�n de la primera letra de cada frase 
for: 	
	lb   $t2, ($t3)		# FOR --Copy value from addres
	beq $t2, $t0 found_sep	#brinca si ES es igual la primera letra al separador
	addi $t5, $t5, 1	#add 1 to character counter
	addi $t3, $t3, 1	#add 1 to address for the next comparation
	bge $t3, $t4 start_sorting #FIN FOR brinca a crear el archivo al terminar de recorrer
	j for
	
			
#mensaje de prueba de brinco
found_sep:	# TOMAR DE ACA EL CONTADOR DE CARACTERES POR FRASE ATES DE BORRARLO $t5
	sw $t5, 0($t7)		#load number of character per sentence
	addi $t7, $t7,4
	li $t5, 0		#poner en cero el contador de caracteres por frase
	li $v0, 4
  	la $a0, msg3            #Es igual: prints message4 to screen
    	syscall
    	addi $t3, $t3,1		#add1 to addres to start checking
    	lb   $t2, ($t3)		# FOR --Copy value from addres
    	j if
if:
	bne $t2, 32 check_next	# check if ther is an space
	addi $t3, $t3,1		# yes! so add1 to addres to continue checkin
	lb   $t2, ($t3)		# FOR --Copy value from addres
	j if			#check again if the next is an space too
check_next: 
	bne $t2, 10 check_next2 # check if ther is an \n nueva linea
	addi $t3, $t3,1		# yes! so add1 to addres to continue checkin
	lb   $t2, ($t3)		# FOR --Copy value from addres
	j if			#check again if the next is an space too, and start again
check_next2: 
	bne $t2, 13 load_vectorA	# check if ther is an \r retorno de carro
	addi $t3, $t3,1		# yes! so add1 to addres to continue checkin
	lb   $t2, ($t3)		# FOR --Copy value from addres
	j if
	
	
load_vectorA:			#la $a3, vectorA (se hizo arriba)Address of vectorA
	addi $t6, $t6,1		#cAddress counter	
	sw $t6,sentence_cont	#number of sentences saved 	
	#sw $t2, 0($a3)		#Cargar caracteres para pruebas
	sw $t3, 0($a3)		#Activar para cargar direcciones
	addi $a3, $a3,4
	j for
	    	

############################################################################################
start_sorting:
    	la	$a0, vectorA		# Load the start address of the array
    	lw	$t0, sentence_cont	# Load the array length
    	sll	$t0, $t0, 2		# Multiple the array length by 4 (the size of the elements)
    	add	$a1, $a0, $t0		# Calculate the array end address
    	jal	mergesort		# Call the merge sort function
   	 b	sortend	
##
# Recrusive mergesort function
#
# @param $a0 first address of the array
# @param $a1 last address of the array
##
mergesort:

	addi	$sp, $sp, -16		# Adjust stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the array start address on the stack
	sw	$a1, 8($sp)		# Store the array end address on the stack
	
	sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address (i.e. number of elements * 4)

	ble	$t0, 4, mergesortend	# If the array only contains a single element, just return
	
	srl	$t0, $t0, 3		# Divide the array size by 8 to half the number of elements (shift right 3 bits)
	sll	$t0, $t0, 2		# Multiple that number by 4 to get half of the array size (shift left 2 bits)
	add	$a1, $a0, $t0		# Calculate the midpoint address of the array
	sw	$a1, 12($sp)		# Store the array midpoint address on the stack
	
	jal	mergesort		# Call recursively on the first half of the array
	
	lw	$a0, 12($sp)		# Load the midpoint address of the array from the stack
	lw	$a1, 8($sp)		# Load the end address of the array from the stack
	
	jal	mergesort		# Call recursively on the second half of the array
	
	lw	$a0, 4($sp)		# Load the array start address from the stack
	lw	$a1, 12($sp)		# Load the array midpoint address from the stack
	lw	$a2, 8($sp)		# Load the array end address from the stack
	
	jal	merge			# Merge the two array halves
	
mergesortend:				

	lw	$ra, 0($sp)		# Load the return address from the stack
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr	$ra			# Return 
	
##
# Merge two sorted, adjacent arrays into one, in-place
#
# @param $a0 First address of first array
# @param $a1 First address of second array
# @param $a2 Last address of second array
##
merge:
	addi	$sp, $sp, -16		# Adjust the stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the start address on the stack
	sw	$a1, 8($sp)		# Store the midpoint address on the stack
	sw	$a2, 12($sp)		# Store the end address on the stack
	
	move	$s0, $a0		# Create a working copy of the first half address
	move	$s1, $a1		# Create a working copy of the second half address
	
mergeloop:

	lw	$t0, 0($s0)		# Load the first half position pointer
	lw	$t1, 0($s1)		# Load the second half position pointer
	#lw	$t0, 0($t0)		# Load the first half position value ## aqqui debo coger el valor real
	#lw	$t1, 0($t1)		# Load the second half position value  ## aqqui debo coger el valor real
	lb 	$t0, 0($t0)		# Load the first half position value ## aqqui debo coger el valor real
	lb	$t1, 0($t1)		# Load the second half position value  ## aqqui debo coger el valor real
	
	nextchar_return:
	beq 	$s0,$s1, continue
	beq     $t1, $t0, nextchar
	continue:
	move    $s7,$zero
	
	
	
	bgt	$t1, $t0, noshift	# If the lower value is already first, don't shift
	

	move	$a0, $s1		# Load the argument for the element to move
	move	$a1, $s0		# Load the argument for the address to move it to
	jal	shift			# Shift the element to the new position 
	
	addi	$s1, $s1, 4		# Increment the second half index
noshift:
	addi	$s0, $s0, 4		# Increment the first half index
	
	lw	$a2, 12($sp)		# Reload the end address
	bge	$s0, $a2, mergeloopend	# End the loop when both halves are empty
	bge	$s1, $a2, mergeloopend	# End the loop when both halves are empty
	b	mergeloop
	
mergeloopend:
	
	lw	$ra, 0($sp)		# Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			# Return

##
# Shift an array element to another position, at a lower address
#
# @param $a0 address of element to shift
# @param $a1 destination address of element
##
shift:
	li	$t0, 10
	ble	$a0, $a1, shiftend	# If we are at the location, stop shifting
	addi	$t6, $a0, -4		# Find the previous address in the array
	lw	$t7, 0($a0)		# Get the current pointer
	lw	$t8, 0($t6)		# Get the previous pointer
	sw	$t7, 0($t6)		# Save the current pointer to the previous address
	sw	$t8, 0($a0)		# Save the previous pointer to the current address
	move	$a0, $t6		# Shift the current position back
	b 	shift			# Loop again
shiftend:
	jr	$ra			# Return
	
sortend:				# Point to jump to when sorting is complete


# Print out the indirect array
	li	$t0, 0				# Initialize the current index
prloop:
	lw	$t1,length			# Load the array length
	bge	$t0,$t1,prdone			# If we hit the end of the array, we are done
	sll	$t2,$t0,2			# Multiply the index by 4 (2^2)
	lw	$t3,vectorA($t2)			# Get the pointer
	lbu 	$a0,0($t3)			# Get the value pointed to and store it for printing
	li	$v0,1				
	syscall					# Print the value
	la	$a0,eol				# Set the value to print to the newline
	li	$v0,4				
	syscall					# Print the value
	addi	$t0,$t0,1			# Increment the current index
	b	prloop		
			# Run through the print block again


    


nextchar:
		
	lw	$t0, 0($s0)		# Load the first half position pointer
	lw	$t1, 0($s1)		# Load the second half position pointer
	add 	$t5, $t0,$s7
	add 	$t9, $t1,$s7
        lb 	$t0, ($t5)		# Load the first half position value ## aqqui debo coger el valor real
	lb	$t1, ($t9)
	
	addi 	$s7,$s7,1
	j nextchar_return
    
    
prdone:	

# Open (for writing) a file that does not exist
	li $v0, 13		# System call for open file
	la $a0, file_out	# Input file name
	li $a1, 1		# Open for overwriting (flag = 1)
	#li $a1, 9		# Open for appending (flag = 9)
	#li $a2, 0		# Mode is ignored
	syscall			# Open a file (file descriptor returned in $v0)
	move $s1, $v0		# Copy file descriptor
	
# Process file loaded in memory

	li $v0, 15		# System call for write to a file
	move $a0, $s1		# Restore file descriptor (open for writing)
	la $a1, input_buffer	# Address of buffer from which to write
	lw  $t1, characters_to_read
	move $a2, $t1		# Number of characters to write
	syscall
	
# Append a sentence to a file
move $t0,$zero
move $t1,$zero

save_loop:
    lw $t6, sentence_cont     #load on $t6 the number of sentences
    beq $t0,$t6,save_loop_exit  #loop to save, 3 is the lenght of the vector -1 *********
    mul $t1, $t0,4
    addi $t0,$t0,1
    li $v0, 15		# System call for write to a file
    move $a0, $s1		# Restore file descriptor (open for writing) 
    lw $a3, vectorA($t1)
    la $a1, ($a3)	# Address of buffer from which to write
    lb $a2, char_p_s($t1)	# Number of characters to write. it should depends of any sentence   *********
    syscall
	
     li $v0, 15		# System call for write to a file
	move $a0, $s1		# Restore file descriptor (open for writing)
	la $a1,sentence	# Address of buffer from which to write
	li $a2, 2		# Number of characters to write
	syscall
    j save_loop  

save_loop_exit:
 
    
    # r Close the files
 
	li   $v0, 16       # system call for close file
	move $a0, $s0      # file descriptor to close
	syscall            # close file
	
	li   $v0, 16       # system call for close file
	move $a0, $s1      # file descriptor to close
	syscall       
	

					# We are finished
	li	$v0,10
	syscall
