<font color="#FF0000"><b>CAUTION Still under construction</b></font>

# Zevios ICF3-Z Core

Zevios is original CPU of ICF3-Z. It is 8bit CPU which is implemented with a very small 
number of transistors, and works in areas that cannot be achieved with a 32bit CPU.
"16bit divided 8bit" can be executed in 17 cycles. With conditions, 
"24bit divided 8bit" can be executed in 17 cycles.
It has 16-bit compression instruction that is user defined.
Its instruction also be used as a function like a virtual machine. 

## Target Device

ASIC and FPGA

## HDL

icarus verilog
Xilinx Vivado
Other verilog

## Imprementaion size 

Xilinx FPGA(XC7A35TICSG324-1L)

| Zevios |LUT|FF|BRAM|LUT-RAM|Freq|
|:--|:--:|:--:|:--:|:--:|:--:|
|Area |387|197|1.5|10|160MHz|
|Perf |442|197|1.5|10|175MHz|

## Web site

[https://icf3z.idletime.tokyo](https://icf3z.idletime.tokyo) (Japanese)

## License

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see LICENSE for full text).

## Copyright

Copyright (c) 2019 Naoki Hirayama

## Notice

The ICF3-Z project aims not to use Japanese taxes.

## Contact

ICF3-Z & Zevios

E-mail : icf3z@idletime.tokyo
