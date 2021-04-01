/*****************************************************
This program was produced by the
CodeWizardAVR V2.05.0 Professional
Automatic Program Generator
© Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 15.03.2021
Author  : 
Company : 
Comments: 


Chip type               : ATmega644PA
Program type            : Application
AVR Core Clock frequency: 16,000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 1024
*****************************************************/

#include <mega644a.h>
#include <stdio.h>
//#include <stlib.h>
#include <delay.h>
#include <spi.h>
#include <math.h>
unsigned char KOEFF_VEL=255-250;

unsigned int data_adc;
unsigned int DAT_ADC[10];
float dt=0.00875,timer;
bit ad_7685;
bit gotov,adc_en;
unsigned int DAT_7685[5];
unsigned int DATA[500],nk=0;       // счетчик сэмплов измерений
unsigned int nk0=0;    //счетчик передаваем. данных
void read_data_adc16();

#ifndef RXB8
#define RXB8 1
#endif

#ifndef TXB8
#define TXB8 0
#endif

#ifndef UPE
#define UPE 2
#endif

#ifndef DOR
#define DOR 3
#endif

#ifndef FE
#define FE 4
#endif

#ifndef UDRE
#define UDRE 5
#endif

#ifndef RXC
#define RXC 7
#endif

#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)

// USART Receiver buffer
#define RX_BUFFER_SIZE0 8
char rx_buffer0[RX_BUFFER_SIZE0];

#if RX_BUFFER_SIZE0 <= 256
unsigned char rx_wr_index0,rx_rd_index0,rx_counter0;
#else
unsigned int rx_wr_index0,rx_rd_index0,rx_counter0;
#endif

// This flag is set on USART Receiver buffer overflow
bit rx_buffer_overflow0;

// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
char status,data;
status=UCSR0A;
data=UDR0;  
if(data==0x71) {KOEFF_VEL=KOEFF_VEL+2; if(KOEFF_VEL>200) KOEFF_VEL=150; }
if(data==0x77) {KOEFF_VEL=KOEFF_VEL-2; if(KOEFF_VEL<20) KOEFF_VEL=50; }
//gotov=1;
if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
   {
   rx_buffer0[rx_wr_index0++]=data;
#if RX_BUFFER_SIZE0 == 256
   // special case for receiver buffer size=256
   if (++rx_counter0 == 0)
      {
#else
   if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
   if (++rx_counter0 == RX_BUFFER_SIZE0)
      {
      rx_counter0=0;
#endif
      rx_buffer_overflow0=1;
      }
   }
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
char data;
while (rx_counter0==0);
data=rx_buffer0[rx_rd_index0++];
#if RX_BUFFER_SIZE0 != 256
if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
#endif
#asm("cli")
--rx_counter0;
#asm("sei")
return data;
}
#pragma used-
#endif

// Standard Input/Output functions
#include <stdio.h>

// Timer 0 overflow interrupt service routine
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
    static int timer_ctr;
    TCCR0B=0x00;
    TCNT0=255-40;   //1000 250
    TCCR0B=0x03;
    //if (++timer_ctr >= 100)
   // {   
  //      gotov = 1; 
  //      timer_ctr = 0;
  //  }
    if(adc_en)  {
    PORTB.4=1;delay_us(4);PORTB.4=0;//старт АЦП
   // if(ad_7685) {
       // PORTB.4=1;delay_us(3);PORTB.4=0;delay_us(2);
        //SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51 
        DAT_7685[0]=(spi(0x00)<<0);DAT_7685[1]=spi(0x00);
        DAT_7685[0]=DAT_7685[0]*256+DAT_7685[1];
        DATA[nk]=DAT_7685[0];
        nk=nk+1;
        if(nk>500){adc_en=0;gotov=1;nk=0;} 
        }
        //gotov=1;  // готовность данных АЦП для передачи        
        timer=timer+0.001;
   // }
//gotov=1;
// putchar(0x55); putchar(0x33);putchar(0x39);
}
// Timer2 overflow interrupt service routine
interrupt [TIM2_OVF] void timer2_ovf_isr(void)
{
PORTD.7=0;
TCCR2B=0x00;
TCNT2=KOEFF_VEL;
TCCR2B=0x05;
delay_us(500);
PORTD.7=1;

}






