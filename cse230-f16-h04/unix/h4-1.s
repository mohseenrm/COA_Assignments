#*******************************************************************************************************
# FILE: h4-1.s
#
# CSE/EEE 230 Comp. Org. and Assemb. Lang. Program. Fall 2016 - Homework 4, Exercise 1.
# SECTION: type-your-section-time
#
# DESCRIPTION
# Tests the student's strlen() function.
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

# Global constant MAX_MSG_LEN is the maximum number of characters in a valid string being tested. How-
# ever, we have to allocate two more bytes of memory than this for the string buffer where SysReadStr
# stores the characters the user types: one byte will store the newline character that is generated
# when the user presses the Enter key; this newline character will follow the last valid character of
# the string; the second additional byte is for the required null character which terminates the string.
# So it appears that we need to allocate 82 bytes for the string buffer, but 82 is not divisible by 4;
# why does this matter? It matters because we need to make sure that items in the stack are always
# stored on word boundaries (i.e., we also use the phrase word-aligned or word-alignment). Since 84
# is the smallest integer divisible by 4 that is greater than 82, we allocate 84 bytes for the string
# array in main().
#
# Note also that when calling SysReadStr() we must pass in $a1 the maximum number of chars to read; if
# we call this value MAX then up to MAX - 1 chars will be read, excluding the null char. Since a string
# contains a maximum of 81 chars, including the generated newline, we must pass 82 for MAX which guar-
# antees that up to 81 chars will be read. In general, if C is the maximum number of chars to be stored
# in a string that is to be read using SysReadStr, then allocate C+2 bytes for the buffer (or C+n,
# n ≥ 2, bytes so C+n is divisible by 4 to maintain word-alignment).

.eqv MAX_MSG_LEN   80  # Max number of valid chars in a string (excluding newline and null char)
.eqv BUF_LEN       84  # Number of bytes to allocate for the 'string' array.
.eqv SYS_RS_MAX    82  # The argument in $a1 when calling SysReadStr

#=======================================================================================================
# DATA SECTION
#=======================================================================================================
.data
s_prompt:       .asciiz  "Enter a string (length <= 80)? "

#=======================================================================================================
# TEXT SECTION
#=======================================================================================================
.text

#-------------------------------------------------------------------------------------------------------
# FUNCTION: void main()
#
# DESCRIPTION
# Asks the user to enter a string, calls strlen() passing the string as the argument, and outputs the
# return value.
#
# PSEUDOCODE
# global constant MAX_MSG_LEN  80               -- Max number of chars in a valid message
# global constant BUF_LEN      84               -- Size of the string array allocated in main()
# global constant SYS_RS_MAX   MAX_MSG_LEN + 2  -- Arg $a1 to SysReadStr is the max num of chars to read
#
# function main()
#     int len, char string[BUF_LEN]
#     SysPrintStr("Enter a string (length <= 80)? ")
#     SysReadStr(string, SYS_RS_MAX)
#     len ← strlen(string)
#     SysPrintInt(len)
#     SysPrintChar('\n')
#     SysExit
# end function main
#
# STACK FRAME
# MARS initializes $sp to 0x7FFF_EFFC before calling main(). Main() will allocate a stack frame contain-
# ing local variables 'string' (84 bytes) and 'len' (4 bytes).
#
# +----------+
# |          | 0x7FFF_EFFC [$sp+ 88] <-- $sp points here on entry to main()
# +----------+
# | string   | 0x7FFF_EFA8 [$sp+ 4, $sp+87]
# +----------+
# | len      | 0x7FFF_EFA4 [$sp+ 0, $sp+ 3]
# +----------+
#
# I arbitrarily chose len to be at the top of the stack frame, with string below it. Alternatively, I
# could have defined string to be at 0($sp), meaning that len would be at 84($sp). Either way is fine
# as it does not affect the behavior or the efficiency of the code.
#
# The total size of the allocated stack frame is 4 + 84 = 88 bytes. Note that because of word alignment,
# len and string are both stored at addresses that are divisible by 4, i.e., len and string are word
# aligned.
#
# Note tha main() is not a leaf procedure because it calls strlen() but main() does not return using
# jr $ra like other functions (it exits the program by calling SysExit). For this reason, we do not need
# to save $ra in main's stack frame.
#-------------------------------------------------------------------------------------------------------
main:
# int len, char string[BUF_LEN]
    addi    $sp, $sp, -88                # Allocate local vars in stack frame

# SysPrintStr("Enter a string (length <= 80)? ")
    addi    $v0, $zero, SYS_PRINT_STR    # $v0 ← SysprintStr service code
    la      $a0, s_prompt                # $a0 ← addr of s_prompt
    syscall                              # SysPrintStr("Enter a string (length <= 80)? ")

# string ← SysReadStr(string, SYS_RS_LEN)
    addi    $v0, $zero, SYS_READ_STR     # $v0 ← SysReadStr service code
    addi    $a0, $sp, 4                  # $a0 ← &string
    addi    $a1, $zero, SYS_RS_MAX       # $a1 ← max num of chars to read
    syscall                              # SysReadStr(string, SYS_RS_LEN)

# len ← strlen(string)
    addi    $a0, $sp, 4                  # $a0 ← &string
    jal     strlen                       # $v0 ← strlen(string)
    sw      $v0, 0($sp)                  # len ← strlen(string)

# SysPrintInt(len)
    addi    $v0, $zero, SYS_PRINT_INT    # $v0 ← SysPrintInt service code
    lw      $a0, 0($sp)                  # $a0 ← len
    syscall                              # SysPrintInt(len)

# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR   # $v0 ← SysPrintChar service code
    addi    $a0, $zero, '\n'             # $a0 ← ASCII value of '\n' (10)
    syscall                              # SysPrintChar('\n')

# Deallocate stack frame
    addi    $sp, $sp, 88                 # Deallocate stack frame

# SysExit()
    addi    $v0, $zero, SYS_EXIT         # $v0 ← SysExit service code
    syscall                              # SysExit()

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
# int strlen(string sample)
strlen:
# int len, char string[BUF_LEN]
    addi    $sp, $sp, -8                 # Allocate local vars in stack frame
    
    addi    $t0, $zero, 0		 # int index = 0
    add     $t1, $zero, $a0		 # string (a0) -> $t1
    sw      $t0, 0($sp)			 # $sp[0:3] = index
    addi    $t5, $zero, '\0'		 # $t5 = ASCII value of '\0'
begin_loop:
    # if(string[index] != '\0')
    lw      $t0, 0($sp)			 # $t0 = index (read from local stack) 
    add     $t2, $t0, $t1		 # $t2 -> &string + index
    lb      $t3, 0($t2)			 # $t3 -> string[index]
    beq     $t3, $t5, end_loop
    #index++
    addi    $t0, $t0, 1			 # index++
    #store index
    sw      $t0, 0($sp)			 # saving index to local stack
    #jump to begin_loop
    j       begin_loop			 # jump to start of loop
end_loop:
    addi    $t0, $t0, -1    		 # to offset the '\n' from user input
    add     $v0, $zero, $t0		 # setting up the reurn registers 
    # Deallocate stack frame
    addi    $sp, $sp, 8                  # Deallocate stack frame
    # Return back to calling function
    jr      $ra
    
