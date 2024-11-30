.data
result_a: .space 4
result_b: .space 4
result_c: .space 4
sqrt_delta: .space 4

nghiem_duy_nhat: .asciiz "Phuong trinh co nghiem duy nhat: "
nghiem_kep: .asciiz "Phuong trinh co nghiem kep: "
vo_nghiem: .asciiz "Phuong trinh vo nghiem!"
vo_so_nghiem: .asciiz "Phuong trinh vo so nghiem!"
nghiem: .asciiz "Phuong trinh co 2 nghiem phan biet la:"
newline: .asciiz "\n"
nhapA: .asciiz "Moi nhap a: "
nhapB: .asciiz "Moi nhap b: "
nhapC: .asciiz "Moi nhap c: "
two: .float 2.0
four: .float 4.0
half: .float 0.5
x0: .float 999999999.0
.text
main:
    #input number 1
    addi $v0,$0,4  #In chuỗi
    la $a0, nhapA
    syscall
    addi $v0,$0,6	#Nhập a
    syscall
    la $a0, result_a
    swc1 $f0,0($a0)
    lw $t0,0($a0)	#lưu vào t0
    
    #input number 2
    addi $v0,$0,4  #In chuỗi
    la $a0, nhapB
    syscall
    addi $v0,$0,6	#Nhập b
    syscall 
    la $a0, result_b
    swc1 $f0,0($a0)
    lw $t1,0($a0)	#lưu vào t1
    
    #input number 3
    addi $v0,$0,4  #In chuỗi
    la $a0, nhapC
    syscall
    addi $v0,$0,6	#Nhập c
    syscall 
    la $a0, result_c
    swc1 $f0,0($a0)
    lw $t2,0($a0)	#lưu vào t2
    
    #Xét các trường hợp của phương trình bậc 2
    	#Kiểm tra nếu a = 0
    beq $t0, $0, a_bang_0
    j a_khac_0
    
end_program:    
    li $v0, 10                    # Syscall thoát chương trình
    syscall
    
#-------------------------------------------------------------------------------------
a_khac_0:
	#t0 = a, t1 = b, t2 = c
	#delta = b ^ 2 - 4ac
    	add $s1, $zero, $t1 	#s1 là b
    	add $s2, $zero, $t1	#s2 là b
    	jal multi	#b ^ 2
	add $k0, $zero, $v0 	#lưu b ^ 2 vào k0
	
    	la $a0, result_a 
    	lw $s1, 0($a0)	#Lấy a
    	
    	la $a0, result_c
    	lw $s2, 0($a0)	#Lấy c
    	
    	jal multi	#Tính ac
    	
    	add $s1, $zero, $v0
    	lw $s2, four
    	jal multi	#Tính 4ac
    	
    	# Tính b ^ 2 - 4ac
    	add $t0, $zero, $k0
    	add $t1, $zero, $v0
    	jal minus
    	
    	# Kiểm tra xem delta có bằng 0 không
    	beq $v0, $0, delta_bang_0
    	
    	# Kiểm tra xem delta có âm không
    	andi $t0, $v0, 0x80000000
    	srl $t0, $t0, 31
    	bne $t0, $0, delta_am  
     	
     	#Tiếp tục tính 2 nghiệm phân biệt
     	
     	#Tính x1--------------------------------------------
     	mtc1 $v0, $f12  # Chuyển nội dung của $t0 (số nguyên) vào $f12 (floating-point)
    	
     	jal SquareRoot
     	
     	add $k1, $zero, $v0	#lưu kết quả vào $k1
     	
     	add $t1, $zero, $v0	#sqrt(delta)
    	
    	la $a0, result_b 
    	lw $t0, 0($a0)	#lưu t1 = b
    	lui $t2, 0x8000          # Load 0x80000000 vào 16 bit cao của $t2 
    	ori $t2, $t2, 0x0000     # Kết hợp để tạo thành 0x80000000
   	xor $t0, $t0, $t2        # Đảo bit dấu của b
    	
    	jal add	#kết quả là -b + sqrt(delta)
    	
    	add $k0, $zero, $v0
    	
    	la $a0, result_a
    	lw $s1, 0($a0)
    	lw $s2, two
    	jal multi	#2 * a 
    	
    	add $a2, $zero, $v0	
    	add $a1, $zero, $k0	
    	
    	jal divide	# (-b + sqrt(delta)) / 2a
   	
	#In x1
    	sw $v0, 0($sp)	#Lưu vào sp để không mất giá trị

    	#In kết quả
    	la $a0, nghiem
    	li $v0, 4
    	syscall
    	
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#In dạng hex
    	lw $a0, 0($sp)
    	addi $v0, $0, 34
    	syscall
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	
  	lwc1 $f12, 0($sp)
   	li $v0, 2
    	syscall
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	# Tính x2-----------------------------------------------
     	add $t1, $zero, $k1	#sqrt(delta) 
     	
     	la $a0, result_b 
    	lw $t0, 0($a0)	#lưu t1 = b
    	lui $t2, 0x8000          # Load 0x80000000 vào 16 bit cao của $t2 
    	ori $t2, $t2, 0x0000     # Kết hợp để tạo thành 0x80000000
   	xor $t0, $t0, $t2        # Đảo bit dấu của b
    	
    	jal minus	#kết quả là -b - sqrt(delta)
    	add $k0, $zero, $v0
    	
    	la $a0, result_a
    	lw $s1, 0($a0)
    	lw $s2, two
    	jal multi
    	
    	add $a2, $zero, $v0	#lưu 2 * a vào a2
    	add $a1, $zero, $k0	#lưu -b + sqrt(delta) vào a1
    	
    	jal divide
    	
    	#In x2
    	sw $v0, 0($sp)
    	
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#In dạng hex
    	lw $a0, 0($sp)
    	addi $v0, $0, 34
    	syscall
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	
  	lwc1 $f12, 0($sp)
   	addi $v0, $zero, 2
    	syscall
    	
    	j end_program
