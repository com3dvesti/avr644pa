#include <mega644p.h>
#include <stdio.h>  
#include <stdlib.h>
#include <string.h>
#include <delay.h>
#include <math.h>
#include <spi.h>
#include "func.h"
#define ADC_VREF_TYPE 0xC0
#define RG    0.0174532925         //радианы град


//#define mkgx    0.00875*RG*2			//mk гироскопы  rad
//#define mkgy    0.00875*RG*2			//mk гироскопы  rad
//#define mkgz    0.00875*RG*2			//mk гироскопы  rad
//#define mkax    0.001796		//mk аксы
//#define mkay    0.009589		//mk аксы
//#define mkaz    0.009589		//mk аксы.

#define mkgx    1			//mk гироскопы  rad
#define mkgy    1			//mk гироскопы  rad
#define mkgz    1			//mk гироскопы  rad
#define mkax    1		//mk аксы
#define mkay    1		//mk аксы
#define mkaz    1		//mk аксы
#define mkadc    5.01/4096		//mk adc
#define mkadc1    5.01/1024		//mk adc
#define GR    57.29577951				//град рад
#define GAIN   4.843952138e+01
#define pi     3.141592653
#define g     9.81
#define k1     -0.6602452139
#define k2     1.5891971372
#define Gain    56.29990544 
#define n_osr    256 
float dt=0.00875,timer;
long int data_adc;
//float Wx_sred = 0, Wy_sred = 0, Wz_sred = 0, ax_sred = 0, ay_sred = 0, az_sred = 0;
float dat_osr[20];
long int DAT_ADC[10];
char gotov,test;
bit bit_start,bit_kalib;
bit ads_1259,ad_7685;
int k_osr,k_del=1;
void read_gyr();
//void read_aks();
void init_ads1259();
void rreg();
void wreg();
void read_data();
void kalib_data();
unsigned char ii,i1,j,ads1259_CONFIG2=5;
unsigned int nn;
unsigned int DAT_7685[5];
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

// USART0 Receiver buffer
#define RX_BUFFER_SIZE0 8
char rx_buffer0[RX_BUFFER_SIZE0];

#if RX_BUFFER_SIZE0 <= 256
unsigned char rx_wr_index0,rx_rd_index0,rx_counter0;
#else
unsigned int rx_wr_index0,rx_rd_index0,rx_counter0;
#endif

// This flag is set on USART0 Receiver buffer overflow
bit rx_buffer_overflow0;

// USART0 Receiver interrupt service routine
interrupt [USART0_RXC] void usart0_rx_isr(void)
{
char status,data;
PORTD.4=1;
status=UCSR0A;
data=UDR0; data=UDR0;
PORTD.6=1;delay_us(2);putchar(data);
// while((UCSR0A & 0x40));
  delay_us(100); PORTD.6=0;UCSR0A=0;
 if(data==0x72)  {   bit_start=1;PORTD.5=!PORTD.5;  } //  r вкл. 
 if(data==0x73)  {   bit_start=0;  } //  s вкл.
 if(data==0x7A)  {   timer=0;bit_kalib=1;  } //  z сброс. 
if(data==0x71)  {  ads_1259=0;ad_7685=1;PORTB.2=0;  } //   500khz.  bit_kalib q
if(data==0x77)  {  ads_1259=1;ad_7685=0;PORTB.2=1;   } //   500khz.  bit_kalib q
  //if(data==0x78)  {   test=1; bit_kalib=1; kalib(); } //  
  //if(data==0x63)  {   test=0; } //  
  if(data==0x31)  {   k_del=k_del+1;
   if(k_del>7) {k_del=0;} 
   ads1259_CONFIG2=k_del;init_ads1259();} //
  //if(data==0x32)  {   k_del=k_del-1; if(k_del<1) {k_del=1;} } //
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
   PORTD.4=0;
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART0 Receiver buffer
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
//#asm("sei")
//PORTB.3=!PORTB.3;
 
//PORTB.2=0;
TCCR0B=0x00;TCNT0=255-250;TCCR0B=0x03;
timer=timer+0.001;
//if(ads_1259) {PORTB.2=1;
//init_ads1259(); ads_1259=0,ad_7685=1; 
//delay_us(200);
//PORTB.2=0;//delay_us(10);PORTB.2=0;
//nn=0; //delay_us(50);

//}
//nn=nn+1;

//read_data();
//DAT_ADC[4]=nn;
//rreg(); 
//gotov=1;
}                                   
// Timer2 overflow interrupt service routine
interrupt [TIM2_OVF] void timer2_ovf_isr(void)
{
TCCR2B=0x00;TCNT2=255-250;TCCR2B=0x04;
PORTC.3=1;delay_us(2);PORTC.3=0;
if(ad_7685) { PORTB.4=1;delay_us(3);PORTB.4=0;delay_us(2);
//SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51 
DAT_7685[0]=(spi(0x00)<<0);DAT_7685[1]=spi(0x00);
DAT_7685[0]=DAT_7685[0]*256+DAT_7685[1];
gotov=1;}
}


// Pin change 8-15 interrupt service routine
interrupt [PC_INT1] void pin_change_isr1(void)
{
    if(!PINB.1) 
    {   
        //PORTB.2=0;
        PORTD.4=0;
        read_data(); 
        //rreg();
        PORTD.4=1;
        //PORTB.2=0; 
        
    }
}



void read_gyr()  
{   //DAT_ADC[3] = spi_rw(0x26|0x80, 0, CS_GYR);  // температура 
 
//    DAT_ADC[0] = spi_rw(0x28|0x80, 0, CS_GYR);
//    DAT_ADC[0] |= (unsigned int) spi_rw(0x29|0x80, 0, CS_GYR) << 8;
//    DAT_ADC[1] = spi_rw(0x2A|0x80, 0, CS_GYR);
//    DAT_ADC[1] |= (unsigned int) spi_rw(0x2B|0x80, 0, CS_GYR) << 8;
//    DAT_ADC[2] = spi_rw(0x2C|0x80, 0, CS_GYR);
//    DAT_ADC[2] |= (unsigned int) spi_rw(0x2D|0x80, 0, CS_GYR) << 8;
    
//    DAT_ADC[3] = spi_rw(0x26|0x80, 0, CS_GYR);  // температура  
   //DAT_ADC[3] = 245;
}



void rreg()  
{
SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51
PORTB.0 = 0;delay_us(2);
spi(0x20);spi(0x02);
DAT_ADC[4]=spi(0x00);DAT_ADC[5]=spi(0x00);DAT_ADC[6]=spi(0x00);
//DAT_ADC[6]=spi(0x00);

PORTB.0 = 1;delay_us(2);
}

void wreg()  
{
SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51
PORTB.0 = 0;delay_us(2);
spi(0x40);spi(0x01);
spi(0x14);spi(0x22);
//spi(0x11);
PORTB.0 = 1;delay_us(2);
}


void read_data()
{
SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51
PORTB.0 = 0;delay_us(1);
spi(0x12);DAT_ADC[0]=spi(0x00);DAT_ADC[1]=spi(0x00);DAT_ADC[2]=spi(0x00);
delay_us(1);
PORTB.0 = 1;
gotov=1;
}


void init_ads1259()
{
SPCR=0x55;SPSR=0x00;//0x56 0x5A 5e 51
PORTB.0 = 0;delay_us(2);
    spi(0x40);spi(0x08);
    spi(0x00);spi(0x1A);spi(ads1259_CONFIG2); //0x27
    spi(0x01);spi(0x00);spi(0x00);//OFC 0x000001 0x800001 0xffffff
    spi(0x00);spi(0x00);spi(0x40);// FSC 0x400000

    delay_us(2);PORTB.0 = 1;
}

                                      
void init_aks()
{    
 //   spi_rw(0x20, 0xC7, CS_AXS);
 //   spi_rw(0x21, 0xC9, CS_AXS);
 //   spi_rw(0x22, 0x00, CS_AXS);    
}

void kalib_data()
{
data_adc=(DAT_ADC[0]*65536+DAT_ADC[1]*256+DAT_ADC[2])<<8;
dat_osr[0]=dat_osr[0]+data_adc;
if (j==100) { dat_osr[1]=dat_osr[0]/100;j=0;dat_osr[0]=0;bit_kalib=0;}
j=j+1;
}





