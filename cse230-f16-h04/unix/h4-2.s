#*******************************************************************************************************
# FILE: h4-2.s
#
# CSE/EEE 230 Comp. Org. and Assemb. Lang. Program. Fall 2016 - Homework 4, Exercise 2.
# SECTION: type-your-section-time
#
# DESCRIPTION
# Encrypts plaintext messages using my lousy 2D grid encryption method.
#
# AUTHOR INFO
# Mohseen Mukaddam ( mohseen@asu.edu )
# Vishnu Narang ( vnnarang@asu.edu )
#*******************************************************************************************************

#=======================================================================================================
# EQUIVALENTS
#=======================================================================================================

# Define equivalents for useful service codes. See pp. 16-17 of the Ch. 2 lecture notes for a discussion
# of the .eqv directive.
.eqv SYS_EXIT         10
.eqv SYS_PRINT_CHAR   11
.eqv SYS_PRINT_INT     1
.eqv SYS_PRINT_STR     4
.eqv SYS_READ_CHAR    12
.eqv SYS_READ_INT      5
.eqv SYS_READ_STR      8

# Other global constants.
.eqv BUF_LEN          84  # Size of the array string allocated in main().
.eqv MAX_MSG_LEN      80  # Maximum number of chars in plaintext message.
.eqv SYS_RS_LEN       82  # Maximum number of chars to read when calling SysReadStr.
.eqv NUM_COLS         10  # Number of columns in the 2D grid.
.eqv NUM_ROWS          8  # Number of rows in the 2D grid.

.eqv MAX_MSG_LEN   80  # Max number of valid chars in a string (excluding newline and null char)
.eqv BUF_LEN       84  # Number of bytes to allocate for the 'string' array.
.eqv SYS_RS_MAX    82  # The argument in $a1 when calling SysReadStr


#=======================================================================================================
# DATA SECTION
#=======================================================================================================
.data
s_prompt:       .asciiz  "Plaintext (80 or fewer chars)? "
s_cipher:       .ascii   "Ciphertext: "

#=======================================================================================================
# TEXT SECTION
#=======================================================================================================
.text

#-------------------------------------------------------------------------------------------------------
# FUNCTION: main()
#
# DESCRIPTION
# Asks the user to enter a plaintext message. Encrypts the message using the 2D grid method and outputs
# the resulting cipherstring message.
#
# PSEUDOCODE
# -- define global constants using the .eqv directive
# global constant BUF_LEN      â†? 84  -- Size of the array string allocated in main().
# global constant SYS_RS_MAX   â†? 82  -- Maximum number of chars to read when calling SysReadStr.
# global constant NUM_COLS     â†? 10  -- Number of columns in the 2D grid.
# global constant NUM_ROWS     â†?  8  -- Number of rows in the 2D grid.
#
# function main()
#     local char string[BUF_LEN], grid[NUM_ROWS][NUM_COLS]  -- local vars are allocated in stack frame
#     SysPrintStr("Plaintext (80 or fewer chars)? ")
#     SysReadStr(string, SYS_RS_MAX)
#     write_grid(grid, string)
#     read_grid(grid, string)
#     SysPrintStr("Ciphertext: ")
#     SysPrintStr(string)
# end function main
#
# -- Reads the characters from the 2D grid forming the encrypted cipherstring, which is returned.
# function read_grid(char grid[][], char cipher[])
#     local int col, index â†? 0, row
#     for col â†? 0 to NUM_COLS - 1 do
#         for row â†? 0 to NUM_ROWS - 1 do
#             if grid[row][col] â‰  ' ' then
#                 cipher[index] â†? grid[row][col]
#                 ++index
#             end if
#         end for
#     end for
#     cipher[index] â†? '\0' -- write the required null char at the end of cipher
# end function read_grid
#
# -- Writes the characters of the plaintext message plain into the 2D grid in row-major order.
# function write_grid(grid, plain)
#     local int col, index â†? 0, len â†? strlen(plain) - 1, row
#     for row â†? 0 to NUM_ROWS do
#         for col â†? 0 to NUM_COLS do
#             if index < len then
#                 grid[row][col] â†? plain[index]
#                 ++index
#             else
#                 grid[row][col] â†? ' '
#             end if
#         end for
#     end for
# end function write_grid
#
# See the read_grid() and write_grid() comments for the revised pseudocode.
#
# STACK FRAME
# main() will allocate a stack frame containing the following local variables,
#
# +----------+
# |          | 0x7FFF_EFFC [$sp+164] <-- $sp points here on entry to main()
# +----------+
# | grid     | 0x7FFF_EFAC [$sp+84, $sp+163]
# +----------+
# | string   | 0x7FFF_EF58 [$sp+ 0, $sp+ 83]
# +----------+
#
# The total size of the allocated stack frame is BUF_LEN + NUM_ROWS Â· NUM_COLS = 84 + 8 Â· 10 = 164 bytes.
# Note that because of word alignment, 'string' and 'grid' are both stored at addresses that are divi-
# sible by 4, i.e., 'string' and 'grid' are word-aligned.
#-------------------------------------------------------------------------------------------------------
main:
# char string[BUF_LEN], grid[MAX_ROWS][MAX_COLS]
    addi    $sp, $sp, -164               # Allocate local vars in stack frame