delta_bang_0:
	la $a0, nghiem_kep
    	addi $v0, $zero, 4
    	syscall  
    	
    	#Tính 2 * a
    	la $a0, result_a 
    	lw $s1, 0($a0)
    	lw $s2, two
    	jal multi
    	
    	add $a2, $zero, $v0	#lưu vào a2
    	
    	#Tính -b
    	la $a0, result_b
    	lw $a1, 0($a0)
    	lui $t2, 0x8000          # Load 0x80000000 vào 16 bit cao của $t2 
    	ori $t2, $t2, 0x0000     # Kết hợp để tạo thành 0x80000000
   	xor $a1, $a1, $t2        # Đảo bit dấu của b
    	
    	jal divide
    	
    	sw $v0, 0($sp)
    	
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#In dạng hex
    	lw $a0, 0($sp)
    	addi $v0, $0, 34
    	syscall
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	
    	lwc1 $f12, 0($sp)
    	addi $v0, $zero, 2
    	syscall
    	j end_program
    	
delta_am:
    	la $a0, vo_nghiem
    	addi $v0, $zero, 4
    	syscall    	
	j end_program
#------------------------------------------------------------
a_bang_0:
	bne $t1, $0, b_khac_0	#b khác 0
	bne $t2, $0, c_khac_0
	la $a0, vo_so_nghiem
    	addi $v0, $zero, 4
    	syscall
	j end_program  		
c_khac_0:
	la $a0, vo_nghiem
    	addi $v0, $zero, 4
    	syscall
    	j end_program
b_khac_0:
    	la $a0, nghiem_duy_nhat
    	addi $v0, $zero, 4
    	syscall
    	#t1 = b, t2 = c
    	#x = -c / b
    	lui $t3, 0x8000          # Load 0x80000000 vào 16 bit cao của $t3
    	ori $t3, $t3, 0x0000     # Kết hợp để tạo thành 0x80000000
    	xor $t2, $t2, $t3        # Đảo bit dấu của c
    	
    	add $a1, $zero, $t2
    	add $a2, $zero, $t1
    	jal divide
    	
    	sw $v0, 0($sp)
    	
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#In dạng hex
    	lw $a0, 0($sp)
    	addi $v0, $0, 34
    	syscall
    	#Xuống dòng
    	la $a0, newline
    	li $v0, 4
    	syscall
    	
    	lwc1 $f12, 0($sp)
    	addi $v0, $zero, 2
    	syscall
    	
    	j end_program    
#---------------------------------------------------------------------------------------    
minus:
    lui $t2, 0x8000          # Load 0x80000000 vào 16 bit cao của $t2 
    ori $t2, $t2, 0x0000     # Kết hợp để tạo thành 0x80000000
    xor $t1, $t1, $t2        # Đảo bit dấu của $t2
add:
    srl $s1, $t0, 31         # Lấy bit dấu của $t1
    srl $s2, $t1, 31         # Lấy bit dấu của $t2 

    srl $s3, $t0, 23         # Dịch phải để lấy exponent của $t1
    andi $s3, $s3, 0xFF      # Lấy ra 8 bit exponent của $t1
    srl $s4, $t1, 23         # Exponent của $t2
    andi $s4, $s4, 0xFF      # Lấy ra 8 bit exponent của $t2

    andi $s5, $t0, 0x7FFFFF  # Lấy ra 23 bit fraction của $t1
    andi $s6, $t1, 0x7FFFFF  # Lấy ra 23 bit fraction của $t2

    ori $s5, $s5, 0x800000   # Biến đổi phần fraction về dạng 1.xxxxx (tức cộng thêm 1 cho phần nằm sau dấu phẩy)
    ori $s6, $s6, 0x800000   # Biến đổi phần fraction về dạng 1.xxxxx

    sub $t2, $s3, $s4        # Tính hiệu của exponents

    # Kiểm tra nếu exponents bằng nhau
    bne $t2, $0 adjust_exponents # Nếu khác nhau, căn chỉnh exponents

    # Nếu exponent bằng nhau, kiểm tra mantissa
    beq $s1 $s2 add_fractions
    sub $t3, $s5, $s6
    beq $t3, $zero, handle_zero_result # Nếu mantissa bằng nhau, kết quả là 0
    j finish_exponent_adjustment        # Nếu không bằng, tính toán

adjust_exponents:
    # Căn chỉnh exponent bằng cách dịch phần trị của số có exponent nhỏ hơn
    slt $t3 $t2 $0
    beq $t3 $0 align_2
    j align_1
align_2:
    shift_fraction_right_2:
        srl $s6, $s6, 1       # Dịch phải phần trị của $t2
        sub $t2, $t2, 1       # Giảm chỉ số dịch
        
        bne $t2, $0, shift_fraction_right_2
    	add $s4, $s3, $zero       # Đặt exponent của $t2 bằng exponent của $t1
    	j finish_exponent_adjustment

align_1:
    sub $t2, $s4, $s3        # Tính chỉ số dịch cho $t1
    shift_fraction_right_1:
        srl $s5, $s5, 1       # Dịch phải phần trị của $t1
        sub $t2, $t2, 1       # Giảm chỉ số dịch
        bne $t2, $0, shift_fraction_right_1
    	add $s3, $s4, $zero       # Đặt exponent của $t1 bằng exponent của $t2

finish_exponent_adjustment:
    # Kiểm tra nếu chỉ một trong hai dấu là âm
    bne $s1, $s2, check_one_negative_sign    # Nếu $s1 và $s2 khác nhau, chỉ có một số âm
    j add_fractions               # Nếu cả hai dấu giống nhau, thực hiện phép cộng

check_one_negative_sign:
    # Nếu phần mũ bằng nhau, so sánh phần trị
    #sub $t3, $s5, $s6
    slt $t3 $s5 $s6 #$t1<$t2?
    beq $t3, $0, subtract_2_from_1          # Nếu phần trị của $t1 lớn hơn hoặc bằng $t2, thực hiện $t1 - $t2
    j subtract_1_from_2                  # Nếu phần trị của $t2 lớn hơn $t1, thực hiện $t2 - $t1

handle_zero_result:
    move $s7, $zero               # Kết quả là 0
    move $s3, $zero
    move $s1, $zero
    j finalize_normalization              # Bỏ qua chuẩn hóa và lưu kết quả

subtract_2_from_1:
    sub $s7, $s5, $s6             # Thực hiện $t1 - $t2 nếu $t1 lớn hơn $t2
    j shift_left_loop             # Chuyển đến chuẩn hóa

subtract_1_from_2:
    sub $s7, $s6, $s5             # Thực hiện $t2 - $t1 nếu $t2 lớn hơn $t1
    move $s1, $s2                 # Gán dấu của $t2 cho kết quả
    j shift_left_loop             # Chuyển đến chuẩn hóa

add_fractions:
    add $s7, $s5, $s6             # Cộng phần trị nếu dấu giống nhau

normalize_fraction:
    srl $t3, $s7, 24              # Kiểm tra overflow
    bne $t3, $zero, shift_right
    j finalize_normalization

shift_left_loop:
    add $t3, $s7, $zero
    andi $t3, $t3, 0x800000       # Lấy bit thứ 23 của phần trị $s7
    bne $t3, $zero, finalize_normalization
    sll $s7, $s7, 1               # Dịch trái phần trị thêm 1 bit
    sub $s3, $s3, 1               # Giảm phần mũ
    j shift_left_loop             # Lặp lại để kiểm tra tiếp

shift_right:
    srl $s7, $s7, 1               # Dịch phải phần trị 1 bit
    add $s3, $s3, 1               # Tăng phần mũ

finalize_normalization:
    sll $s1, $s1, 31              # Kết hợp sign vào bit 31
    sll $s3, $s3, 23              # Kết hợp exponent vào bits 30-23
    andi $s7, $s7, 0x7FFFFF       # Giữ 23 bits cho phần trị

    or $t3, $s1, $s3
    or $t3, $t3, $s7              # Kết hợp với phần trị

    move $v0, $t3

    jr $ra

#------------------------------------------------------------------------------------------

multi:
# Nếu một trong hai số bằng 0, chuyển đến kết thúc
    beq $s1, $zero, end
    beq $s2, $zero, end

# Lấy dấu, phần mũ và phần định trị của số thứ nhất và số thứ hai 
    andi $v0, $s1, 0x80000000   # Lấy dấu (bit 31)
    srl $v0, $v0, 31            # Dịch phải 31 bit để đưa dấu về bit 0
    andi $a1, $s2, 0x80000000
    srl $a1, $a1, 31

    andi $v1, $s1, 0x7F800000   # Lấy phần mũ (8 bit từ bit 23)
    srl $v1, $v1, 23
    andi $a2, $s2, 0x7F800000
    srl $a2, $a2, 23

    andi $a0, $s1, 0x007FFFFF   # Lấy phần định trị (23 bit)
    andi $a3, $s2, 0x007FFFFF

    # Tính toán dấu và phần mũ mới
    xor  $t6, $v0, $a1          # Tính dấu mới
    add  $t7, $v1, $a2          # Tính phần mũ mới
    addi $t7, $t7, -254         # Trừ phần bù (bias)
    addi $t7, $t7, 127          # Chuyển phần mũ về dạng bias

    # Chuẩn hóa phần định trị và nhân
    ori  $a0, $a0, 0x00800000   # Thêm bit ẩn vào phần định trị
    ori  $a3, $a3, 0x00800000

    mult $a0, $a3               # Nhân hai phần định trị
    mfhi $t3                    # Lấy phần trên (32 bit cao)
    mflo $t0                    # Lấy phần dưới (32 bit thấp)
    sll  $t3, $t3, 16           # Dịch trái phần trên 16 bit
    srl  $t0, $t0, 16           # Dịch phải phần dưới 16 bit
    or   $t3, $t3, $t0          # Ghép hai phần lại

    # Kiểm tra và chuẩn hóa kết quả
    lui  $t1, 0x8000
    and  $t4, $t3, $t1          # Kiểm tra cần chuẩn hóa
    beqz $t4, shift
    addi $t7, $t7, 1            # Chuẩn hóa: tăng phần mũ

    # Chuẩn hóa phần định trị
shift:
    and $t2, $t3, $t1
    sll $t3, $t3, 1
    beqz $t2, shift

    # Ghép kết quả thành số IEEE 754
    srl  $t8, $t3, 9            # Dịch phải phần định trị để đưa vào vị trí
    move $v0, $t8
    sll  $t6, $t6, 31           # Đưa bit dấu lên đầu
    or   $v0, $v0, $t6          # Thêm dấu vào kết quả
    sll  $t7, $t7, 23           # Đưa phần mũ về vị trí
    or   $v0, $v0, $t7          # Thêm phần mũ vào kết quả

    jr   $ra                    # Kết thúc hàm

end:
    li   $v0, 0                 # Trả về kết quả = 0 nếu input = 0
    jr   $ra
    
#---------------------------------------------------------------------------------------

