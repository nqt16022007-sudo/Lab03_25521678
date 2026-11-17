.data
n:      .word 20                # thay doi gia tri n tai day de do (0, 1, 2, 10, 15, 19, 20)
msg1:   .asciiz "F("
msg2:   .asciiz ") = "

.text
.globl main

# main: doc n tu .data, goi fib_rec (hoac fib_iter) va in F(n) = <ket qua>
# Tham so  : khong
# Tra ve   : khong (ket thuc bang syscall 10)
# Thanh ghi: $a0, $v0, $s0
main:
        lw    $a0, n            # nap n vao $a0
        jal   fib_rec           # doi thanh 'jal fib_iter' khi do ban vong lap
        move  $s0, $v0          # luu ket qua F(n)

        li    $v0, 4
        la    $a0, msg1         # in "F("
        syscall

        lw    $a0, n
        li    $v0, 1            # in gia tri n
        syscall

        li    $v0, 4
        la    $a0, msg2         # in ") = "
        syscall

        move  $a0, $s0
        li    $v0, 1            # in gia tri F(n)
        syscall

        li    $v0, 10           # thoat chuong trinh
        syscall

# fib_rec: tinh F(n) bang de quy dung theo dinh nghia (thu tuc khong la)
# Tham so  : $a0 = n (n >= 0)
# Tra ve   : $v0 = F(n)
# Thanh ghi: $s0 (luu n), $s1 (luu F(n-1)), $ra
fib_rec:
        addi  $sp, $sp, -12     # mo dau: cap khung ngan xep 3 word (12 byte)
        sw    $ra, 8($sp)       # cat dia chi tro ve
        sw    $s0, 4($sp)       # cat $s0
        sw    $s1, 0($sp)       # cat $s1

        slti  $t0, $a0, 2       # kiem tra truong hop co so: n < 2?
        beq   $t0, $zero, fr_rec
        move  $v0, $a0          # F(0) = 0, F(1) = 1
        j     fr_done

fr_rec:
        move  $s0, $a0          # giu n qua cac loi goi de quy
        addi  $a0, $s0, -1      # tham so n - 1
        jal   fib_rec           # tinh F(n - 1)
        move  $s1, $v0          # luu F(n - 1) vao $s1

        addi  $a0, $s0, -2      # tham so n - 2
        jal   fib_rec           # tinh F(n - 2)
        add   $v0, $s1, $v0     # $v0 = F(n - 1) + F(n - 2)

fr_done:
        lw    $s1, 0($sp)       # ket thuc: khoi phuc thanh ghi
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12      # thu hoi khung ngan xep
        jr    $ra

# fib_iter: tinh F(n) bang vong lap (thu tuc la)
# Tham so  : $a0 = n
# Tra ve   : $v0 = F(n)
# Thanh ghi: $t0-$t3
fib_iter:
        move  $v0, $zero        # a = F(0)
        li    $t0, 1            # b = F(1)
        move  $t1, $zero        # i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     # a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra
