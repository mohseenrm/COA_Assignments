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
# type-your-name (type-your-email-address)
# type-your-partners-name (type-your-email-address)
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
# global constant BUF_LEN      ← 84  -- Size of the array string allocated in main().
# global constant SYS_RS_MAX   ← 82  -- Maximum number of chars to read when calling SysReadStr.
# global constant NUM_COLS     ← 10  -- Number of columns in the 2D grid.
# global constant NUM_ROWS     ←  8  -- Number of rows in the 2D grid.
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
#     local int col, index ← 0, row
#     for col ← 0 to NUM_COLS - 1 do
#         for row ← 0 to NUM_ROWS - 1 do
#             if grid[row][col] ≠ ' ' then
#                 cipher[index] ← grid[row][col]
#                 ++index
#             end if
#         end for
#     end for
#     cipher[index] ← '\0' -- write the required null char at the end of cipher
# end function read_grid
#
# -- Writes the characters of the plaintext message plain into the 2D grid in row-major order.
# function write_grid(grid, plain)
#     local int col, index ← 0, len ← strlen(plain) - 1, row
#     for row ← 0 to NUM_ROWS do
#         for col ← 0 to NUM_COLS do
#             if index < len then
#                 grid[row][col] ← plain[index]
#                 ++index
#             else
#                 grid[row][col] ← ' '
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
# The total size of the allocated stack frame is BUF_LEN + NUM_ROWS · NUM_COLS = 84 + 8 · 10 = 164 bytes.
# Note that because of word alignment, 'string' and 'grid' are both stored at addresses that are divi-
# sible by 4, i.e., 'string' and 'grid' are word-aligned.
#-------------------------------------------------------------------------------------------------------
main:
# char string[BUF_LEN], grid[MAX_ROWS][MAX_COLS]
    addi    $sp, $sp, -164               # Allocate local vars in stack frame

# SysPrintStr("Enter a string (length <= 80)? ")
    addi    $v0, $zero, SYS_PRINT_STR    # $v0 ← SysprintStr service code
    la      $a0, s_prompt                # $a0 ← addr of s_prompt
    syscall                              # SysPrintStr("Enter a string (length <= 80)? ")

# string ← SysReadStr()
    addi    $v0, $zero, SYS_READ_STR     # $v0 ← SysReadStr service code
    move    $a0, $sp                     # $a0 ← &string (note that array vars are addresses)
    addi    $a1, $zero, SYS_RS_MAX       # $a1 ← max num of chars to read
    syscall                              # SysReadStr(&string, 82) Reads up to 80 chars plus the newline

# write_grid(grid, string)
    addi    $a0, $sp, BUF_LEN            # $a0 ← &grid ($a0 contains the address of grid)
    move    $a1, $sp                     # $a1 ← &string ($a1 contains the address of string)
    jal     write_grid                   # write_grid(&grid, &string), passes addresses
    
# read_grid(grid, string)
    addi    $a0, $sp, BUF_LEN            # $a0 ← &grid
    move    $a1, $sp                     # $a1 ← &string
    jal     read_grid                    # read_grid(&grid, &string)    
    
# SysPrintStr("Ciphertext: ")
    addi    $v0, $zero, SYS_PRINT_STR    # $v0 ← SysprintStr service code
    la      $a0, s_cipher                # $a0 = addr of s_cipher
    syscall                              # SysPrintStr("Ciphertext: ")

# SysPrintStr(string)
    addi    $v0, $zero, SYS_PRINT_STR    # $a0 ← SysPrintStr service code
    move    $a0, $sp                     # $a1 ← &string
    syscall                              # SysPrintStr(&string)

# Deallocate stack frame
    addi    $sp, $sp, 164                # Deallocate stack frame

# SysExit()
    addi    $v0, $zero, SYS_EXIT         # $v0 ← SysExit service code
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
#     local int col, index ← 0, row
#     for col ← 0 to NUM_COLS - 1 do
#         for row ← 0 to NUM_ROWS - 1 do
#             if grid[row][col] ≠ ' ' then
#                 cipher[index] ← grid[row][col]
#                 ++index
#             end if
#         end for
#     end for
#     cipher[index] ← '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 2 - REWRITE FOR LOOPS USING WHILE LOOPS
# function read_grid(char grid[][], char cipher[])
#     local int col, index ← 0, row
#     col ← 0
#     while col < NUM_COLS do
#         row ← 0
#         while row < NUM_ROWS do
#             if grid[row][col] ≠ ' ' then
#                 cipher[index] ← grid[row][col]
#                 ++index
#             end if
#             ++row
#         end while
#         ++col
#     end while
#     cipher[index] ← '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 3 - REWRITE WHILE LOOPS USING IF STATEMENTS AND GOTO'S
# function read_grid(char grid[][], char cipher[])
#     local int col, index ← 0, row
#     col ← 0
#   rg_begin_loop1:
#     if col ≥ NUM_COLS then goto rg_end_loop1
#     row ← 0
#   rg_begin_loop2:
#     if row ≥ NUM_ROWS then goto rg_end_loop2
#     if grid[row][col] ≠ ' ' then
#         cipher[index] ← grid[row][col]
#         ++index
#     end if
#     ++row
#     goto rg_begin_loop2
#   rg_end_loop2:
#     ++col
#     goto rg_begin_loop1
#   rg_end_loop1:
#     cipher[index] ← '\0'
# end function read_grid
#
# PSEUDOCODE - VERSION 4 - REWRITE IF-ELSE STATEMENT USING IF STATEMENT AND GOTO'S
# function read_grid(char grid[][], char cipher[])
#     local int col, index ← 0, row
#     col ← 0
#   rg_begin_loop1:
#     if col ≥ NUM_COLS then goto rg_end_loop1
#     row ← 0
#   rg_begin_loop2:
#     if row ≥ NUM_ROWS then goto rg_end_loop2
#     if grid[row][col] = ' ' then goto rg_endif
#     cipher[index] ← grid[row][col]
#     ++index
#   rg_endif:
#     ++row
#     goto rg_begin_loop2
#   rg_end_loop2:
#     ++col
#     goto rg_begin_loop1
#   rg_end_loop1:
#     cipher[index] ← '\0'
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
    sw      $zero, 4($sp)                # index ← 0

# Load global constants NUM_COLS and NUM_ROWS into registers. We need use these constants in the cond-
# itional expressions of the loops, but it make sense to only load the values once rather than during
# each iteration of the loop.
    addi    $t8, $zero, NUM_COLS         # $t8 ← NUM_COLS
    addi    $t9, $zero, NUM_ROWS         # $t9 ← NUM_ROWS

# We compare grid[row][col] to see if it is a space char in the inner loop. Rather than loading $t7 with
# the ASCII value of ' ' (32 base 10) each time through the loop, I have optimized this code so we only
# load $t7 once.
    addi    $t7, $zero, ' '              # $t7 ← ' ' (ASCII value 32)
    
# col ← 0
    sw      $zero, 0($sp)                # col ← 0

rg_begin_loop1:
# if col ≥ NUM_COLS then goto rg_end_loop1
    lw      $t0, 0($sp)                  # $t0 ← col
    bge     $t0, $t8, rg_end_loop1       # if col ≥ NUM_COLS drop out of outer loop

# row ← 0
    sw      $zero, 8($sp)                # row ← 0
    
rg_begin_loop2:
# if row ≥ NUM_ROWS then goto rg_end_loop2
    lw      $t0, 8($sp)                  # $t0 ← row
    bge     $t0, $t9, rg_end_loop2       # if row ≥ NUM_ROWS drop out of outer loop

# if grid[row][col] = ' ' goto rg_endif
    lw      $t0, 8($sp)                  # $t0 ← row
    mul     $t0, $t0, $t8                # $t0 ← row · NUM_COLS
    lw      $t1, 0($sp)                  # $t1 ← col
    add     $t0, $t0, $t1                # $t0 ← row · NUM_COLS + col
    add     $t0, $a0, $t0                # $t0 ← grid + row · NUM_COLS + col = &grid[row][col]
    lbu     $t0, 0($t0)                  # $t0[7:0] ← grid[row][col] (note: LBU loads a byte/char)
    beq     $t0, $t7, rg_endif           # if grid[row][col] = ' ' goto rg_endif
    
# cipher[index] ← grid[row][col]
    lw      $t1, 4($sp)                  # $t1 ← index
    add     $t1, $a1, $t1                # $t1 ← cipher + index = &cipher[index]
    sb      $t0, 0($t1)                  # cipher[index] ← grid[row][col]
    
# ++index
    lw      $t0, 4($sp)                  # $t0 ← index
    addi    $t0, $t0, 1                  # $t0 ← index + 1
    sw      $t0, 4($sp)                  # ++index

rg_endif:
# ++row
    lw      $t0, 8($sp)                  # $t0 ← row
    addi    $t0, $t0, 1                  # $t0 ← row + 1
    sw      $t0, 8($sp)                  # ++row
    
# goto rg_begin_loop2
    j       rg_begin_loop2               # goto beginning of inner loop

rg_end_loop2:
# ++col
    lw      $t0, 0($sp)                  # $t0 ← col
    addi    $t0, $t0, 1                  # $t0 ← col + 1
    sw      $t0, 0($sp)                  # ++col

# goto rg_begin_loop1
    j       rg_begin_loop1               # goto beginning of outer loop

rg_end_loop1:
# cipher[index] ← '\0'
    lw      $t0, 4($sp)                  # $t0 ← index
    add     $t0, $a1, $t0                # $t0 ← cipher + index = &cipher[index]
    sb      $zero, 0($t0)                # cipher[index] ← '\0'

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
#     local int index ← 0
#   begin_loop:
#     if string[index] = '\0' goto end_loop
#     ++index
#     goto begin_loop
#   end_loop:
#     return index
#-------------------------------------------------------------------------------------------------------
??? COPY-AND-PASTE YOUR CODE FOR STRLEN() FROM EXERCISE 1 HERE ???

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
#     local int col, index ← 0, len ← strlen(plain) - 1, row
#     for row ← 0 to NUM_ROWS do
#         for col ← 0 to NUM_COLS do
#             if index < len then
#                 grid[row][col] ← plain[index]
#                 ++index
#             else
#                 grid[row][col] ← ' '
#             end if
#         end for
#     end for
# end function write_grid
#
# Write the pseudocode Versions 2-4 (Exercises 2.a - 2.c) before you begin writing the assembly language
# code. You can insert the revised versions here, but also place them in the PDF as requested.
#-------------------------------------------------------------------------------------------------------
??? WRITE THE CODE FOR WRITE_GRID() HERE ???
