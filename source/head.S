;******************************************************************************       
; 异常向量，本程序中，除Reset和HandleIRQ外，其它异常都没有使用
;******************************************************************************   
	import init_system
	import  EINT_Handle
	import kernel_main
	export _start

DISABLE_IRQ equ 	0x80
DISABLE_FIQ equ 	0x40
SYS_MOD 	equ		0x1f
IRQ_MOD		equ		0x12
FIQ_MOD		equ		0x11
SVC_MOD		equ	  	0x13
ABT_MOD		equ  	0x17
UND_MOD 	equ  	0x1b
MOD_MASK	equ 	0x1f

IRQ_MODE_STACK		equ	0x32f00000
FIQ_MODE_STACK		equ	0x32e00000
SVC_MODE_STACK		equ	0x32d00000
SYS_MODE_STACK 		equ 0x32c00000

	AREA    RESET,CODE,READONLY
	PRESERVE8    ;8 

	IMPORT  |Image$$ER_ROM1$$RO$$Base|   ; Base of ROM code 
	IMPORT  |Image$$ER_ROM1$$RO$$Limit|  ; End of ROM code (=start of ROM data) 
	IMPORT  |Image$$RW_RAM1$$RW$$Base|   ; Base of RAM to initialise 
	IMPORT  |Image$$RW_RAM1$$ZI$$Base|   ; Base and limit of area 
	IMPORT  |Image$$RW_RAM1$$ZI$$Limit|  ; to zero initialise 

_start
   	b   Reset


HandleUndef
    b   .			 		;0x04: 未定义指令中止模式的向量地址
Handle_swi
    b   .					;0x08: 管理模式的向量地址，通过SWI指令进入此模式
HandlePrefetchAbort
    b   .					; 0x0c: 指令预取终止导致的异常的向量地址
HandleDataAbort
    b  	HandleDataAbort		; 0x10: 数据访问终止导致的异常的向量地址
HandleNotUsed
    b   .					; 0x14: 保留
Handle_irq
    b   HandleIRQ			; 0x18: 中断模式的向量地址
HandleFIQ
    b   .					; 0x1c: 快中断模式的向量地址

Reset

    msr cpsr_cxsf, #0xd2    ; 进入中断模式
	ldr		r0, =IRQ_MODE_STACK
	mov		sp, r0

	msr     CPSR_cxsf, #(DISABLE_FIQ :OR: DISABLE_IRQ :OR: SVC_MOD)
	ldr		r0, =SVC_MODE_STACK
	mov		sp, r0

	msr     CPSR_cxsf, #(DISABLE_FIQ :OR: DISABLE_IRQ :OR: FIQ_MOD)
	ldr		r0, =FIQ_MODE_STACK
	mov		sp, r0
    
	msr cpsr_cxsf, #0xdf	;系统模式
	ldr		r0, =SYS_MODE_STACK
	mov		sp, r0

	mrc    p15, 0, r0, c1, c0, 0    
	bic    r0, r0, #0x0001          ;禁用MMU
	mcr    p15, 0, r0, c1, c0, 0    ;tq2440 运行ok的代码直接拿到jz2440上运行异常
                                    ;现象: 通过jlink第一次仿真运行是可以的,然而结束仿真后在不断电的情况下再次
                                    ;仿真就会死掉(死在禁用看门狗的那条语句)
                                    ;可能原因:jz440 和 tq2440可能(具体是不是我没有研究)是jtag引脚接的不同(reset脚?) 
                                    ;断电重启后p15处理器被复位,mmu是禁用状态,然而jz2440在不断电重新载入程序后
                                    ;并不会复位p15处理器,导致mmu还是开启状态,然而这时候的清bss段或其他的内存操
                                    ;作有可能会清掉mmu映射表,从而导致访问内存出现异常
                                    ;!!!!!!这个地方要详细检查,因为mmu映射表不应该出现在bss段,或者异常并不是因为映射表被清掉导致!!!!!!!
	bl copy_proc_beg

	bl init_system
    
    ldr lr, =halt_loop      ; 设置返回地址
    ldr pc, =kernel_main           ; 调用main函数

copy_proc_beg
	adr	r0, _start
	ldr	r2, BaseOfROM
	cmp	r0, r2
	ldreq	r0, TopOfROM
	beq	InitRam	
	ldr r3, TopOfROM
0	
	ldmia	r0!, {r4-r7}
	stmia	r2!, {r4-r7}
	cmp	r2, r3
	bcc	%B0
	
	sub	r2, r2, r3
	sub	r0, r0, r2				
		
InitRam	
	ldr	r2, BaseOfBSS
	ldr	r3, BaseOfZero	
0
	cmp	r2, r3
	ldrcc	r1, [r0], #4
	strcc	r1, [r2], #4
	bcc	%B0	

	mov	r0,	#0
	ldr	r3,	EndOfBSS
1	
	cmp	r2,	r3
	strcc	r0, [r2], #4
	bcc	%B1
	
	mov pc, lr

halt_loop
    b   halt_loop

HandleIRQ
	sub lr, lr, #4                  ; 计算返回地址
    stmdb   sp!,    { r0-r12,lr }   ; 保存使用到的寄存器
                                    ; 注意，此时的sp是中断模式的sp
                                    ; 初始值是上面设置的3072
    
    ldr lr, =int_return             ; 设置调用ISR即EINT_Handle函数后的返回地址  
    ldr pc, =EINT_Handle            ; 调用中断服务函数，在interrupt.c中
int_return
    ldmia   sp!,    { r0-r12,pc }^  ; 中断返回, ^表示将spsr的值复制到cpsr


BaseOfROM  DCD  |Image$$ER_ROM1$$RO$$Base| 
TopOfROM   DCD  |Image$$ER_ROM1$$RO$$Limit| 
BaseOfBSS  DCD  |Image$$RW_RAM1$$RW$$Base| 
BaseOfZero DCD  |Image$$RW_RAM1$$ZI$$Base| 
EndOfBSS   DCD  |Image$$RW_RAM1$$ZI$$Limit| 


data_abort
	
	ldr sp, =0x31000000
	mrs		r14, spsr
	MSR		cPSR_cxsf, R14
	b .

	end
