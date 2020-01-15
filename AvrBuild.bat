@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "D:\AT26\asm\LIN_AT128_3\labels.tmp" -fI -W+ie -C V2E -o "D:\AT26\asm\LIN_AT128_3\LIN_AT128.hex" -d "D:\AT26\asm\LIN_AT128_3\LIN_AT128.obj" -e "D:\AT26\asm\LIN_AT128_3\LIN_AT128.eep" -m "D:\AT26\asm\LIN_AT128_3\LIN_AT128.map" "D:\AT26\asm\LIN_AT128_3\Source\main.asm"
