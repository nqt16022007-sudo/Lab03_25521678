.data
n:      .word 20                # gia tri n = 20 de do so lenh
msg1:   .asciiz "F("
msg2:   .asciiz ") = "

.text
.globl main

# main: doc n tu .data, goi fib_opt va in F(n) = <ket qua>
# Tham so  : khong
# Tra ve   : khong (ket thuc bang syscall 10)
# Thanh ghi: $a0, $v0, $s0
main:
        lw    $a0, n
        jal   fib_opt
        move  $s0, $v0

        li    $v0, 4
        la    $a0, msg1
        syscall

        lw    $a0, n
        li    $v0, 1
        syscall

        li    $v0, 4
        la    $a0, msg2
        syscall

        move  $a0, $s0
        li    $v0, 1
        syscall

        li    $v0, 10
        syscall

# fib_opt: tinh F(n) toi uu truong hop co so (khong cap khung khi n < 2)
# Tham so  : $a0 = n (n >= 0)
# Tra ve   : $v0 = F(n)
# Thanh ghi: $s0 (luu n), $s1 (luu F(n-1)), $ra
fib_opt:
        slti  $t0, $a0, 2       # kiem tra n < 2 truoc khi cap phat stack frame
        beq   $t0, $zero, fo_rec
        move  $v0, $a0          # F(0) = 0, F(1) = 1
        jr    $ra               # thoat truc tiep ma khong ton chi phi stack

fo_rec:
        addi  $sp, $sp, -12     # chi cap khung khi thuc su goi de quy (n >= 2)
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)

        move  $s0, $a0          # luu n
        addi  $a0, $s0, -1
        jal   fib_opt           # F(n - 1)
        move  $s1, $v0

        addi  $a0, $s0, -2
        jal   fib_opt           # F(n - 2)
        add   $v0, $s1, $v0

        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12
        jr    $ra