void read_data_adc16()       // одноканальный АЦП         16 разрядный
{
SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51
PORTB.0 = 0;delay_us(1);
spi(0x12);DAT_ADC[0]=spi(0x00);DAT_ADC[1]=spi(0x00);DAT_ADC[2]=spi(0x00);
delay_us(1);
PORTB.0 = 1;
gotov=1;
}



// Declare your global variables here

void main(void)
{
// Declare your local variables here

// Crystal Oscillator division factor: 1
#pragma optsize-
CLKPR=0x80;
CLKPR=0x00;
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

// Input/Output Ports initialization
// Port A initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTA=0x00;
DDRA=0x00;

// Port B initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTB=0x00;
DDRB=0xBF;

// Port C initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTC=0x00;
DDRC=0x00;

// Port D initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTD=0x00;
DDRD=0xff;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: 250,000 kHz
// Mode: Normal top=0xFF
// OC0A output: Disconnected
// OC0B output: Disconnected
TCCR0A=0x00;
TCCR0B=0x03;
TCNT0=0x05;
OCR0A=0x00;
OCR0B=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer1 Stopped
// Mode: Normal top=0xFFFF
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: 125,000 kHz
// Mode: Normal top=0xFF
// OC2A output: Disconnected
// OC2B output: Disconnected
ASSR=0x00;
TCCR2A=0x00;
TCCR2B=0x05;
TCNT2=0x00;
OCR2A=0x00;
OCR2B=0x00;

// External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off
// Interrupt on any change on pins PCINT0-7: Off
// Interrupt on any change on pins PCINT8-15: Off
// Interrupt on any change on pins PCINT16-23: Off
// Interrupt on any change on pins PCINT24-31: Off
EICRA=0x00;
EIMSK=0x00;
PCICR=0x00;

// Timer/Counter 0 Interrupt(s) initialization
TIMSK0=0x01;
// Timer/Counter 0 Interrupt(s) initialization
TIMSK0=(0<<OCIE0B) | (0<<OCIE0A) | (1<<TOIE0);
// Timer/Counter 1 Interrupt(s) initialization
TIMSK1=0x00;

// Timer/Counter 2 Interrupt(s) initialization
TIMSK2=0x01;

// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART0 Mode: Asynchronous
// USART Baud Rate: 115200 (Double Speed Mode)
UCSR0A=0x02;
UCSR0B=0x98;
UCSR0C=0x06;
//UBRR0H=0x00;
//UBRR0L=0x10;
UBRR0H=0x00;
UBRR0L=0x03;    //500k
UBRR0H=0x00;
UBRR0L=0x01;      //1MEG

// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
ADCSRB=0x00;
DIDR1=0x00;

// ADC initialization
// ADC disabled
ADCSRA=0x00;

// SPI initialization
// SPI Type: Master
// SPI Clock Rate: 2*1000,000 kHz
// SPI Clock Phase: Cycle Start
// SPI Clock Polarity: Low
// SPI Data Order: MSB First
SPCR=0x51;
SPSR=0x01;

// TWI initialization
// TWI disabled
TWCR=0x00;

// Global enable interrupts
#asm("sei")
PORTD.6=0; 
PORTD.4=0; PORTD.5=0;  // биты для управления двигателем, один направление меняет, а другой разрешает работу контоллера(кит)
adc_en=1;gotov=1; nk0=0;
while (1)
{   
          //putchar(0x55);
          //gotov=1;  
        if(!adc_en) { 
              if(gotov) {  PORTD.6=1; delay_us(5);      //40
                  //printf("hello atmega644 vasia\r\n");
                 // printf("%9.3f %6.0f  %6.0f  %6.0f  %6.0f  %6.0f  %6.0f  %6.0f \r\n ", timer,wx,wy,wz,ax,ay,az,DAT_ADC[3]*1.0); 
                  // printf("%6.0f \r\n",KOEFF_VEL*1.0); 
                  
                  //printf("%9.3f %9.5f   \r\n ", timer,DAT_7685[0]*2.5/65536); 
                  printf("%6.3f %4.0f  \r\n ", DATA[nk0]*2.5/65536,nk0*1.0); 
                  //delay_us(10);//  
                  
                  PORTD.6=1;  gotov=1; 
                  if(nk0==500){nk0=0;adc_en=1;}
                  nk0=nk0+1;
            } 
       }
}
}
