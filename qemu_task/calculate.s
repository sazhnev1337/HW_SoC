@   uint32_t calculate(uint32_t repeat, uint32_t x, uint32_t y)
@   {
@       uint32_t max = 10;
@       uint32_t res = 0;
@       for (int i = 0;  i < repeat; i++)
@       {
@           uint32_t sum = x + y;
@           uint32_t mul = x * y;
@           res += sum + mul;
@           x = (sum < max) ? sum : max;
@       }
@       return res;
@   }

.data
    repeat: .word 0x00000002
    x_val : .word 0x00000003
    y_val : .word 0x00000004
    res   : .word 0x00000000
.text
.global _start
_start:
    LDR r5, =repeat
    LDR r5, [r5]

    LDR r1, =x_val
    LDR r1, [r1]
    LDR r2, =y_val 
    LDR r2, [r2]

    MOV r6, #10         @ max = 10

    MOV r0, #0          @ res = 0

.loop:

    ADD r3, r1, r2      @ sum = x + y
    MUL r4, r1, r2      @ mul = x * y

    ADD r0, r0, r3      @ res += sum
    ADD r0, r0, r4      @ res += mul

    CMP r3, r6
    BGT .max_less       @ if sum > max: x = max
    MOV r1, r3          @ else: x = sum
    B .branch_end
.max_less:
    MOV r1, r6          @ x = max
.branch_end:
    SUBS r5, r5, #1     @ repeat--
    BNE .loop

    LDR r5, =res
    STR r0, [r5]


@ Часть написанная claude для вывода результата в консоль

@ --- конвертация r0 в ASCII и вывод ---

    @ r0 = число которое хотим напечатать (результат)
    
    @ буфер для строки на стеке
    SUB sp, sp, #8          @ выделяем 8 байт на стеке
    MOV r2, #'\n'
    STRB r2, [sp, #4]       @ newline в конец
    MOV r2, #0
    STRB r2, [sp, #5]       @ нуль-терминатор

    @ конвертируем число в цифры (для чисел 0-99)
    MOV r1, #10
    UDIV r2, r0, r1         @ r2 = r0 / 10  (десятки)
    MUL r3, r2, r1
    SUB r3, r0, r3          @ r3 = r0 % 10  (единицы)

    ADD r2, r2, #'0'        @ десятки → ASCII
    ADD r3, r3, #'0'        @ единицы → ASCII

    STRB r2, [sp]           @ кладём в буфер
    STRB r3, [sp, #1]

    @ syscall write(1, buf, 3)
    MOV r0, #1              @ fd = stdout
    MOV r1, sp              @ buf = адрес буфера
    MOV r2, #3              @ len = 3 (две цифры + newline)
    MOV r7, #4              @ syscall номер write
    SVC #0

    ADD sp, sp, #8          @ освобождаем стек

    @ syscall exit(0)
    MOV r0, #0
    MOV r7, #1
    SVC #0
