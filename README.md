# Дз 1 часть 1
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