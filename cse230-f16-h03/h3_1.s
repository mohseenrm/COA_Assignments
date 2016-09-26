#*******************************************************************************************************
# FILE: h3_1.s
#
# CSE/EEE 230 Comp. Org. and Assemb. Lang. Program. Fall 2016 - Homework 3, Exercise 1.
# SECTION: MWF 2:00-2:50
#
# DESCRIPTION
# The program prompts for and reads two integers a and b. It then calculates and displays the sum of a
# and b, the difference between a and b, the product of a and b, the quotient from dividing a by b, and
# the remainder from dividing a by b.
#
# AUTHOR INFO
# Mohseen Mukaddam ( mohseen@asu.edu )
# Vishnu (vnnarang@asu.edu)
#*******************************************************************************************************

#=======================================================================================================
# EQUIVALENTS
#=======================================================================================================

# Define equivalents for useful service codes. See pp. 16-17 of the Ch. 2 lecture notes for a discussion
# of the .eqv directive.
.eqv SYS_EXIT         10   # SysExit()
.eqv SYS_PRINT_CHAR   11   # SysPrintChar()
.eqv SYS_PRINT_INT    1    # SysPrintInt()
.eqv SYS_PRINT_STR    4    # SysPrintStr()
.eqv SYS_READ_CHAR    12   # SysReadChar()
.eqv SYS_READ_INT     5    # SysReadInt()
.eqv SYS_READ_STR     8    # SysReadStr()

#=======================================================================================================
# DATA SECTION
#=======================================================================================================
#??? What goes here ???
.data

# Define string literals.
prompt_a:       .asciiz   "Enter a? "
prompt_b:       .asciiz   "Enter b (not zero)? "
out_sum:        .asciiz   "a + b = "
out_diff:       .asciiz   "a - b = "
out_product:    .asciiz   "a * b = "
out_quotient:   .asciiz   "a / b = "
out_modulus:    .asciiz   "a % b = "

# Define int global variables, all initialized to 0.
a:              .word     0   # int a;
b:              .word     0   # int b;
sum:            .word     0   # int sum;
diff:           .word     0   # int diff;
product:        .word     0   # int product;
quotient:       .word     0   # int quotient;
modulus:        .word     0   # int modulus;

#=======================================================================================================
# TEXT SECTION
#=======================================================================================================
#??? What goes here ???
.text
#-------------------------------------------------------------------------------------------------------
# main()
#
# PSEUDOCODE:
# global var int a, b, sum, diff, product, quotient, modulus
# function main()
#     SysPrintStr("Enter a? "); a = SysReadInt()
#     SysPrintStr("Enter b? "); b = SysReadInt()
#     sum = a + b; diff = a - b; product = a * b; quotient = a / b; modulus = a % b
#     SysPrintStr("a + b = "); SysPrintInt(sum);      SysPrintChar('\n')
#     SysPrintStr("a - b = "); SysPrintInt(diff);     SysPrintChar('\n')
#     SysPrintStr("a * b = "); SysPrintInt(product);  SysPrintChar('\n')
#     SysPrintStr("a / b = "); SysPrintInt(quotient); SysPrintChar('\n')
#     SysPrintStr("a % b = "); SysPrintInt(modulus);  SysPrintChar('\n')
#     SysExit()
# end function
#-------------------------------------------------------------------------------------------------------
main:
# SysPrintStr("Enter a? ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code (LI would also work)
    la      $a0, prompt_a                   # $a0 = &prompt_a
    syscall                                 # SysPrintStr(prompt_a)
    
# a = SysReadInt()
    addi    $v0, $zero, SYS_READ_INT        # $v0 = SysReadInt service code
    syscall                                 # $v0 = the integer that was entered
    la      $t0, a                          # $t0 = &a
    sw      $v0, 0($t0)                     # a = SysReadInt()
    
# SysPrintStr("Enter b? ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, prompt_b                   # $a0 = &prompt_b
    syscall                                 # SysPrintStr(prompt_b)

# b = SysReadInt()
    addi    $v0, $zero, SYS_READ_INT        # $v0 = SysReadInt service code
    syscall                                 # $v0 = the integer that was entered
    la      $t1, b                          # $t1 = &b
    sw      $v0, 0($t1)                     # b = SysReadInt()

# sum = a + b
    la $t0, a                               # $t0 = &a (hint: LA)
    lw $t0, 0($t0)                          # $t0 = a (hint: LW)
    la $t1, b                               # $t1 = &b (hint: LA)
    lw $t1, 0($t1)                          # $t1 = b (hint: LW)
    add $t2, $t0, $t1                       # $t2 = a + b (hint: ADD)
    la $t3, sum                             # $t3 = &sum (hint: LA)
    sw $t2, 0($t3)                          # sum = a + b (hint: SW)
    