void main(void)
{
    #pragma optsize-
    CLKPR=0x80;
    CLKPR=0x00;
    #ifdef _OPTIMIZE_SIZE_
    #pragma optsize+
    #endif   
    

    PORTA=0x00;DDRA=0x0F;
    PORTB=0xfd;DDRB=0xfd; //

    PORTC=0x00;DDRC=0xff;
    PORTD=0xFF;DDRD=0xFE;

    // Timer/Counter 0 initialization
    TCCR0A=0x82;
    TCCR0B=0x03;
    TCNT0=0x00;
    OCR0A=0x00;
    OCR0B=0x00;
// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: 250,000 kHz
// Mode: Normal top=0xFF
// OC2A output: Disconnected
// OC2B output: Disconnected
ASSR=0x00;
TCCR2A=0x00;
TCCR2B=0x04;
TCNT2=0x00;
OCR2A=0x00;
OCR2B=0x00;
    // External Interrupt(s) initialization
    EICRA=0x00;
    EIMSK=0x00;
    //PCMSK0=0x02;
    //PCMSK1=0x01;
    //PCICR=0x02;//3
    //PCIFR=0x02;//3 
    

EICRA=0x00;
EIMSK=0x00;
PCMSK1=0x02;
PCICR=0x02;
PCIFR=0x02;
//PCMSK1=(0<<PCINT15) | (0<<PCINT14) | (0<<PCINT13) | (0<<PCINT12) | (0<<PCINT11) | (0<<PCINT10) | (0<<PCINT9) | (1<<PCINT8);
//PCICR=(0<<PCIE3) | (0<<PCIE2) | (1<<PCIE1) | (0<<PCIE0);
//PCIFR=(0<<PCIF3) | (0<<PCIF2) | (1<<PCIF1) | (0<<PCIF0);

    // Timer/Counter 0 Interrupt(s) initialization
    TIMSK0=0x01;
    // Timer/Counter 1 Interrupt(s) initialization
    TIMSK1=0x00;
    // Timer/Counter 2 Interrupt(s) initialization
    TIMSK2=0x01;
    
    // Analog Comparator initialization
    ADMUX=ADC_VREF_TYPE & 0xff;
    ADCSRA=0x8C;
    
    // SPI initialization
    SPCR=0x5e;
    SPSR=0x01;
    SPCR=0x52;
    SPSR=0x01;

    // TWI initialization
    // TWI disabled
    TWCR=0x00;
    // USART0 initialization   115200
    UCSR0A=0x00;//
    UCSR0B=0x98;
    UCSR0C=0x06;
    UBRR0H=0;//21
    UBRR0L=0x10;//21  115200   20
    UBRR0L=0;//21 230khz 
    UCSR0A=2;UBRR0H=0;UBRR0L=5;//4 500khz
    UCSR0A=2;UBRR0H=0;UBRR0L=11;//4 250khz 
    UCSR0A=2;UBRR0H=0;UBRR0L=0x19;//4 115khz
    //UBRR0L=1;//4 1250khz
    //UBRR0L=0;//21 500khz
    // USART1 initialization
    UCSR1A=0x02;
    // UCSR1B=0x98;    // interrupt ON
    UCSR1B=0x18;    // interrupt OFF
    UCSR1C=0x06;
    UBRR1H=0x01;
    UBRR1L=0x03;

    //PORTC.0=1;PORTC.1=1;
    init_ads1259(); //init gyroscopes 
    init_ads1259(); //init gyroscopes 
    //read_gyr();  init_gyr(); 
    //init_aks(); //init aks
    //read_aks();
    //bit_compass=1;
    //bit_kalib=1;
    
    //wreg(); wreg(); 
    PORTD.6=0; PORTD.4=0; 
    PORTB.0=1;PORTB.2=0;
    //delay_ms(10); 
// Watchdog Timer initialization
// Watchdog Timer Prescaler: OSC/2k
// Watchdog timeout action: Reset
#pragma optsize-
//WDTCSR=(0<<WDIF) | (0<<WDIE) | (0<<WDP3) | (1<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (0<<WDP0);
//WDTCSR=(0<<WDIF) | (0<<WDIE) | (0<<WDP3) | (0<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (0<<WDP0);
//WDTCSR=0x11;WDTCSR=0x01;
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

    #asm("sei")
    
    while (1)
    //PORTC.3=1;delay_us(10);PORTC.3=0;;
    //PORTB.3=!PORTB.3; 
    //putchar(0x55); 
   // bit_kalib=1;gotov=1;
     {   
     if(bit_kalib) {
      if(gotov==1)  {   gotov=0;kalib_data();}
         }   
  bit_start=1;
    if(bit_start)
    {   
    //gotov=1;     
        if(gotov==1) 
        {   
        gotov=0;
        data_adc=(DAT_ADC[0]*65536+DAT_ADC[1]*256+DAT_ADC[2])<<8;  
        //    PORTA.0=1; 
         //   k_del=1;
            //if(bit_kalib) {kalib();} else { read_data();} 
         //   read_data(); 
            //i1=i1+1;
            if(i1==15)
            { i1=0;                 
             //putchar(0x55);   
                //#asm("cli")
                PORTD.6=1;
                delay_us(1); 
                ads_1259=1;
                //putchar(0x55); 
                //printf("%9.3f %9.3f  %9.3f  %9.3f  %9.3f  %9.3f  %4.0f  \r\n ", mwxyz[0],mwxyz[1],mwxyz[2],maxyz[0],maxyz[1],maxyz[2],test*1.0); 
                //printf("%9.3f %6.0f %6.0f %6.0f %10.0f  \r\n ", timer,DAT_ADC[0]*1.0,DAT_ADC[1]*1.0,DAT_ADC[2]*1.0,(65536*DAT_ADC[0]+256*DAT_ADC[1]+DAT_ADC[2])*1.0); 
                //printf(" %9.3f %9.0f %3.0f %3.0f %3.0f\r\n ", timer,data_adc*1.0,DAT_ADC[4]*1.0,DAT_ADC[5]*1.0,DAT_ADC[6]*1.0);
                if(ads_1259)
                 {printf(" %9.3f  %3.0f   %10.7f \r\n ", timer,ads1259_CONFIG2*1.0,(data_adc-dat_osr[1])*10.0/(256*16777216));} 
                if(ad_7685) 
                {printf("%9.3f %9.5f   \r\n ", timer,DAT_7685[0]*2.5/65536); }
                //#asm("sei")  
                // ¬–≈ћя Ќ≈ѕ–ј¬»Ћ№Ќќ≈
                delay_us(40);
                PORTD.6=0; }
              i1=i1+1;  
            
        } 
    }
}

}