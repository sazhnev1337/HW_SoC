.global _start

.text
_start:
    @ Системный вызов sys_write (вывод на экран)
    mov r0, #1          @ Файловый дескриптор 1 (stdout - экран)
    ldr r1, =message    @ Загружаем адрес нашей строки в регистр r1
    mov r2, #12         @ Длина строки (12 символов)
    mov r7, #4          @ Номер системного вызова sys_write (4 для ARM Linux EABI)
    svc #0              @ Вызов ядра (Supervisor Call, раньше назывался swi)

    @ Системный вызов sys_exit (корректное завершение программы)
    mov r0, #0          @ Код возврата 0 (всё ок)
    mov r7, #1          @ Номер системного вызова sys_exit (1)
    svc #0              @ Вызов ядра

.data
message:
    .ascii "Hello, ARM!\n"
