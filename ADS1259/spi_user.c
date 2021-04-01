#include <mega644p.h>
#include <delay.h>
#include <spi.h>
#include "func.h"


// Оптимизировать задержки (до 2us)
char spi_rw(char address, char value, char cs_pin)
{
    char data = 0;
    PORTB = PORTB & ~(1 << cs_pin); // set 0 in cs_pin
    spi(address); 
    delay_us(1); 
    data = spi(value); 
    delay_us(1); 
    PORTB = PORTB | (1 << cs_pin); // set 1 in cs_pin 
    delay_us(1);
    return data;   
}