# diff = a - b                              # Note that a and b are still in $t0 and $t1
    sub $t2, $t0, $t1                        # $t2 = a - b
    la $t3, diff                            # $t3 = &diff
    sw $t2, 0($t3)                          # diff = a - b
    
# product = a * b                           # Note that a and b are still in $t0 and $t1
    mul $t2, $t0, $t1                       # $t2 = a * b (hint: use MUL)
    la $t3, product                         # $t3 = &product
    sw $t2, 0($t3)                          # product = a * b
    
# quotient = a / b                          # Note that a and b are still in $t0 and $t1
    div $t0, $t1                            # LO = a / b
    mflo $t2                                # $t2 = a / b (hint: move the value from LO to $t2)
    la $t3, quotient                        # $t3 = &quotient
    sw $t2, 0($t3)                          # quotient = a / b
    
# modulus = a % b                           # Note that a and b are still in $t0 and $t1
    mfhi $t2                                # $t2 = a % b (hint: a % b is still in HI from the previous DIV)
    la $t3, modulus                         # $t3 = &modulus 
    sw $t2, 0($t3)                          # modulus = a % b
    
# SysPrintStr("a + b = ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, out_sum                    # $a0 = &out_sum
    syscall                                 # SysPrintStr(out_sum)
    
# SysPrintInt(sum)
    addi    $v0, $zero, SYS_PRINT_INT       # $v0 = SysPrintInt service code
    la      $t0, sum                        # $t0 = &sum
    lw      $a0, 0($t0)                     # $a0 = sum
    syscall                                 # SysPrintInt(sum)
    
# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR      # $v0 = SysPrintChar service code
    addi    $a0, $zero, '\n'                # $a0 = '\n'
    syscall                                 # SysPrintChar('\n')
    
# SysPrintStr("a - b = ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, out_diff                   # $a0 = &out_diff
    syscall                                 # SysPrintStr(out_diff)

# SysPrintInt(diff)
    addi    $v0, $zero, SYS_PRINT_INT       # $v0 = SysPrintInt service code
    la      $t0, diff                       # $t0 = &diff
    lw      $a0, 0($t0)                     # $a0 = diff
    syscall                                 # SysPrintInt(diff)

# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR      # $v0 = SysPrintChar service code
    addi    $a0, $zero, '\n'                # $a0 = '\n'
    syscall                                 # SysPrintChar('\n')
    
# SysPrintStr("a * b = ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, out_product                # $a0 = &out_dproduct
    syscall                                 # SysPrintStr(out_product) 
    addi    $v0, $zero, SYS_PRINT_INT       # $v0 = SysPrintInt service code
    
# SysPrintInt(product)
    la      $t0, product                    # $t0 = &product
    lw      $a0, 0($t0)                     # $a0 = product
    syscall                                 # SysPrintInt(product)

# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR      # $v0 = SysPrintChar service code
    addi    $a0, $zero, '\n'                # $a0 = '\n'
    syscall                                 # SysPrintChar('\n')
    
# SysPrintStr("a / b = ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, out_quotient               # $a0 = &out_quotient
    syscall                                 # SysPrintStr(out_quotient)
    addi    $v0, $zero, SYS_PRINT_INT       # $v0 = SysPrintInt service code

# SysPrintInt(quotient)
    la      $t0, quotient                   # $t0 = &quotient
    lw      $a0, 0($t0)                     # $a0 = quotient
    syscall                                 # SysPrintInt(quotient)

# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR      # $v0 = SysPrintChar service code
    addi    $a0, $zero, '\n'                # $a0 = '\n'
    syscall                                 # SysPrintChar('\n')
    
# SysPrintStr("a % b = ")
    addi    $v0, $zero, SYS_PRINT_STR       # $v0 = SysPrintStr service code
    la      $a0, out_modulus                # $a0 = &out_modulus
    syscall                                 # SysPrintStr(out_modulus)
    
# SysPrintInt(modulus)    
    addi    $v0, $zero, SYS_PRINT_INT       # $v0 = SysPrintInt service code
    la      $t0, modulus                    # $t0 = &modulus 
    lw      $a0, 0($t0)                     # $a0 = modulus
    syscall                                 # SysPrintInt(modulus)

# SysPrintChar('\n')
    addi    $v0, $zero, SYS_PRINT_CHAR      # $v0 = SysPrintChar service code
    addi    $a0, $zero, '\n'                # $a0 = '\n'
    syscall                                 # SysPrintChar('\n')

# SysExit()
    addi    $v0, $zero, SYS_EXIT            # $v0 = SysExit service code
    syscall                                 # SysExit()