# SysPrintStr("Enter a string (length <= 80)? ")
    addi    $v0, $zero, SYS_PRINT_STR    # $v0 â†? SysprintStr service code
    la      $a0, s_prompt                # $a0 â†? addr of s_prompt
    syscall                              # SysPrintStr("Enter a string (length <= 80)? ")

# string â†? SysReadStr()
    addi    $v0, $zero, SYS_READ_STR     # $v0 â†? SysReadStr service code
    move    $a0, $sp                     # $a0 â†? &string (note that array vars are addresses)
    addi    $a1, $zero, SYS_RS_MAX       # $a1 â†? max num of chars to read
    syscall                              # SysReadStr(&string, 82) Reads up to 80 chars plus the newline

# write_grid(grid, string)
    addi    $a0, $sp, BUF_LEN            # $a0 â†? &grid ($a0 contains the address of grid)
    move    $a1, $sp                     # $a1 â†? &string ($a1 contains the address of string)
    jal     write_grid                   # write_grid(&grid, &string), passes addresses
    
# read_grid(grid, string)
    addi    $a0, $sp, BUF_LEN            # $a0 â†? &grid
    move    $a1, $sp                     # $a1 â†? &string
    jal     read_grid                    # read_grid(&grid, &string)    
    
# SysPrintStr("Ciphertext: ")
    addi    $v0, $zero, SYS_PRINT_STR    # $v0 â†? SysprintStr service code
    la      $a0, s_cipher                # $a0 = addr of s_cipher
    syscall                              # SysPrintStr("Ciphertext: ")

# SysPrintStr(string)
    addi    $v0, $zero, SYS_PRINT_STR    # $a0 â†? SysPrintStr service code
    move    $a0, $sp                     # $a1 â†? &string
    syscall                              # SysPrintStr(&string)

# Deallocate stack frame
    addi    $sp, $sp, 164                # Deallocate stack frame

# SysExit()
    addi    $v0, $zero, SYS_EXIT         # $v0 â†? SysExit service code
    syscall                              # SysExit()