divide:
    
  #Kiểm tra trường hợp đặc biệt
   	beq $a1, $zero, exit	#so sánh: $a1 = 0 thì nhảy đến dividend0 (dividend = 0)
    #trường Sign: dịch phải cả dividend và divisor 31 bit. 
    	srl $t1, $a1, 31		#trường dấu của dividend = $t1
    	srl $t2, $a2, 31		#trường dấu của divisor = $t2
      #trường Exponent của dividend
     	sll $t3, $a1, 1 		
	srl $t3, $t3, 24
	subi $t3, $t3, 127	#Exponent của dividend = $t3
      #trường Exponent của divisor
	sll $t4, $a2, 1 			
	srl $t4, $t4, 24
	subi $t4, $t4, 127	#Exponent của divisor = $t4
      #trường Fraction của dividend
	sll $t5, $a1, 9		
	srl $t5, $t5, 9
	ori $t5, $t5, 0x00800000	#$t5 = 1bit + fraction dividend
      #trường Fraction của divisor
	sll $t6, $a2, 9		
	srl $t6, $t6, 9
	ori $t6, $t6, 0x00800000	#$t6 = 1bit + fraction divisor
	
   #Tính toán
   	xor $t1, $t1, $t2		#trường dấu của thương = $t1
   	sub $t2, $t3, $t4		#Exponent của thương = $t2
   	addu $t2, $t2, 127
   		
   	slt $s0, $t5, $t6		#kiểm tra (1 + Fraction dividend)/(1 + Fraction divisor) < 1 ?
   	li $t9, 0x00800000	#gán bit 23 của t9 = 1, phần còn lại = 0 để tính toán
   	li $t8, 24		# t8 = 24, lấy 24 bit
   	li $t3, 0		# t3 = 0, lưu fraction
   loop:
   	div $t5, $t6		#Fraction của thương = $t3 = (1 + Fraction dividend)/(1 + Fraction divisor) - 1
   	mflo $t7		#Thương
   	mfhi $t5		#Số dư
   	mulu $t7, $t7, $t9
   	addu $t3, $t3, $t7
   	srl $t9, $t9, 1
   	sll $t5, $t5, 1
   	subu $t8, $t8, 1
   	beqz $t5, endloop	#t5 = 0 nghĩa là số dư = 0
   	beqz $t8, endloop	#t8 = 0 nghĩa là đã lấy đủ 24 bit
   	j loop
   endloop:
   	beqz $s0,  notsubtract	#s0 = 0 nghĩa là fraction của dividend nhỏ hơn fraction của divisor
   	sll $t3, $t3, 1		#dịch trái 1 bit
   	subi $t2, $t2, 1		#trừ Exponent đi 1 bit
   notsubtract:
   	andi $t3, $t3, 0x007FFFFF	#thực hiện and để bỏ đi bit 1 ở bit thứ 23
   	
   #kết hợp các trường và lưu trong $t4
   	sll $t4, $t1, 31		#kết hợp các trường
   	sll $t2, $t2, 23		#kết hợp Exponent
   	or $t4, $t4, $t2
   	or $t4, $t4, $t3		#kết hợp Fraction
   #Kiểm tra số dư = 0
   	sll $t5, $t5, 1
   	slt $t5, $t6, $t5
   	beqz $t5,  remainder0
   	addi $t4, $t4, 1		#nếu số dư != 0, cộng thêm 1 bit để làm tròn
   remainder0:
   #chuyển dữ liệu sang số thực
   	#mtc1 $t4, $f12
   	add $v0, $0, $t4
   	
   	jr $ra
#Kết thúc chương trình (syscall)
exit:
	li $v0, 0
	jr $ra

    
#----------------------------------------------------------------------------------

SquareRoot:
    li $s2, 9                 # Đặt bộ đếm vòng lặp là 9

    l.s $f8, x0               # Tải giá trị đoán ban đầu vào $f8
    l.s $f10, half       # Tải 0.5 vào $f10

    start_loop:
        start_loop2:

            beq $s0, $s2, end_loop2  # Nếu bộ đếm vòng lặp trong bằng 9, kết thúc vòng lặp trong

            div.s $f9, $f12, $f8     # Tính S / xn
            add.s $f8, $f8, $f9      # Tính xn + S / xn
            mul.s $f8, $f10, $f8     # Tính 0.5 * (xn + S / xn)

            add $s0, $s0, 1          # Tăng bộ đếm vòng lặp trong
            b start_loop2            # Lặp lại vòng lặp trong
        end_loop2:

        li $s0, 0                   # Đặt lại bộ đếm vòng lặp trong

        beq $s1, $s2, end_loop      # Nếu bộ đếm vòng lặp ngoài bằng 9, kết thúc vòng lặp ngoài
        add $s1, $s1, 1             # Tăng bộ đếm vòng lặp ngoài
        b start_loop                # Lặp lại vòng lặp ngoài
    end_loop:
    
    swc1 $f8,0($sp)
    lw $v0, 0($sp)
    
    jr $ra                    # Trở về từ hàm
