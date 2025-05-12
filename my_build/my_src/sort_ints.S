.section .data
ten_ints_text:
.asciz  "%d %d %d %d %d %d %d %d %d %d"

ten_ints_arr:
.align 4
.long 0,0,0,0,0,0,0,0,0,0
array_size = (. - ten_ints_arr)

#i can use rdi, rsi, rdx, rcx, r8, r9

.section .text
.globl main
.globl comp
.extern exit
.extern scanf

comp:
movq $0, %rax
movl (%rsi), %r10d
movl (%rdi), %r11d
cmpl %r10d, %r11d
jge comp_greater
cmpl %r10d, %r11d
je comp_equal
decq %rax
comp_equal:
ret
comp_greater:
incq %rax
ret


main:
#------scanf-----
load_scanf:
movq $5, %rax
leaq ten_ints_arr+36(%rip), %rbx
LOOP_START_SCANF:
cmpq $0 , %rax
JE finish_loop_scanf
pushq %rbx
subq $4, %rbx
decq %rax
JMP LOOP_START_SCANF
finish_loop_scanf:
leaq ten_ints_text(%rip), %rdi
leaq ten_ints_arr(%rip), %rsi
leaq ten_ints_arr+4(%rip), %rdx
leaq ten_ints_arr+8(%rip), %rcx
leaq ten_ints_arr+12(%rip), %r8
leaq ten_ints_arr+16(%rip), %r9
call scanf
addq $0x28, %rsp

#-------qsort-------
leaq ten_ints_arr(%rip), %rdi
movq $10, %rsi
movq $4, %rdx
leaq comp(%rip), %rcx
subq $8, %rsp
call qsort
addq $8, %rsp

#-------printf------
load_printf:
movq $5, %rax
leaq ten_ints_arr+36(%rip), %rbx
LOOP_START_PRINTF:
cmpq $0 , %rax
JE finish_loop_printf
pushq (%rbx)
subq $4, %rbx
decq %rax
JMP LOOP_START_PRINTF
finish_loop_printf:
leaq ten_ints_text(%rip), %rdi
leaq ten_ints_arr(%rip), %rax
movl (%rax), %esi
movl 4(%rax), %edx
movl 8(%rax), %ecx
movl 12(%rax), %r8d
movl 16(%rax), %r9d
call printf
addq $0x28, %rsp
#--------exit--------
pushq $0
call exit