#-------------------------------------------------------------------------------------------------------
# FUNCTION: void read_grid(char grid[][], char cipher[])
#
# DESCRIPTION
# Reads the characters from grid in column-major order concatenating them to create the encrypted
# cipherstring message, which is written to the 'cipher' parameter.
#
# ARGUMENTS
# $a0 - grid   (which is the address of the 'grid' variable allocated in main's stack frame)
# $a1 - cipher (which is the address of the 'string' variable allocated in main's stack frame)
#
# RETURNS
# Nothing directly, but modifying 'cipher' here really modifies 'string' defined in main's stack frame
# so, upon return to main(), 'string' in main() will be the ciphertext message.
#
# PSEUDOCODE - VERSION 1 - USING FOR LOOPS
# function read_grid(char grid[][], char cipher[])
#     local int col, index â†? 0, row
#     for col â†? 0 to NUM_COLS - 1 do
#         for row â†? 0 to NUM_ROWS - 1 do
#             if grid[row][col] â‰  ' ' then
#                 cipher[index] â†? grid[row][col]
#                 ++index
#             end if
#         end for
#     end for
#     cipher[index] â†? '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 2 - REWRITE FOR LOOPS USING WHILE LOOPS
# function read_grid(char grid[][], char cipher[])
#     local int col, index â†? 0, row
#     col â†? 0
#     while col < NUM_COLS do
#         row â†? 0
#         while row < NUM_ROWS do
#             if grid[row][col] â‰  ' ' then
#                 cipher[index] â†? grid[row][col]
#                 ++index
#             end if
#             ++row
#         end while
#         ++col
#     end while
#     cipher[index] â†? '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 3 - REWRITE WHILE LOOPS USING IF STATEMENTS AND GOTO'S
# function read_grid(char grid[][], char cipher[])
#     local int col, index â†? 0, row
#     col â†? 0
#   rg_begin_loop1:
#     if col â‰¥ NUM_COLS then goto rg_end_loop1
#     row â†? 0
#   rg_begin_loop2:
#     if row â‰¥ NUM_ROWS then goto rg_end_loop2
#     if grid[row][col] â‰  ' ' then
#         cipher[index] â†? grid[row][col]
#         ++index
#     end if
#     ++row
#     goto rg_begin_loop2
#   rg_end_loop2:
#     ++col
#     goto rg_begin_loop1
#   rg_end_loop1:
#     cipher[index] â†? '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 4 - REWRITE IF-ELSE STATEMENT USING IF STATEMENT AND GOTO'S
# function read_grid(char grid[][], char cipher[])
#     local int col, index â†? 0, row
#     col â†? 0
#   rg_begin_loop1:
#     if col â‰¥ NUM_COLS then goto rg_end_loop1
#     row â†? 0
#   rg_begin_loop2:
#     if row â‰¥ NUM_ROWS then goto rg_end_loop2
#     if grid[row][col] = ' ' then goto rg_endif
#     cipher[index] â†? grid[row][col]
#     ++index
#   rg_endif:
#     ++row
#     goto rg_begin_loop2
#   rg_end_loop2:
#     ++col
#     goto rg_begin_loop1
#   rg_end_loop1:
#     cipher[index] â†? '\0'
# end function read_grid
#
# STACK FRAME
# read_grid() will allocate a stack frame containing the local variables. On entry to read_grid, $sp
# will contain 0x7FFF_EF58 which is the address of the top of main's stack frame. In general, if
# function foo() calls function bar(), then on entry to bar(), $sp will be pointing to the top of
# foo's stack frame.
#
# +----------+
# | main sf  | 0x7FFF_EF58 [$sp+12] <-- $sp points to the top of main's stack frame on entry
# +----------+
# | row      | 0x7FFF_EF54 [$sp+8, $sp+11]
# +----------+
# | index    | 0x7FFF_EF50 [$sp+4, $sp+ 7]
# +----------+
# | col      | 0x7FFF_EF4C [$sp+0, $sp+ 3]
# +----------+
#
# The total size of the allocated stack frame is 3 words x 4 bytes/word = 12 bytes. Note that all local
# variables are stored at addresses that are divisible by 4, i.e., the variables are word-aligned. It is
# very important that the stack maintains word-alignment.
#-------------------------------------------------------------------------------------------------------
read_grid:
# local int col, index, row
    addi    $sp, $sp, -12                # Allocate 3 words in stack frame
    sw      $zero, 4($sp)                # index â†? 0

# Load global constants NUM_COLS and NUM_ROWS into registers. We need use these constants in the cond-
# itional expressions of the loops, but it make sense to only load the values once rather than during
# each iteration of the loop.
    addi    $t8, $zero, NUM_COLS         # $t8 â†? NUM_COLS
    addi    $t9, $zero, NUM_ROWS         # $t9 â†? NUM_ROWS

# We compare grid[row][col] to see if it is a space char in the inner loop. Rather than loading $t7 with
# the ASCII value of ' ' (32 base 10) each time through the loop, I have optimized this code so we only
# load $t7 once.
    addi    $t7, $zero, ' '              # $t7 â†? ' ' (ASCII value 32)
    
# col â†? 0
    sw      $zero, 0($sp)                # col â†? 0

rg_begin_loop1:
# if col â‰¥ NUM_COLS then goto rg_end_loop1
    lw      $t0, 0($sp)                  # $t0 â†? col
    bge     $t0, $t8, rg_end_loop1       # if col â‰¥ NUM_COLS drop out of outer loop

# row â†? 0
    sw      $zero, 8($sp)                # row â†? 0
    
rg_begin_loop2:
# if row â‰¥ NUM_ROWS then goto rg_end_loop2
    lw      $t0, 8($sp)                  # $t0 â†? row
    bge     $t0, $t9, rg_end_loop2       # if row â‰¥ NUM_ROWS drop out of outer loop

