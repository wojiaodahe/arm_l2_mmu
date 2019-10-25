;******************************************************************************       
; �쳣�������������У���Reset��HandleIRQ�⣬�����쳣��û��ʹ��
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
    b   .			 		;0x04: δ����ָ����ֹģʽ��������ַ
Handle_swi
    b   .					;0x08: ����ģʽ��������ַ��ͨ��SWIָ������ģʽ
HandlePrefetchAbort
    b   .					; 0x0c: ָ��Ԥȡ��ֹ���µ��쳣��������ַ
HandleDataAbort
    b  	HandleDataAbort		; 0x10: ���ݷ�����ֹ���µ��쳣��������ַ
HandleNotUsed
    b   .					; 0x14: ����
Handle_irq
    b   HandleIRQ			; 0x18: �ж�ģʽ��������ַ
HandleFIQ
    b   .					; 0x1c: ���ж�ģʽ��������ַ

Reset

    msr cpsr_cxsf, #0xd2    ; �����ж�ģʽ
	ldr		r0, =IRQ_MODE_STACK
	mov		sp, r0

	msr     CPSR_cxsf, #(DISABLE_FIQ :OR: DISABLE_IRQ :OR: SVC_MOD)
	ldr		r0, =SVC_MODE_STACK
	mov		sp, r0

	msr     CPSR_cxsf, #(DISABLE_FIQ :OR: DISABLE_IRQ :OR: FIQ_MOD)
	ldr		r0, =FIQ_MODE_STACK
	mov		sp, r0
    
	msr cpsr_cxsf, #0xdf	;ϵͳģʽ
	ldr		r0, =SYS_MODE_STACK
	mov		sp, r0

	mrc    p15, 0, r0, c1, c0, 0    
	bic    r0, r0, #0x0001          ;����MMU
	mcr    p15, 0, r0, c1, c0, 0    ;tq2440 ����ok�Ĵ���ֱ���õ�jz2440�������쳣
                                    ;����: ͨ��jlink��һ�η��������ǿ��Ե�,Ȼ������������ڲ��ϵ��������ٴ�
                                    ;����ͻ�����(���ڽ��ÿ��Ź����������)
                                    ;����ԭ��:jz440 �� tq2440����(�����ǲ�����û���о�)��jtag���ŽӵĲ�ͬ(reset��?) 
                                    ;�ϵ�������p15����������λ,mmu�ǽ���״̬,Ȼ��jz2440�ڲ��ϵ�������������
                                    ;�����Ḵλp15������,����mmu���ǿ���״̬,Ȼ����ʱ�����bss�λ��������ڴ��
                                    ;���п��ܻ����mmuӳ���,�Ӷ����·����ڴ�����쳣
                                    ;!!!!!!����ط�Ҫ��ϸ���,��Ϊmmuӳ�����Ӧ�ó�����bss��,�����쳣��������Ϊӳ������������!!!!!!!
	bl copy_proc_beg

	bl init_system
    
    ldr lr, =halt_loop      ; ���÷��ص�ַ
    ldr pc, =kernel_main           ; ����main����

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
	sub lr, lr, #4                  ; ���㷵�ص�ַ
    stmdb   sp!,    { r0-r12,lr }   ; ����ʹ�õ��ļĴ���
                                    ; ע�⣬��ʱ��sp���ж�ģʽ��sp
                                    ; ��ʼֵ���������õ�3072
    
    ldr lr, =int_return             ; ���õ���ISR��EINT_Handle������ķ��ص�ַ  
    ldr pc, =EINT_Handle            ; �����жϷ���������interrupt.c��
int_return
    ldmia   sp!,    { r0-r12,pc }^  ; �жϷ���, ^��ʾ��spsr��ֵ���Ƶ�cpsr


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