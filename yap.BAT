SET PATH=C:\Keil\ARM\ARMCC\bin\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\TDM-GCC-64\bin;C:\Program Files\Git\cmd;C:\Program Files\vim;C:\Python37\Scripts\;C:\Python37\;C:\Users\crane\AppData\Local\Microsoft\WindowsApps;C:\Program Files\Microsoft VS Code\bin;C:\Users\crane\AppData\Local\atom\bin;C:\Python27\;
SET CPU_TYPE=S3C2440A
SET CPU_VENDOR=Samsung
SET UV2_TARGET=yap
SET CPU_CLOCK=0x00B71B00
"C:\Keil\ARM\ARMCC\bin\ArmAsm" --Via ".\output\head._ia"
"C:\Keil\ARM\ARMCC\bin\ArmCC" --Via ".\output\init_system.__i"
"C:\Keil\ARM\ARMCC\bin\ArmCC" --Via ".\output\key.__i"
"C:\Keil\ARM\ARMCC\bin\ArmCC" --Via ".\output\led.__i"
"C:\Keil\ARM\ARMCC\bin\ArmCC" --Via ".\output\main.__i"
"C:\Keil\ARM\ARMCC\bin\ArmCC" --Via ".\output\mmu.__i"
"C:\Keil\ARM\ARMCC\bin\ArmLink" --Via ".\output\Yap.lnp"
C:\Keil\ARM\ARMCC\bin\fromelf.exe ".\output\Yap.axf" --i32combined --output ".\output\Yap.hex"
fromelf.exe --bin -o yap.bin output/yap.axf