# if grid[row][col] = ' ' goto rg_endif
    lw      $t0, 8($sp)                  # $t0 â†? row
    mul     $t0, $t0, $t8                # $t0 â†? row Â· NUM_COLS
    lw      $t1, 0($sp)                  # $t1 â†? col
    add     $t0, $t0, $t1                # $t0 â†? row Â· NUM_COLS + col
    add     $t0, $a0, $t0                # $t0 â†? grid + row Â· NUM_COLS + col = &grid[row][col]
    lbu     $t0, 0($t0)                  # $t0[7:0] â†? grid[row][col] (note: LBU loads a byte/char)
    beq     $t0, $t7, rg_endif           # if grid[row][col] = ' ' goto rg_endif
    
# cipher[index] â†? grid[row][col]
    lw      $t1, 4($sp)                  # $t1 â†? index
    add     $t1, $a1, $t1                # $t1 â†? cipher + index = &cipher[index]
    sb      $t0, 0($t1)                  # cipher[index] â†? grid[row][col]
    
# ++index
    lw      $t0, 4($sp)                  # $t0 â†? index
    addi    $t0, $t0, 1                  # $t0 â†? index + 1
    sw      $t0, 4($sp)                  # ++index

rg_endif:
# ++row
    lw      $t0, 8($sp)                  # $t0 â†? row
    addi    $t0, $t0, 1                  # $t0 â†? row + 1
    sw      $t0, 8($sp)                  # ++row
    
# goto rg_begin_loop2
    j       rg_begin_loop2               # goto beginning of inner loop

rg_end_loop2:
# ++col
    lw      $t0, 0($sp)                  # $t0 â†? col
    addi    $t0, $t0, 1                  # $t0 â†? col + 1
    sw      $t0, 0($sp)                  # ++col

# goto rg_begin_loop1
    j       rg_begin_loop1               # goto beginning of outer loop

rg_end_loop1:
# cipher[index] â†? '\0'
    lw      $t0, 4($sp)                  # $t0 â†? index
    add     $t0, $a1, $t0                # $t0 â†? cipher + index = &cipher[index]
    sb      $zero, 0($t0)                # cipher[index] â†? '\0'

    addi    $sp, $sp, 12                 # Deallocate stack frame
    jr      $ra                          # Return

#-------------------------------------------------------------------------------------------------------
# FUNCTION: int strlen(char string[])
#
# DESCRIPTION
# Computes and returns the length of the C-string 'string'.
#
# ARGUMENTS
# $a0 - string (the address of the string)
#
# RETURNS
# $v0 - the length of string.
#
# PSEUDOCODE
# function strlen(char string[])
#     local int index â†? 0
#   begin_loop:
#     if string[index] = '\0' goto end_loop
#     ++index
#     goto begin_loop
#   end_loop:
#     return index
#-------------------------------------------------------------------------------------------------------
#??? COPY-AND-PASTE YOUR CODE FOR STRLEN() FROM EXERCISE 1 HERE ???

strlen:
# int len, char string[BUF_LEN]
    addi    $sp, $sp, -8                 # Allocate local vars in stack frame
    
    addi    $t0, $zero, 0		         # int index = 0
    add     $t1, $zero, $a1		         # string (a1) -> $t1
    sw      $t0, 0($sp)			         # $sp[0:3] = index
    addi    $t5, $zero, '\0'		     # $t5 = ASCII value of '\0'
begin_loop:
    # if(string[index] != '\0')
    lw      $t0, 0($sp)			         # $t0 = index (read from local stack) 
    add     $t2, $t0, $t1		         # $t2 -> &string + index
    lb      $t3, 0($t2)			         # $t3 -> string[index]
    beq     $t3, $t5, end_loop
    #index++
    addi    $t0, $t0, 1			         # index++
    #store index
    sw      $t0, 0($sp)			         # saving index to local stack
    #jump to begin_loop
    j       begin_loop			         # jump to start of loop
end_loop:
    addi    $t0, $t0, -1    		     # to offset the '\n' from user input
    add     $v0, $zero, $t0		         # setting up the reurn registers 
    # Deallocate stack frame
    addi    $sp, $sp, 8                  # Deallocate stack frame
    # Return back to calling function
    jr      $ra




