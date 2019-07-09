#!/usr/bin/env bash

external/avr-gcc-unwrapped/bin/avr-gcc -nostdinc -isystem external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include -isystem external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include-fixed -isystem external/avr-libc/avr/include "$@"