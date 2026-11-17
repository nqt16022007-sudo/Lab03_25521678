.data
str1:   .asciiz "kien truc may tinh"
str2:   .asciiz "mips"
str3:   .asciiz ""
str4:   .asciiz "a bc def"
str5:   .asciiz "goi long nhau phai luu thanh ghi ra"
bar:    .asciiz "|"
nl:     .asciiz "\n"

.text
.globl main

# main: kiem thu reverse_words voi 5 chuoi mau va in ket qua giua hai dau |
# Tham so  : khong
# Tra ve   : khong (ket thuc bang syscall 10)
# Thanh ghi: $a0, $v0
main:
        la    $a0, str1
        jal   test_case

        la    $a0, str2
        jal   test_case

        la    $a0, str3
        jal   test_case

        la    $a0, str4
        jal   test_case

        la    $a0, str5
        jal   test_case

        li    $v0, 10           # thoat chuong trinh
        syscall

# test_case: thu tuc phu goi reverse_words va in |chuoi| kem xuong dong
# Tham so  : $a0 = dia chi chuoi can kiem thu
# Tra ve   : khong
# Thanh ghi: $s0 (cat vao ngan xep), $ra, $a0, $v0
test_case:
        addi  $sp, $sp, -8
        sw    $ra, 4($sp)
        sw    $s0, 0($sp)

        move  $s0, $a0          # luu dia chi chuoi
        jal   reverse_words     # dao thu tu tu tai cho

        li    $v0, 4
        la    $a0, bar          # in '|'
        syscall

        move  $a0, $s0          # in chuoi sau khi dao
        syscall

        la    $a0, bar          # in '|'
        syscall

        la    $a0, nl           # in xuong dong
        syscall

        lw    $s0, 0($sp)
        lw    $ra, 4($sp)
        addi  $sp, $sp, 8
        jr    $ra

# strlen: tinh do dai chuoi ket thuc bang byte 0 (thu tuc la)
# Tham so  : $a0 = dia chi chuoi .asciiz
# Tra ve   : $v0 = so ky tu truoc byte 0
# Thanh ghi: $t0 (con tro duyet), $t1 (ky tu doc duoc)
strlen:
        move  $t0, $a0          # $t0 = p = str
sl_loop:
        lbu   $t1, 0($t0)       # doc 1 byte khong dau
        beq   $t1, $zero, sl_done
        addiu $t0, $t0, 1       # p++
        j     sl_loop
sl_done:
        subu  $v0, $t0, $a0     # do dai = p - str
        jr    $ra

# rev_range: dao nguoc tai cho doan ky tu tu dia chi $a0 den $a1 (thu tuc la)
# Tham so  : $a0 = dia chi ky tu dau, $a1 = dia chi ky tu cuoi
# Tra ve   : khong
# Thanh ghi: $t0, $t1 (hai ky tu can hoan doi)
rev_range:
rr_loop:
        sltu  $t0, $a0, $a1     # so sanh dia chi khong dau: $a0 < $a1?
        beq   $t0, $zero, rr_done
        lbu   $t0, 0($a0)       # $t0 = *left
        lbu   $t1, 0($a1)       # $t1 = *right
        sb    $t1, 0($a0)       # *left = $t1
        sb    $t0, 0($a1)       # *right = $t0
        addiu $a0, $a0, 1       # left++
        addiu $a1, $a1, -1      # right--
        j     rr_loop
rr_done:
        jr    $ra

# reverse_words: dao thu tu cac tu trong chuoi tai cho (thu tuc khong la)
# Tham so  : $a0 = dia chi chuoi
# Tra ve   : khong
# Thanh ghi: $s0 (dia chi dau chuoi), $s1 (con tro duyet), $s2 (dau tu hien tai), $ra
reverse_words:
        addi  $sp, $sp, -16     # mo dau: cap khung 4 word (16 byte)
        sw    $ra, 12($sp)      # cat dia chi tro ve
        sw    $s0, 8($sp)       # cat $s0
        sw    $s1, 4($sp)       # cat $s1
        sw    $s2, 0($sp)       # cat $s2

        move  $s0, $a0          # $s0 = dia chi dau chuoi
        jal   strlen            # $v0 = do dai chuoi
        beq   $v0, $zero, rw_done # neu chuoi rong thi thoat ngay

        # Buoc 1: Dao toan bo chuoi tu $s0 den $s0 + len - 1
        move  $a0, $s0
        addu  $a1, $s0, $v0
        addiu $a1, $a1, -1
        jal   rev_range

        # Buoc 2: Duyet tung tu va dao nguoc lai tung tu
        move  $s1, $s0          # $s1 = con tro duyet p
        move  $s2, $s0          # $s2 = dia chi bat dau tu hien tai (word_start)
rw_scan:
        lbu   $t0, 0($s1)       # doc ky tu hien tai *p
        beq   $t0, $zero, rw_last_word # gap ky tu ket thuc chuoi '\0'
        li    $t1, 32           # ma ASCII cua dau cach ' ' la 32 (0x20)
        beq   $t0, $t1, rw_space

        addiu $s1, $s1, 1       # p++
        j     rw_scan

rw_space:
        move  $a0, $s2          # dau tu
        addiu $a1, $s1, -1      # cuoi tu (ngay truoc dau cach)
        jal   rev_range
        addiu $s1, $s1, 1       # bo qua dau cach
        move  $s2, $s1          # bat dau tu moi
        j     rw_scan

rw_last_word:
        move  $a0, $s2          # dau tu cuoi cung
        addiu $a1, $s1, -1      # cuoi tu cuoi cung (ngay truoc '\0')
        jal   rev_range

rw_done:
        lw    $s2, 0($sp)       # ket thuc: khoi phuc thanh ghi
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addi  $sp, $sp, 16      # thu hoi khung ngan xep
        jr    $ra