#-------------------------------------------------------------------------------------------------------
# FUNCTION: void write_grid(char grid[][], char plain[])
#
# DESCRIPTION
# Writes the characters of 'plain' into 'grid' in row-major order. Unused grid elements are filled with
# spaces. Note that there is a newline character at the end of 'plain' that was placed there by the
# SysReadStr() service. We do not want to store that newline character in grid, which is why we subtract
# 1 from strlen(plain) when len is initialized.
#
# ARGUMENTS
# $a0 - grid   (which is the address of the 'grid' variable allocated in main's stack frame)
# $a1 - plain  (which is the address of the 'string' variable  allocated in main's stack frame)
#
# RETURNS
# Nothing directly, but modifying 'grid' here really modifies 'grid' defined in main's stack frame
# so, upon return to main(), 'grid' in main() will contain the plaintext message written in row-major
# order.
#
# PSEUDOCODE - VERSION 1 - USING FOR LOOPS
# function write_grid(grid, plain)
#     local int col, index â†? 0, len â†? strlen(plain) - 1, row
#     for row â†? 0 to NUM_ROWS do
#         for col â†? 0 to NUM_COLS do
#             if index < len then
#                 grid[row][col] â†? plain[index]
#                 ++index
#             else
#                 grid[row][col] â†? ' '
#             end if
#         end for
#     end for
# end function write_grid
#
# Write the pseudocode Versions 2-4 (Exercises 2.a - 2.c) before you begin writing the assembly language
# code. You can insert the revised versions here, but also place them in the PDF as requested.
#-------------------------------------------------------------------------------------------------------
# ??? WRITE THE CODE FOR WRITE_GRID() HERE ???
write_grid:
    addi    $sp, $sp, -16               # Allocate 3 words in stack frame
    sw 		$ra, 12($sp)				# Store $ra value in stack so that we can call strlen inside without losing return address.
    # a1 has string and a0 has grid address
    jal strlen		                    # Find the length of the string entered.
    sw      $v0, 0($sp)		            # get length of string intp stack
    lw 		$t3, 0($sp)		            # load length into t3 from $v0	
    sw      $zero, 0($sp)               # index at -> 0
    addi    $t8, $zero, NUM_COLS        # $t8 â†? NUM_COLS
    addi    $t9, $zero, NUM_ROWS        # $t9 â†? NUM_ROWS    
    addi    $t7, $zero, ' '             # $t7 â†? ' ' (ASCII value 32)
    sw      $zero, 4($sp)               # row â†? 0
wg_begin_loop1:
    lw      $t5, 4($sp)                 # load row value into t0 from $sp
    bge     $t5, $t9, wg_end_loop1      # if t0 == t9 i.e. num of rows, end loop.
    sw      $zero, 8($sp)               # col set to 0 from stack
wg_begin_loop2:
    lw      $t5, 8($sp)                 # $t0 â†? row
    bge     $t5, $t8, wg_end_loop2      # end loop if t0 is equl to col size	
    lw      $t0, 4($sp)                 # $t0 â†? row
    mul     $t0, $t0, $t8               # $t0 â†? row Â· NUM_COLS
    lw      $t1, 8($sp)                 # $t1 â†? col
    add     $t0, $t0, $t1               # $t0 â†? row Â· NUM_COLS + col
    add     $t0, $a0, $t0               # $t0 â†? grid + row Â· NUM_COLS + col = &grid[row][col]
    lw      $t1, 0($sp) 				# load index in t0
    blt     $t1, $t3, store_char        # if index is equal to length
    sb 		$t7, 0($t0)  	            # grid[row][col] = ''
    b end_if_else
store_char:
   	add     $t1, $a1, $t1               # $t1 â†? cipher + index = &cipher[index]
    lbu     $t1, 0($t1)                 # load value from index
    sb      $t1, 0($t0)                 # cipher[index] â†? grid[row][col]
end_if_else:
    # ++index
    lw      $t0, 0($sp)                 # $t0 â†? index
    addi    $t0, $t0, 1                 # $t0 â†? index + 1
    sw      $t0, 0($sp)                 # ++index
    # ++col
    lw      $t5, 8($sp)                 # $t0 â†? col
    addi    $t5, $t5, 1                 # $t0 â†? col + 1
    sw      $t5, 8($sp)                 # ++col
    # goto rg_begin_loop2
    j       wg_begin_loop2              # goto beginning of inner loop
wg_end_loop2:
    # ++row
    lw      $t5, 4($sp)                 # $t0 â†? row
    addi    $t5, $t5, 1                 # $t0 â†? row + 1
    sw      $t5, 4($sp)                 # ++row
    # goto rg_begin_loop1
    j       wg_begin_loop1              # goto beginning of outer loop
wg_end_loop1:
	lw 		$ra, 12($sp)				# load the $ra value earlier stored to jump out of write
    addi    $sp, $sp, 16                # Deallocate stack frame
    jr      $ra                         # Return
