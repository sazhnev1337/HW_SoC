# ДЗ 1. arm и эмуляция на QEMU
###  Работа с емулятором:
```bash
arm-linux-gnueabi-as hello.s -o hello.o # создание объектного файла
arm-linux-gnueabi-ld hello.o -o hello    # линкуем

```
Так как QEMU интегрируется в ядро Linux, Ubuntu знает, что делать с ARM-файлами. Можно запустить исполняемый файл так, будто это родная программа
```shell
./hello
```

---
### Cheat sheet базовых команд ARM-ассемблера (сгенерировано Gemini 3.1 pro preview)

#### 1. Перемещение данных (Регистр ↔ Регистр)
* **`MOV r0, r1`** — Скопировать значение из `r1` в `r0`.
* **`MOV r0, #5`** — Записать число `5` в регистр `r0` (символ `#` означает константу).
* **`MVN r0, r1`** — Скопировать инвертированное значение (Move NOT).
#### 2. Работа с памятью (Регистр ↔ Оперативная память)
Нельзя прибавить число напрямую к переменной в памяти. Сначала нужно загдрузить её в регистр, прибавить, а потом выгрузить обратно.
* **`LDR r0, =message`** — (Load Register) Загрузить *адрес* метки `message` в регистр `r0`.
* **`LDR r0, [r1]`** — Загрузить в `r0` *значение* из оперативной памяти по адресу, который лежит в `r1`.
* **`STR r0, [r1]`** — (Store Register) Сохранить значение из `r0` в память по адресу из `r1`.
* **`PUSH {r0, r1}`** — Сохранить значения регистров в Стек .
* **`POP {r0, r1}`** — Достать значения из Стека обратно.
#### 3. Арифметика и Логика
* **`ADD r0, r1, r2`** — Сложение: `r0 = r1 + r2`.
* **`SUB r0, r1, #1`** — Вычитание: `r0 = r1 - 1`.
* **`MUL r0, r1, r2`** — Умножение: `r0 = r1 * r2`.
* **`AND r0, r1, r2`** — Побитовое И (логическое умножение).
* **`ORR r0, r1, r2`** — Побитовое ИЛИ (логическое сложение).
* **`LSL r0, r1, #1`** — Логический сдвиг влево (Logical Shift Left). Сдвиг на 1 бит влево эквивалентен умножению на 2. Это работает в разы быстрее команды `MUL`!
#### 4. Ветвления / Циклы
* **`CMP r0, r1`** — (Compare) Сравнить `r0` и `r1`. Команда  меняет флаги состояния внутри процессора (например, флаг Z — Zero, если они равны).
Сразу после `CMP` используются команды условного прыжка (Branch):
* **`BEQ label`** — (Branch if EQual) Прыгнуть на `label`, если числа были **равны**.
* **`BNE label`** — (Branch if Not Equal) Прыгнуть, если **не равны**.
* **`BGT label`** — (Branch if Greater Than) Прыгнуть, если `r0` **больше** `r1`.
* **`BLT label`** — (Branch if Less Than) Прыгнуть, если **меньше**.
* **`BLE label`** — (Branch if Less or Equal) Прыгнуть, если **меньше или равно**.
* **`B label`** — Безусловный прыжок (прыгнуть в любом случае).
#### 5. Вызов функций
* **`BL printf`** — (Branch with Link) Прыгнуть в функцию `printf`, но при этом **сохранить адрес возврата** в `lr` (Link Register). 
* **`BX lr`** — (Branch and eXchange) Вернуться туда, откуда нас вызвали (используется в конце функций вместо `return`).
#### Суффикс `S`

В ARM арифметические операции не меняют флаги. Для этого нужно дописывать команде отдельный флаг `S`:
```arm-asm
SUBS r1, r1, #1  @ Вычесть 1 И обновить флаги
BEQ end_loop     @ Теперь сработает идеально
```

---
### Код
```arm-asm

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

```

Добавленя часть, которая выводит результат в консоль, чтобы было проще отлаживать код. Делегировал эту задачу Claude: Sonnet 4.6.

# Дз 2 часть 1. Моргание светодиодом.
Находится по пути: `./led_blink_button_x2`.

Мограние происходит по прерыванию от таймера `tim3`. Опрос кнопки происходит в основном цикле. Описание `CallBack` для обработчика прерываний:
```c
/* USER CODE BEGIN 4 */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {

    if (htim->Instance == TIM3) {
        HAL_GPIO_TogglePin(GPIOI, LD1_Pin);
    }
    
}
/* USER CODE END 4 */
```

Опрос кнопки в основном цикле. Если происходит нажатие, то меняется содержимое регистра `ARR` согласно массиву определяющему набор периодов.
```c
  while (1)
  {
    if (HAL_GPIO_ReadPin(B_USER_GPIO_Port, B_USER_Pin) == GPIO_PIN_SET) {
      // Кнопка нажата 

      while (HAL_GPIO_ReadPin(B_USER_GPIO_Port, B_USER_Pin) == GPIO_PIN_SET) ;  // Ждeм пока кнопка будет отпущена

      freq_index++;
      if  (freq_index == 5) freq_index = 0; 

      __HAL_TIM_SET_AUTORELOAD(&htim3, periods[freq_index]);
      __HAL_TIM_SET_COUNTER(&htim3, 0);   // Обнуление
    }
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}
```

Определение переменных:
```c
/* USER CODE BEGIN PV */
uint32_t periods[] = {5400-1, 2700-1, 1350-1, 675-2, 338-1};
uint8_t freq_index = 0;
```