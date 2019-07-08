#include <avr/io.h>

int
main(void)
{
    DDRD = (1 << 5);
    PORTD = (1 << 5);
    while(1)
    {}
}