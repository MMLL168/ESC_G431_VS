
/**
  ******************************************************************************
  * @file    parameters_conversion_g4xx.h
  * @author  Motor Control SDK Team, ST Microelectronics
  * @brief   This file contains the definitions needed to convert MC SDK parameters
  *          so as to target the STM32G4 Family.
  *
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under Ultimate Liberty license
  * SLA0044, the "License"; You may not use this file except in compliance with
  * the License. You may obtain a copy of the License at:
  *                             www.st.com/SLA0044
  *
  ******************************************************************************
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef PARAMETERS_CONVERSION_G4XX_H
#define PARAMETERS_CONVERSION_G4XX_H

#include "drive_parameters.h"
#include "power_stage_parameters.h"
#include "mc_math.h"

/************************* CPU & ADC PERIPHERAL CLOCK CONFIG ******************/
#define SYSCLK_FREQ                      170000000uL
#define TIM_CLOCK_DIVIDER                1
#define ADV_TIM_CLK_MHz                  170 /* Actual TIM clk including Timer clock divider*/
#define ADC_CLK_MHz                      42
#define HALL_TIM_CLK                     170000000uL
#define APB1TIM_FREQ                     170000000uL

/*************************  IRQ Handler Mapping  *********************/
#define TIMx_BRK_M1_IRQHandler           TIM1_BRK_TIM15_IRQHandler
#define BEMF_ADC1_2_READING_IRQHandler   ADC1_2_IRQHandler

#define PERIOD_COMM_IRQHandler           TIM2_IRQHandler

#define ADC_TRIG_CONV_LATENCY_CYCLES     3.5
#define ADC_SAR_CYCLES                   12.5

#define M1_VBUS_SW_FILTER_BW_FACTOR      6u
/* ESC parameters conversion */
/* TIM2 capture runs with LF_TIMER prescaler, so thresholds must be in TIM2 ticks. */
#define ESC_CMD_TIM_FREQ                 (APB1TIM_FREQ / (LF_TIMER_PSC + 1U))
#define ESC_US_TO_TICKS(us)              ((uint32_t)(((uint64_t)ESC_CMD_TIM_FREQ * (uint64_t)(us)) / 1000000ULL))

/* PX4 throttle input range: 1000 us .. 2000 us */
#define ESC_TON_MIN                      ESC_US_TO_TICKS(1000U)
#define ESC_TON_MAX                      ESC_US_TO_TICKS(2000U)
/* Arming: if 800 us <= TOn < 1000 us for ARMING_TIME, ESC is armed. */
#define ESC_TON_ARMING                   ESC_US_TO_TICKS(800U)

/* USER CODE BEGIN Additional parameters */

/* USER CODE END Additional parameters */

#endif /*PARAMETERS_CONVERSION_G4XX_H*/

/******************* (C) COPYRIGHT 2025 STMicroelectronics *****END OF FILE****/
