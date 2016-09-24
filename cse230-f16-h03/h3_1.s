#*******************************************************************************************************
# FILE: h3_1.s
#
# CSE/EEE 230 Comp. Org. and Assemb. Lang. Program. Fall 2016 - Homework 3, Exercise 1.
# SECTION: <Enter your section, either: MWF 10:45 or MWF 2:00-2:50>
#
# DESCRIPTION
# The program prompts for and reads two integers a and b. It then calculates and displays the sum of a
# and b, the difference between a and b, the product of a and b, the quotient from dividing a by b, and
# the remainder from dividing a by b.
#
# AUTHOR INFO
# Mohseen Mukaddam ( mohseen@asu.edu )
# Vishnu (<Your-Partners-Email-Address>)
#*******************************************************************************************************

#=======================================================================================================
# EQUIVALENTS
#=======================================================================================================

# Define equivalents for useful service codes. See pp. 16-17 of the Ch. 2 lecture notes for a discussion
# of the .eqv directive.
.eqv SYS_EXIT         10   # SysExit()
.eqv SYS_PRINT_CHAR   11   # SysPrintChar()
.eqv SYS_PRINT_INT    ??   # SysPrintInt()
.eqv SYS_PRINT_STR    ??   # SysPrintStr()
.eqv SYS_READ_CHAR    ??   # SysReadChar()
.eqv SYS_READ_INT     ??   # SysReadInt()
.eqv SYS_READ_STR     ??   # SysReadStr()

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
modulus:        .modulus  0   # int modulus;

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
    ???                                     # $t0 = &a (hint: LA)
    ???                                     # $t0 = a (hint: LW)
    ???                                     # $t1 = &b (hint: LA)
    ???                                     # $t1 = b (hint: LW)
    ???                                     # $t2 = a + b (hint: ADD)
    ???                                     # $t3 = &sum (hint: LA)
    ???                                     # sum = a + b (hint: SW)
    
# diff = a - b                              # Note that a and b are still in $t0 and $t1
    ???                                     # $t2 = a - b
    ???                                     # $t3 = &diff
    ???                                     # diff = a - b
    
# product = a * b                           # Note that a and b are still in $t0 and $t1
    ???                                     # $t2 = a * b (hint: use MUL)
    ???                                     # $t3 = &product
    ???                                     # product = a * b
    
# quotient = a / b                          # Note that a and b are still in $t0 and $t1
    ???                                     # LO = a / b
    ???                                     # $t2 = a / b (hint: move the value from LO to $t2)
    ???                                     # $t3 = &quotient
    ???                                     # quotient = a / b
    
# modulus = a % b                           # Note that a and b are still in $t0 and $t1
    ???                                     # $t2 = a % b (hint: a % b is still in HI from the previous DIV)
    ???                                     # $t3 = &modulus 
    ???                                     # modulus = a % b
    
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
    ???                                     # $v0 = SysPrintStr service code
    ???                                     # $a0 = &out_diff
    ???                                     # SysPrintStr(out_diff)

# SysPrintInt(diff)
    ???                                     # $v0 = SysPrintInt service code
    ???                                     # $t0 = &diff
    ???                                     # $a0 = diff
    ???                                     # SysPrintInt(diff)

# SysPrintChar('\n')
    ???                                     # $v0 = SysPrintChar service code
    ???                                     # $a0 = '\n'
    ???                                     # SysPrintChar('\n')
    
# SysPrintStr("a * b = ")
    ???                                     # $v0 = SysPrintStr service code
    ???                                     # $a0 = &out_dproduct
    ???                                     # SysPrintStr(out_product) 
    ???                                     # $v0 = SysPrintInt service code
    
# SysPrintInt(product)
    ???                                     # $t0 = &product
    ???                                     # $a0 = product
    ???                                     # SysPrintInt(product)

# SysPrintChar('\n')
    ???                                     # $v0 = SysPrintChar service code
    ???                                     # $a0 = '\n'
    ???                                     # SysPrintChar('\n')
    
# SysPrintStr("a / b = ")
    ???                                     # $v0 = SysPrintStr service code
    ???                                     # $a0 = &out_quotient
    ???                                     # SysPrintStr(out_quotient)
    ???                                     # $v0 = SysPrintInt service code

# SysPrintInt(quotient)
    ???                                     # $t0 = &quotient
    ???                                     # $a0 = quotient
    ???                                     # SysPrintInt(quotient)

# SysPrintChar('\n')
    ???                                     # $v0 = SysPrintChar service code
    ???                                     # $a0 = '\n'
    ???                                     # SysPrintChar('\n')
    
# SysPrintStr("a % b = ")
    ???                                     # $v0 = SysPrintStr service code
    ???                                     # $a0 = &out_modulus
    ???                                     # SysPrintStr(out_modulus)
    
# SysPrintInt(modulus)    
    ???                                     # $v0 = SysPrintInt service code
    ???                                     # $t0 = &modulus 
    ???                                     # $a0 = modulus
    ???                                     # SysPrintInt(modulus)

# SysPrintChar('\n')
    ???                                     # $v0 = SysPrintChar service code
    ???                                     # $a0 = '\n'
    ???                                     # SysPrintChar('\n')

# SysExit()
    ???                                     # $v0 = SysExit service code
    ???                                     # SysExit()
