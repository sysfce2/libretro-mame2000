@
@ NEC V20/V30/V33 Emulator v0.002 - Assembler Output
@
@ Copyright (c) 2009 OopsWare, All rights reserved.
@ this is free for non-commercial use.
@

	.global ArmV30Irq
	.global ArmV30Run
	.global ArmV30CryptTable

ArmV30Irq:
	stmfd sp!,{r4-r12,lr}
	mov r7, r0			@ r7 = Pointer to Cpu Context
	mov r10, r1			@ r10 = Irq vector
	ldr r6, =JumpTables	@ r6 = Opcode Jump table
	ldrh r1, [r7, #0x1A]	@ load NEC flag part
	ldr r9, [r7, #0x20]		@ load ARM flag part
	orr r1, r1, r9
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x1A]
	bic r1, r1, #0x0300			@ clear IF and TF
	strh r1, [r7, #0x1A]
	mov r10, r10, lsl#2
	ldrh r1, [r7, #0x12]	@ load PS then PUSH
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x18]	@ load IP then PUSH
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	mov r0, r10				@ load int verctor ip
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x18]	@ IP
	mov r11, r0
	add r0, r10, #2			@ load int verctor ps
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x12]	@ PS
	mov r1, r11
	ldr r2, [r7, #0x2C]	@ membase
	add r2, r2, r0, lsl#4
	add r4, r2, r1
	str r4, [r7, #0x28]	@ pc
	ldmfd sp!,{r4-r12,pc}

ArmV30Run:
	stmfd sp!,{r4-r12,lr}
	mov r7, r0			@ r7 = Pointer to Cpu Context
	ldr r6, =JumpTables	@ r6 = Opcode Jump table
	ldr r5, [r7,#0x24]	@ r5 = Cycles
	ldr r4, [r7,#0x28]	@ r4 = Current PC + Memory Base
	ldr r9, [r7,#0x20]	@ r9 = flags  ___ANZCV
	mov r8, #0
	ldrb r2, [r4], #1
	ldr pc, [r6, r2, lsl#2]


ArmNecEnd:
	sub r4, r4, #1
ArmNecEndNoBack:
	str r5, [r7,#0x24]	@ Save Cycles
	str r4, [r7,#0x28]	@ Save Current PC + Memory Base
	ldrh r2, [r7,#0x12]	@ PS
	ldr r3, [r7,#0x2C]	@ Memory Base
	sub r4, r4, r2, lsl#4
	sub r4, r4, r3
	strh r4, [r7,#0x18]	@ Save ip
	str r9, [r7,#0x20]
	mov r0, r5			@ return cycles remain
	ldmfd sp!,{r4-r12,pc}

.ltorg

@--- BITOP branchs -----------------------------------

getEAByte:
	ldrb r2, [r4], #1
	add r3, r6, #0x400
	ldr pc, [r3, r2, lsl#2]

getEAWord:
	ldrb r2, [r4], #1
	add r3, r6, #0x800
	ldr pc, [r3, r2, lsl#2]

eab_00:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_01:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_02:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_03:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_04:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_05:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_06:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_07:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_08:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_09:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_0f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_10:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_11:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_12:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_13:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_14:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_15:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_16:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_17:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_18:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_19:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_1f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_20:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_21:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_22:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_23:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_24:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_25:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_26:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_27:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_28:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_29:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_2f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_30:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_31:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_32:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_33:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_34:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_35:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_36:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_37:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_38:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_39:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_3f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_40:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_41:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_42:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_43:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_44:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_45:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_46:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_47:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_48:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_49:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_4f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_50:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_51:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_52:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_53:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_54:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_55:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_56:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_57:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_58:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_59:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_5f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_60:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_61:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_62:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_63:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_64:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_65:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_66:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_67:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_68:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_69:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_6f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_70:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_71:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_72:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_73:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_74:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_75:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_76:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_77:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_78:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_79:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_7f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_80:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_81:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_82:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_83:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_84:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_85:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_86:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_87:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x00			@ AL
	mov pc, r11

eab_88:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_89:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_8f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x02			@ CL
	mov pc, r11

eab_90:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_91:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_92:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_93:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_94:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_95:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_96:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_97:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x04			@ DL
	mov pc, r11

eab_98:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_99:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_9f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x06			@ BL
	mov pc, r11

eab_a0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x01			@ AH
	mov pc, r11

eab_a8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_a9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_aa:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_ab:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_ac:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_ad:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_ae:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_af:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x03			@ CH
	mov pc, r11

eab_b0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x05			@ DH
	mov pc, r11

eab_b8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_b9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_ba:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_bb:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_bc:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_bd:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_be:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_bf:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r10, #0x07			@ BH
	mov pc, r11

eab_c0:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c1:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c2:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c3:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c4:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c5:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c6:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c7:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x00			@ AL
	add pc, r11, #4

eab_c8:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_c9:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_ca:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_cb:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_cc:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_cd:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_ce:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_cf:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x02			@ CL
	add pc, r11, #4

eab_d0:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d1:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d2:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d3:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d4:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d5:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d6:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d7:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x04			@ DL
	add pc, r11, #4

eab_d8:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_d9:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_da:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_db:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_dc:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_dd:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_de:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_df:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x06			@ BL
	add pc, r11, #4

eab_e0:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e1:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e2:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e3:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e4:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e5:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e6:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e7:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x01			@ AH
	add pc, r11, #4

eab_e8:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_e9:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_ea:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_eb:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_ec:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_ed:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_ee:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_ef:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x03			@ CH
	add pc, r11, #4

eab_f0:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f1:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f2:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f3:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f4:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f5:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f6:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f7:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x05			@ DH
	add pc, r11, #4

eab_f8:
	ldrb r0, [r7, #0x00]	@ AL
	mov r8, #0x00
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_f9:
	ldrb r0, [r7, #0x02]	@ CL
	mov r8, #0x02
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_fa:
	ldrb r0, [r7, #0x04]	@ DL
	mov r8, #0x04
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_fb:
	ldrb r0, [r7, #0x06]	@ BL
	mov r8, #0x06
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_fc:
	ldrb r0, [r7, #0x01]	@ AH
	mov r8, #0x01
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_fd:
	ldrb r0, [r7, #0x03]	@ CH
	mov r8, #0x03
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_fe:
	ldrb r0, [r7, #0x05]	@ DH
	mov r8, #0x05
	mov r10, #0x07			@ BH
	add pc, r11, #4

eab_ff:
	ldrb r0, [r7, #0x07]	@ BH
	mov r8, #0x07
	mov r10, #0x07			@ BH
	add pc, r11, #4

eaw_00:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_01:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_02:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_03:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_04:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_05:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_06:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_07:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_08:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_09:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_0f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_10:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_11:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_12:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_13:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_14:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_15:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_16:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_17:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_18:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_19:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_1f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_20:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_21:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_22:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_23:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_24:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_25:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_26:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_27:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_28:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_29:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_2f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_30:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_31:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_32:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_33:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_34:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_35:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_36:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_37:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_38:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_39:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_3f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_40:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_41:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_42:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_43:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_44:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_45:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_46:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_47:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_48:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_49:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_4f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_50:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_51:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_52:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_53:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_54:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_55:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_56:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_57:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_58:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_59:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_5f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_60:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_61:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_62:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_63:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_64:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_65:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_66:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_67:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_68:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_69:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_6f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_70:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_71:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_72:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_73:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_74:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_75:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_76:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_77:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_78:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_79:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_7f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_80:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_81:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_82:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_83:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_84:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_85:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_86:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_87:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x00			@ AW
	mov pc, r11

eaw_88:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_89:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_8f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x02			@ CW
	mov pc, r11

eaw_90:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_91:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_92:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_93:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_94:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_95:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_96:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_97:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x04			@ DW
	mov pc, r11

eaw_98:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_99:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_9f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x06			@ BW
	mov pc, r11

eaw_a0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x08			@ SP
	mov pc, r11

eaw_a8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_a9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_aa:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_ab:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_ac:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_ad:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_ae:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_af:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0a			@ BP
	mov pc, r11

eaw_b0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0c			@ IX
	mov pc, r11

eaw_b8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_b9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_ba:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_bb:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_bc:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_bd:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_be:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_bf:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	mov r10, #0x0e			@ IY
	mov pc, r11

eaw_c0:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c1:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c2:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c3:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c4:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c5:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c6:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c7:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x00			@ AW
	add pc, r11, #4

eaw_c8:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_c9:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_ca:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_cb:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_cc:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_cd:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_ce:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_cf:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x02			@ CW
	add pc, r11, #4

eaw_d0:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d1:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d2:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d3:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d4:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d5:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d6:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d7:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x04			@ DW
	add pc, r11, #4

eaw_d8:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_d9:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_da:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_db:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_dc:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_dd:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_de:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_df:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x06			@ BW
	add pc, r11, #4

eaw_e0:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e1:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e2:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e3:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e4:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e5:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e6:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e7:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x08			@ SP
	add pc, r11, #4

eaw_e8:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_e9:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_ea:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_eb:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_ec:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_ed:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_ee:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_ef:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x0a			@ BP
	add pc, r11, #4

eaw_f0:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f1:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f2:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f3:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f4:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f5:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f6:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f7:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x0c			@ IX
	add pc, r11, #4

eaw_f8:
	ldrh r0, [r7, #0x00]	@ AW
	mov r8, #0x00
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_f9:
	ldrh r0, [r7, #0x02]	@ CW
	mov r8, #0x02
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_fa:
	ldrh r0, [r7, #0x04]	@ DW
	mov r8, #0x04
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_fb:
	ldrh r0, [r7, #0x06]	@ BW
	mov r8, #0x06
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_fc:
	ldrh r0, [r7, #0x08]	@ SP
	mov r8, #0x08
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_fd:
	ldrh r0, [r7, #0x0a]	@ BP
	mov r8, #0x0a
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_fe:
	ldrh r0, [r7, #0x0c]	@ IX
	mov r8, #0x0c
	mov r10, #0x0e			@ IY
	add pc, r11, #4

eaw_ff:
	ldrh r0, [r7, #0x0e]	@ IY
	mov r8, #0x0e
	mov r10, #0x0e			@ IY
	add pc, r11, #4

@--- DIV branchs -------------------------------------

nec_div:
	mov	r10,r0
	mov	r11,r1
	mov	r4,#0
	eor	r2,r0,r1
	mov	r3,#1
	mov	r4,#0
	cmp	r1,#0
	rsbmi r1,r1,#0
	beq	div_by_0
	cmp	r0,#0
	rsbmi r0,r0,#0
	cmp	r0,r1
	blo	div_got_result
div_loop1:
	cmp	r1,#0x10000000
	cmplo r1,r0
	movlo r1,r1,lsl#4
	movlo r3,r3,lsl#4
	blo	div_loop1
div_bignum:
	cmp	r1,#0x80000000
	cmplo r1,r0
	movlo r1,r1,lsl#1
	movlo r3,r3,lsl#1
	blo	div_bignum
div_loop3:
	cmp	r0,r1
	subhs r0,r0,r1
	orrhs r4,r4,r3
	cmp	r0,r1,lsr#1
	subhs r0,r0,r1,lsr#1
	orrhs r4,r4,r3,lsr#1
	cmp	r0,r1,lsr#2
	subhs r0,r0,r1,lsr#2
	orrhs r4,r4,r3,lsr#2
	cmp	r0,r1,lsr#3
	subhs r0,r0,r1,lsr#3
	orrhs r4,r4,r3,lsr#3
	cmp	r0,#0
	movnes r3,r3,lsr#4
	movne r1,r1,lsr#4
	bne	div_loop3
	cmp	r2,#0
	rsbmi r4,r4,#0
div_got_result:
	mov r0,r4
	mul r1,r11,r4
	sub r1,r10,r1
div_by_0:
	ldmfd sp!,{r4,pc}

nec_udiv:
	mov	r10,r0
	mov	r11,r1
	cmp	r1,#0
	beq	udiv_by_0
	mov	r3,#1
	mov	r4,#0
	cmp	r0,r1
	blo	udiv_got_result
udiv_loop1:
	cmp	r1,#0x10000000
	cmplo r1,r0
	movlo r1,r1,lsl#4
	movlo r3,r3,lsl#4
	blo	udiv_loop1
udiv_bignum:
	cmp	r1,#0x80000000
	cmplo r1,r0
	movlo r1,r1,lsl#1
	movlo r3,r3,lsl#1
	blo	udiv_bignum
udiv_loop3:
	cmp	r0,r1
	subhs r0,r0,r1
	orrhs r4,r4,r3
	cmp	r0,r1,lsr #1
	subhs r0,r0,r1,lsr#1
	orrhs r4,r4,r3,lsr#1
	cmp	r0,r1,lsr #2
	subhs r0,r0,r1,lsr#2
	orrhs r4,r4,r3,lsr#2
	cmp	r0,r1,lsr #3
	subhs r0,r0,r1,lsr#3
	orrhs r4,r4,r3,lsr#3
	cmp	r0,#0
	movnes r3,r3,lsr#4
	movne r1,r1,lsr#4
	bne	udiv_loop3
udiv_got_result:
	mov r0,r4
	mul r1,r11,r4
	sub r1,r10,r1
udiv_by_0:
	ldmfd sp!,{r4,pc}

@--- Opcode branchs ----------------------------------

OP___3:
	sub r4, r4, #1
OP___2:
	sub r4, r4, #1
OP___1:
OP____:
	sub r4, r4, #1
	mov r0, r4
	mov lr, pc
	ldr pc, [r7, #0x5C]	@ Call UnrecognizedCallback()
	b ArmNecEndNoBack


OP00__:	@ "ADD EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM00
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM00:
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP01__:	@ "ADDW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM01
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM01:
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP02__:	@ "ADD Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM02
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM02:
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP03__:	@ "ADDW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM03
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM03:
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP04__:	@ "ADD AL,#u8"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r7, #0x00]	@ AL

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP05__:	@ "ADDW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r0, r0, r1, lsl#8
	ldrh r1, [r7, #0x00]	@ AW

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP06__:	@ "PUSH DS1"
	ldrh r1, [r7, #0x10]	@ DS1
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP07__:	@ "POP DS1"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x10]	@ DS1

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP08__:	@ "OR EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM08
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM08:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP09__:	@ "ORW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM09
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM09:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0a__:	@ "OR Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0a
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0a:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0b__:	@ "ORW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0b
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0b:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0c__:	@ "OR AL,#u8"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r7, #0x00]	@ AL

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0d__:	@ "ORW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r0, r0, r1, lsl#8
	ldrh r1, [r7, #0x00]	@ AW

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0e__:	@ "PUSH PS"
	ldrh r1, [r7, #0x12]	@ PS
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f__:	@ "PRE 0x0F"
	ldrb r2, [r4], #1
	add r3, r6, #0xc00	@ call EA
	ldr pc, [r3, r2, lsl#2]

OP0f10:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	eor r3, r3, r3	@ nop
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r0, r0, lsr r1
	tst r0, #1
	mrs r3, cpsr	@ NZCV
	mov r9, r3, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f11:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	eor r3, r3, r3	@ nop
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r0, r0, lsr r1
	tst r0, #1
	mrs r3, cpsr	@ NZCV
	mov r9, r3, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f12:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f12
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	bic r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f12:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	bic r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f13:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f13
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	bic r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f13:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	bic r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f14:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f14
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	orr r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f14:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	orr r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f15:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f15
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	orr r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f15:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	orr r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f16:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f16
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	eor r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f16:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0x7
	mov r2, #1
	eor r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f17:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f17
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	eor r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f17:
	ldrb r1, [r7, #0x02]
	and r1, r1, #0xf
	mov r2, #1
	eor r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f18:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	eor r3, r3, r3	@ nop
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r0, r0, lsr r1
	tst r0, #1
	mrs r3, cpsr	@ NZCV
	mov r9, r3, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f19:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	eor r3, r3, r3	@ nop
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r0, r0, lsr r1
	tst r0, #1
	mrs r3, cpsr	@ NZCV
	mov r9, r3, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1a:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1a
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	bic r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #6
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1a:
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	bic r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #6
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1b:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1b
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	bic r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #6
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1b:
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	bic r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #6
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1c:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1c
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	orr r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1c:
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	orr r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1d:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1d
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	orr r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1d:
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	orr r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1e:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1e
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	eor r1, r0, r2, lsl r1
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1e:
	ldrb r1, [r4], #1
	and r1, r1, #0x7
	mov r2, #1
	eor r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f1f:
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f1f
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	eor r1, r0, r2, lsl r1
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f1f:
	ldrb r1, [r4], #1
	and r1, r1, #0xf
	mov r2, #1
	eor r1, r0, r2, lsl r1
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #5
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f20:
	ldrb r0, [r7, #0x02]
	add r0, r0, #1
	mov r8, r0, lsr#1		@ r8: count
	bic r9, r9, #6			@ Clear ZF and CF
	cmp r8, r0
	beq add4s_end
	ldrh r0, [r7, #0x0e]
	ldrh r1, [r7, #0x10]
	add r10, r0, r1, lsl#4	@ r10: DS1:IY
	ldrh r0, [r7, #0x0c]
	ldrh r1, [r7, #0x16]
	add r11, r0, r1, lsl#4	@ r11: DS0:IX
	stmfd sp!,{r4}
add4s_loop:
	mov r0, r10
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r4, r0
	mov r0, r11
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	sub r2, r6, #0x100		@ HexToDec table
	ldrb r1, [r2, r0]		@ tmp2 convert to decimal value
	ldrb r0, [r2, r4]		@ tmp convert to decimal value
	tst r9, #2
	addne r1, r1, #1		@ add CF
	adds r0, r0, r1
	orreq r9, r9, #4		@ set ZF
	bicne r9, r9, #4		@ clear ZF
	cmp r0, #99
	orrgt r9, r9, #2		@ set CF
	bicle r9, r9, #2		@ clear CF
	sub r2, r6, #0x400		@ DecToHexEx table
	ldrb r1, [r2, r0]		@ tmp2 convert to decimal value
	mov r0, r10
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]
	add r10, r10, #1
	add r11, r11, #1
	sub r5, r5, #18			@ dec cycles
	subs r8, r8, #1
	bgt add4s_loop
	ldmfd sp!,{r4}
add4s_end:

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f22:
	ldrb r0, [r7, #0x02]
	add r0, r0, #1
	mov r8, r0, lsr#1		@ r8: count
	bic r9, r9, #6			@ Clear ZF and CF
	cmp r8, r0
	beq sub4s_end
	ldrh r0, [r7, #0x0e]
	ldrh r1, [r7, #0x10]
	add r10, r0, r1, lsl#4	@ r10: DS1:IY
	ldrh r0, [r7, #0x0c]
	ldrh r1, [r7, #0x16]
	add r11, r0, r1, lsl#4	@ r11: DS0:IX
	stmfd sp!,{r4}
sub4s_loop:
	mov r0, r10
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r4, r0
	mov r0, r11
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	sub r2, r6, #0x100		@ HexToDec table
	ldrb r1, [r2, r0]		@ tmp2 convert to decimal value
	ldrb r0, [r2, r4]		@ tmp convert to decimal value
	tst r9, #2
	addne r1, r1, #1		@ add CF
	cmp r0, r1
	addlt r0, r0, #100
	orrlt r9, r9, #2		@ set CF
	bicge r9, r9, #2		@ clear CF
	subs r0, r0, r1
	orreq r9, r9, #4		@ set ZF
	bicne r9, r9, #4		@ clear ZF
	and r0, r0, #0xff
	sub r2, r6, #0x200		@ DecToHex table
	ldrb r1, [r2, r0]		@ tmp2 convert to decimal value
	mov r0, r10
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]
	add r10, r10, #1
	add r11, r11, #1
	sub r5, r5, #18			@ dec cycles
	subs r8, r8, #1
	bgt sub4s_loop
	ldmfd sp!,{r4}
sub4s_end:

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f26:
	ldrb r0, [r7, #0x02]
	add r0, r0, #1
	mov r8, r0, lsr#1		@ r8: count
	bic r9, r9, #6			@ Clear ZF and CF
	cmp r8, r0
	beq cmp4s_end
	ldrh r0, [r7, #0x0e]
	ldrh r1, [r7, #0x10]
	add r10, r0, r1, lsl#4	@ r10: DS1:IY
	ldrh r0, [r7, #0x0c]
	ldrh r1, [r7, #0x16]
	add r11, r0, r1, lsl#4	@ r11: DS0:IX
	stmfd sp!,{r4}
cmp4s_loop:
	mov r0, r10
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	mov r4, r0
	mov r0, r11
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]
	sub r2, r6, #0x100		@ HexToDec table
	ldrb r1, [r2, r0]		@ tmp2 convert to decimal value
	ldrb r0, [r2, r4]		@ tmp convert to decimal value
	tst r9, #2
	addne r1, r1, #1		@ add CF
	cmp r0, r1
	addlt r0, r0, #100
	orrlt r9, r9, #2		@ set CF
	bicge r9, r9, #2		@ clear CF
	subs r0, r0, r1
	orreq r9, r9, #4		@ set ZF
	bicne r9, r9, #4		@ clear ZF
	add r10, r10, #1
	add r11, r11, #1
	sub r5, r5, #14			@ dec cycles
	subs r8, r8, #1
	bgt cmp4s_loop
	ldmfd sp!,{r4}
cmp4s_end:

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f28:
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM0f28
	mov r0, r0, lsl#4
	ldrb r1, [r7, #0x00]
	mov r1, r1, ror#4
	orr r0, r0, r1, lsr#28
	mov r2, r0, lsr#8
	orr r1, r2, r1, lsl#4
	strb r1, [r7, #0x00]
	strb r0, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM0f28:
	mov r0, r0, lsl#4
	ldrb r1, [r7, #0x00]
	mov r1, r1, ror#4
	orr r0, r0, r1, lsr#28
	mov r2, r0, lsr#8
	orr r1, r2, r1, lsl#4
	strb r1, [r7, #0x00]
	mov r1, r0
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #28
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP0f92:

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP10__:	@ "ADC EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM10
	ldrb r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM10:
	ldrb r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP11__:	@ "ADCW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM11
	ldrh r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM11:
	ldrh r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP12__:	@ "ADC Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM12
	ldrb r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM12:
	ldrb r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP13__:	@ "ADCW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM13
	ldrh r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM13:
	ldrh r1, [r7, r10]
	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP14__:	@ "ADC AL,#u8"
	mov r8, #0
	ldrb r0, [r7, #0x00]	@ AL
	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP15__:	@ "ADCW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r1, r0, r1, lsl#8
	ldrh r0, [r7, #0x00]	@ AW

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP16__:	@ "PUSH SS"
	ldrh r1, [r7, #0x14]	@ SS
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP17__:	@ "POP SS"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x14]	@ SS

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP18__:	@ "SBB EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM18
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM18:
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP19__:	@ "SBBW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM19
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM19:
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1a__:	@ "SBB Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM1a
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM1a:
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1b__:	@ "SBBW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM1b
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM1b:
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1c__:	@ "SBB AL,#u8"
	mov r8, #0
	ldrb r1, [r4], #1
	ldrb r0, [r7, #0x00]	@ AL

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1d__:	@ "SBBW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r1, r0, r1, lsl#8
	ldrh r0, [r7, #0x00]	@ AW

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1e__:	@ "PUSH DS0"
	ldrh r1, [r7, #0x16]	@ DS0
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP1f__:	@ "POP DS0"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x16]	@ DS0

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP20__:	@ "AND EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM20
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM20:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP21__:	@ "ANDW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM21
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM21:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP22__:	@ "AND Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM22
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM22:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP23__:	@ "ANDW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM23
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM23:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP24__:	@ "AND AL,#u8"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r7, #0x00]	@ AL

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP25__:	@ "ANDW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r0, r0, r1, lsl#8
	ldrh r1, [r7, #0x00]	@ AW

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP26__:	@ "ES	prefix(DS1)"
	ldrh r8, [r7, #0x10]		@ DS1
	orr r8, r8, #0x80000000
	ldrb r3, [r4], #1
	sub r5, r5, #2
	ldr pc, [r6, r3, asl#2]

OP27__:	@ "ADJ4 +6"
	ldrb r0, [r7, #0x00]
	and r3, r9, #0x10			@ AF
	and r2, r0, #0xf
	cmp r2, #9
	orrgt r3, r3, #1
	cmp r3, #0
	addne r0, r0, #6			@ + param1
	orrne r9, r9, #0x10			@ set AF
	and r3, r0, #0x100			@ check CF
	orrne r9, r9, r3, lsr#7		@ set CF
	and r3, r9, #0x02			@ CF
	and r0, r0, #0xff
	cmp r0, #0x9f
	orrgt r3, r3, #1
	cmp r3, #0
	addne r0, r0, #0x60			@ + param2
	orrne r9, r9, #0x02			@ set CF
	and r9, r9, #0x12			@ keep AF and CF
	ands r0, r0, #0xff
	orreq r9, r9, #0x04			@ set ZF
	orrs r9, r9, r0, lsl#24		@ set P Value
	orrmi r9, r9, #0x08			@ set SF
	strb r0, [r7, #0x00]

	ldrb r3, [r4], #1
	subs r5, r5, #3
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP28__:	@ "SUB EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM28
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM28:
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP29__:	@ "SUBW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM29
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM29:
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP2a__:	@ "SUB Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM2a
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM2a:
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP2b__:	@ "SUBW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM2b
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM2b:
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP2c__:	@ "SUB AL,#u8"
	mov r8, #0
	ldrb r1, [r4], #1
	ldrb r0, [r7, #0x00]	@ AL

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP2d__:	@ "SUBW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r1, r0, r1, lsl#8
	ldrh r0, [r7, #0x00]	@ AW

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP2e__:	@ "CS prefix(PS)"
	ldrh r8, [r7, #0x12]		@ PS
	orr r8, r8, #0x80000000
	ldrb r3, [r4], #1
	sub r5, r5, #2
	ldr pc, [r6, r3, asl#2]

OP2f__:	@ "ADJ4 -6"
	ldrb r0, [r7, #0x00]
	and r3, r9, #0x10			@ AF
	and r2, r0, #0xf
	cmp r2, #9
	orrgt r3, r3, #1
	cmp r3, #0
	subne r0, r0, #6			@ - param1
	orrne r9, r9, #0x10			@ set AF
	and r3, r0, #0x100			@ check CF
	orrne r9, r9, r3, lsr#7		@ set CF
	and r3, r9, #0x02			@ CF
	and r0, r0, #0xff
	cmp r0, #0x9f
	orrgt r3, r3, #1
	cmp r3, #0
	subne r0, r0, #0x60			@ - param2
	orrne r9, r9, #0x02			@ set CF
	and r9, r9, #0x12			@ keep AF and CF
	ands r0, r0, #0xff
	orreq r9, r9, #0x04			@ set ZF
	orrs r9, r9, r0, lsl#24		@ set P Value
	orrmi r9, r9, #0x08			@ set SF
	strb r0, [r7, #0x00]

	ldrb r3, [r4], #1
	subs r5, r5, #3
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP30__:	@ "XOR EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM30
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#24
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM30:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP31__:	@ "XORW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM31
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#16
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM31:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP32__:	@ "XOR Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM32
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM32:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#24
	strb r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP33__:	@ "XORW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM33
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM33:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#16
	strh r1, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP34__:	@ "XOR AL,#u8"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r7, #0x00]	@ AL

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP35__:	@ "XORW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r0, r0, r1, lsl#8
	ldrh r1, [r7, #0x00]	@ AW

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF
	mov r1, r0, lsr#16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP36__:	@ "SS prefix(SS)"
	ldrh r8, [r7, #0x14]		@ SS
	orr r8, r8, #0x80000000
	ldrb r3, [r4], #1
	sub r5, r5, #2
	ldr pc, [r6, r3, asl#2]

OP37__:	@ "ADJB +6"
	ldrb r0, [r7, #0x00]
	tst r9, #0x10				@ AF
	bne jRM37
	and r3, r0, #0xf
	cmp r3, #9
	bgt jRM37
	bic r9, r9, #0x12			@ Clean AF and CF
	strb r3, [r7, #0x00]		@ r3 = r0 & 0xf

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM37:
	ldrb r1, [r7, #0x01]
	cmp r0, #0xf9
	addgt r1, r1, #2
	addle r1, r1, #1
	strb r1, [r7, #0x01]
	add r0, r0, #6
	and r0, r0, #0xf
	strb r0, [r7, #0x00]
	orr r9, r9, #0x12			@ Set AF and CF

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP38__:	@ "CMP EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM38
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM38:
	ldrb r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP39__:	@ "CMPW EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM39
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM39:
	ldrh r1, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP3a__:	@ "CMP Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM3a
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM3a:
	mov r1, r0
	ldrb r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP3b__:	@ "CMPW Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM3b
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM3b:
	mov r1, r0
	ldrh r0, [r7, r10]
	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP3c__:	@ "CMP AL,#u8"
	mov r8, #0
	ldrb r1, [r4], #1
	ldrb r0, [r7, #0x00]	@ AL

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP3d__:	@ "CMPW AW,#u16"
	mov r8, #0
	ldrb r0, [r4], #1
	ldrb r1, [r4], #1
	orr r1, r0, r1, lsl#8
	ldrh r0, [r7, #0x00]	@ AW

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP3e__:	@ "DS prefix(DS0)"
	ldrh r8, [r7, #0x16]		@ DS0
	orr r8, r8, #0x80000000
	ldrb r3, [r4], #1
	sub r5, r5, #2
	ldr pc, [r6, r3, asl#2]

OP3f__:	@ "ADJB -6"
	ldrb r0, [r7, #0x00]
	tst r9, #0x10				@ AF
	bne jRM3f
	and r3, r0, #0xf
	cmp r3, #9
	bgt jRM3f
	bic r9, r9, #0x12			@ Clean AF and CF
	strb r3, [r7, #0x00]		@ r3 = r0 & 0xf

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM3f:
	ldrb r1, [r7, #0x01]
	cmp r0, #6
	sublt r1, r1, #2
	subge r1, r1, #1
	strb r1, [r7, #0x01]
	sub r0, r0, #6
	and r0, r0, #0xf
	strb r0, [r7, #0x00]
	orr r9, r9, #0x12			@ Set AF and CF

	ldrb r3, [r4], #1
	subs r5, r5, #7
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP40__:	@ "INC AW"
	ldrh r0, [r7, #0x00]	@ AW
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP41__:	@ "INC CW"
	ldrh r0, [r7, #0x02]	@ CW
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP42__:	@ "INC DW"
	ldrh r0, [r7, #0x04]	@ DW
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP43__:	@ "INC BW"
	ldrh r0, [r7, #0x06]	@ BW
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP44__:	@ "INC SP"
	ldrh r0, [r7, #0x08]	@ SP
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP45__:	@ "INC BP"
	ldrh r0, [r7, #0x0a]	@ BP
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP46__:	@ "INC IX"
	ldrh r0, [r7, #0x0c]	@ IX
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP47__:	@ "INC IY"
	ldrh r0, [r7, #0x0e]	@ IY
	mov r1, r0, lsl #16
	adds r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP48__:	@ "DEC AW"
	ldrh r0, [r7, #0x00]	@ AW
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP49__:	@ "DEC CW"
	ldrh r0, [r7, #0x02]	@ CW
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4a__:	@ "DEC DW"
	ldrh r0, [r7, #0x04]	@ DW
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4b__:	@ "DEC BW"
	ldrh r0, [r7, #0x06]	@ BW
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4c__:	@ "DEC SP"
	ldrh r0, [r7, #0x08]	@ SP
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4d__:	@ "DEC BP"
	ldrh r0, [r7, #0x0a]	@ BP
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4e__:	@ "DEC IX"
	ldrh r0, [r7, #0x0c]	@ IX
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP4f__:	@ "DEC IY"
	ldrh r0, [r7, #0x0e]	@ IY
	mov r1, r0, lsl #16
	subs r1, r1, #0x10000
	mrs r2, cpsr
	mov r9, r1, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r0, r1, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3
	mov r1, r1, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP50__:	@ "PUSH AW"
	ldrh r1, [r7, #0x00]	;@ AW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP51__:	@ "PUSH CW"
	ldrh r1, [r7, #0x02]	;@ CW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP52__:	@ "PUSH DW"
	ldrh r1, [r7, #0x04]	;@ DW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP53__:	@ "PUSH BW"
	ldrh r1, [r7, #0x06]	;@ BW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP54__:	@ "PUSH SP"
	ldrh r1, [r7, #0x08]	;@ SP
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP55__:	@ "PUSH BP"
	ldrh r1, [r7, #0x0a]	;@ BP
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP56__:	@ "PUSH IX"
	ldrh r1, [r7, #0x0c]	;@ IX
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP57__:	@ "PUSH IY"
	ldrh r1, [r7, #0x0e]	;@ IY
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP58__:	@ "POP AW"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x00]	;@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP59__:	@ "POP CW"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x02]	;@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5a__:	@ "POP DW"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x04]	;@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5b__:	@ "POP BW"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x06]	;@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5c__:	@ "POP SP"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x08]	;@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5d__:	@ "POP BP"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0a]	;@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5e__:	@ "POP IX"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0c]	;@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP5f__:	@ "POP IY"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0e]	;@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #8
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP60__:	@ "PUSH ALL"
	ldrh r11, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x00]	@ AW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x02]	@ CW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x04]	@ DW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x06]	@ BW
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	mov r1, r11				@ SP
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x0a]	@ BP
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x0c]	@ IX
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]
	ldrh r1, [r7, #0x0e]	@ IY
	@ PUSH r1
	ldrh r0, [r7, #0x08]	@ SP
	sub r0, r0, #2
	strh r0, [r7, #0x08]	@ SP
	mov r0, r0, lsl#16
	mov r0, r0, lsr#16
	ldrh r2, [r7, #0x14]	@ SS
	add r0, r0, r2, lsl#4
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneh r1, [r2, r0]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #35
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP61__:	@ "POP ALL"
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0e]	@ IY
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0c]	@ IX
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x0a]	@ BP
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x06]	@ BW
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x04]	@ DW
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x02]	@ CW
	@ POP r0
	ldrh r0, [r7, #0x08]	@ SP
	add r1, r0, #2
	strh r1, [r7, #0x08]	@ SP
	ldrh r1, [r7, #0x14]	@ SS
	add r0, r0, r1, lsl#4
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneh r0, [r2, r0]
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]
	strh r0, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #43
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP6b__:	@ "MUL Rw,EA,#s8"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM6b
	mov r0, r0, lsl#16
	mov r0, r0, asr#16
	ldrsb r1, [r4], #1
	mul r2, r0, r1
	mov r3, r2, asr#15
	mov r9, #0x3		@ CF OF
	cmp r3, #0
	moveq r9, #0
	cmp r3, #-1
	moveq r9, #0
	strh r2, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #31
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM6b:
	mov r0, r0, lsl#16
	mov r0, r0, asr#16
	ldrsb r1, [r4], #1
	mul r2, r0, r1
	mov r3, r2, asr#15
	mov r9, #0x3		@ CF OF
	cmp r3, #0
	moveq r9, #0
	cmp r3, #-1
	moveq r9, #0
	strh r2, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #39
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP70__:	@ "JO + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x1	;@ V flag
	subne r5, r5, #10
	addne r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP71__:	@ "JNO + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x1	;@ V flag
	subeq r5, r5, #10
	addeq r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP72__:	@ "JC + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x2	;@ C flag
	subne r5, r5, #10
	addne r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP73__:	@ "JNC + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x2	;@ C flag
	subeq r5, r5, #10
	addeq r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP74__:	@ "JZ + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x4	;@ Z flag
	subne r5, r5, #10
	addne r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP75__:	@ "JNZ + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x4	;@ Z flag
	subeq r5, r5, #10
	addeq r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP76__:	@ "JCE + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x6	;@ C Z flag
	subne r5, r5, #10
	addne r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP77__:	@ "JNCE + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x6	;@ C Z flag
	subeq r5, r5, #10
	addeq r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP78__:	@ "JS + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x8	;@ N flag
	subne r5, r5, #10
	addne r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP79__:	@ "JNS + #s8"
	ldrsb r3, [r4], #1
	tst r9, #0x8	;@ N flag
	subeq r5, r5, #10
	addeq r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP7c__:	@ "JL + #s8"
	ldrsb r3, [r4], #1
	mov r0, r9, lsl#28
	msr cpsr_f, r0
	sublt r5, r5, #10
	addlt r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP7d__:	@ "JNL + #s8"
	ldrsb r3, [r4], #1
	mov r0, r9, lsl#28
	msr cpsr_f, r0
	subge r5, r5, #10
	addge r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP7e__:	@ "JLE + #s8"
	ldrsb r3, [r4], #1
	mov r0, r9, lsl#28
	msr cpsr_f, r0
	suble r5, r5, #10
	addle r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP7f__:	@ "JNLE + #s8"
	ldrsb r3, [r4], #1
	mov r0, r9, lsl#28
	msr cpsr_f, r0
	subgt r5, r5, #10
	addgt r4, r4, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80__:	@ "PRE 0x80"
	ldrb r2, [r4], #1
	add r3, r6, #0x1000	@ call EA
	ldr pc, [r3, r2, lsl#2]

OP8000:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8001:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8002:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8003:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8004:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8005:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8006:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8007:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8008:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8009:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP800f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8010:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8011:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8012:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8013:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8014:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8015:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8016:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8017:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8018:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8019:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP801f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8020:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8021:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8022:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8023:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8024:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8025:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8026:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8027:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8028:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8029:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP802f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8030:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8031:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8032:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8033:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8034:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8035:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8036:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8037:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8038:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8039:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP803f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8040:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8041:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8042:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8043:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8044:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8045:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8046:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8047:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8048:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8049:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP804f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8050:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8051:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8052:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8053:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8054:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8055:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8056:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8057:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8058:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8059:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP805f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8060:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8061:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8062:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8063:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8064:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8065:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8066:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8067:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8068:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8069:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP806f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8070:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8071:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8072:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8073:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8074:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8075:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8076:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8077:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8078:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8079:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP807f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8080:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8081:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8082:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8083:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8084:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8085:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8086:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8087:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8088:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8089:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP808f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8090:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8091:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8092:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8093:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8094:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8095:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8096:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8097:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8098:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8099:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP809f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80a9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80aa:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ab:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ac:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ad:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ae:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80af:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80b9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ba:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80bb:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80bc:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80bd:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80be:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80bf:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	ldrneb r0, [r2, r0]
	moveq lr, pc	@ call "read8"
	ldreq pc, [r7, #0x40]

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c0:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c1:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c2:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c3:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c4:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c5:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c6:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c7:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c8:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80c9:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ca:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80cb:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80cc:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80cd:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ce:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80cf:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	orrs r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d0:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d1:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d2:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d3:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d4:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d5:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d6:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d7:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	adds r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d8:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80d9:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80da:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80db:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80dc:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80dd:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80de:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80df:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x100
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e0:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e1:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e2:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e3:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e4:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e5:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e6:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e7:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e8:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80e9:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ea:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80eb:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ec:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ed:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ee:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ef:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f0:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x00]	@ AL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f1:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x02]	@ CL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f2:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x04]	@ DL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f3:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x06]	@ BL

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f4:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x01]	@ AH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f5:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x03]	@ CH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f6:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x05]	@ DH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f7:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	mov r0, r0, lsl#24
	eors r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #24
	strb r1, [r7, #0x07]	@ BH

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f8:
	ldrb r0, [r7, #0x00]	@ AL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80f9:
	ldrb r0, [r7, #0x02]	@ CL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80fa:
	ldrb r0, [r7, #0x04]	@ DL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80fb:
	ldrb r0, [r7, #0x06]	@ BL

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80fc:
	ldrb r0, [r7, #0x01]	@ AH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80fd:
	ldrb r0, [r7, #0x03]	@ CH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80fe:
	ldrb r0, [r7, #0x05]	@ DH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP80ff:
	ldrb r0, [r7, #0x07]	@ BH

	ldrb r1, [r4], #1

	eor r3, r0, r1
	mov r0, r0, lsl#24
	subs r0, r0, r1, lsl#24
	mrs r2, cpsr			@ NZCV
	orr r9, r0, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#24	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81__:	@ "PRE 0x81"
	ldrb r2, [r4], #1
	add r3, r6, #0x1400	@ call EA
	ldr pc, [r3, r2, lsl#2]

OP8100:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8101:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8102:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8103:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8104:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8105:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8106:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8107:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8108:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8109:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP810f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8110:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8111:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8112:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8113:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8114:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8115:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8116:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8117:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8118:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8119:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP811f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8120:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8121:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8122:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8123:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8124:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8125:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8126:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8127:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8128:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8129:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP812f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8130:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8131:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8132:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8133:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8134:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8135:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8136:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8137:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8138:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8139:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP813f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8140:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8141:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8142:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8143:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8144:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8145:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8146:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8147:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8148:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8149:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP814f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8150:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8151:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8152:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8153:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8154:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8155:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8156:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8157:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8158:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8159:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP815f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8160:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8161:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8162:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8163:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8164:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8165:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8166:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8167:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8168:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8169:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP816f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8170:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8171:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8172:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8173:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8174:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8175:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8176:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8177:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8178:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8179:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP817f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8180:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8181:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8182:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8183:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8184:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8185:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8186:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8187:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8188:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8189:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP818f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8190:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8191:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8192:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8193:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8194:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8195:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8196:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8197:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8198:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8199:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP819f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81a9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81aa:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ab:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ac:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ad:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ae:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81af:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81b9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ba:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81bb:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81bc:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81bd:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81be:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81bf:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81c9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ca:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81cb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81cc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81cd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ce:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81cf:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81d9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81da:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81db:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81dc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81dd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81de:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81df:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81e9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ea:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81eb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ec:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ed:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ee:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ef:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81f9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81fa:
	ldrh r0, [r7, #0x04]	@ DW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81fb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81fc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81fd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81fe:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP81ff:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrb r1, [r4], #1	;@ fetch word
	ldrb r2, [r4], #1
	orr r1, r1, r2, lsl#8

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83__:	@ "PRE 0x83"
	ldrb r2, [r4], #1
	add r3, r6, #0x1800	@ call EA
	ldr pc, [r3, r2, lsl#2]

OP8300:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8301:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8302:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8303:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8304:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8305:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8306:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8307:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8308:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8309:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP830f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8310:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8311:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8312:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8313:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8314:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8315:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8316:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8317:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8318:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8319:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP831f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8320:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8321:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8322:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8323:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8324:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8325:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8326:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8327:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8328:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8329:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP832f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8330:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8331:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8332:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8333:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8334:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8335:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8336:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8337:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8338:
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8339:
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833a:
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833b:
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833c:
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833d:
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833e:
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP833f:
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8340:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8341:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8342:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8343:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8344:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8345:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8346:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8347:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8348:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8349:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP834f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8350:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8351:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8352:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8353:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8354:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8355:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8356:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8357:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8358:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8359:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP835f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8360:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8361:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8362:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8363:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8364:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8365:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8366:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8367:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8368:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8369:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP836f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8370:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8371:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8372:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8373:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8374:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8375:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8376:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8377:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8378:
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8379:
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837a:
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837b:
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837c:
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837d:
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837e:
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP837f:
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8380:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8381:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8382:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8383:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8384:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8385:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8386:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8387:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8388:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8389:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP838f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8390:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8391:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8392:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8393:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8394:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8395:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8396:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8397:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8398:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8399:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839a:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839b:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839c:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839d:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839e:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP839f:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83a9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83aa:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ab:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ac:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ad:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ae:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83af:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b0:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b1:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b2:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b3:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b4:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b5:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b6:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b7:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b8:
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83b9:
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ba:
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83bb:
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83bc:
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83bd:
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83be:
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83bf:
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	mov r0, r8
	ldr r2, [r7, #0x38]		@ ppMemRead
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	ldrneb r0, [r2], #1
	ldrneb r3, [r2]
	orrne r0, r0, r3, lsl#8
	moveq lr, pc	@ call "read16"
	ldreq pc, [r7, #0x44]

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #13
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83c9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ca:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83cb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83cc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83cd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ce:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83cf:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	orrs r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r1, r0
	tst r9, #0x2		@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	adds r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83d9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83da:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83db:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83dc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83dd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83de:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83df:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	tst r9, #0x2			@ check CF
	addne r1, r1, #1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	tst r1, #0x10000
	orrne r9, r9, #0x2
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83e9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ea:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83eb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ec:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ed:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ee:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ef:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f0:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x00]	@ AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f1:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x02]	@ CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f2:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x04]	@ DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f3:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x06]	@ BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f4:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x08]	@ SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f5:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0a]	@ BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f6:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0c]	@ IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f7:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	mov r0, r0, lsl#16
	eors r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	bic r9, r9, #3		@ Clear CF VF

	mov r1, r0, lsr #16
	strh r1, [r7, #0x0e]	@ IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f8:
	ldrh r0, [r7, #0x00]	@ AW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83f9:
	ldrh r0, [r7, #0x02]	@ CW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83fa:
	ldrh r0, [r7, #0x04]	@ DW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83fb:
	ldrh r0, [r7, #0x06]	@ BW

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83fc:
	ldrh r0, [r7, #0x08]	@ SP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83fd:
	ldrh r0, [r7, #0x0a]	@ BP

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83fe:
	ldrh r0, [r7, #0x0c]	@ IX

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP83ff:
	ldrh r0, [r7, #0x0e]	@ IY

	ldrsb r1, [r4], #1	;@ fetch signed byte as word
	mov r1, r1, lsl#16
	mov r1, r1, lsr#16

	eor r3, r0, r1
	mov r0, r0, lsl#16
	subs r0, r0, r1, lsl#16
	mrs r2, cpsr			@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28
	eor r9, r9, #2			@ !CF
	eor r3, r3, r0, lsr#16	@ AF
	and r3, r3, #0x10
	orr r9, r9, r3

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP84__:	@ "TST EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM84
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM84:
	ldrb r1, [r7, r10]
	mov r0, r0, lsl#24
	ands r0, r0, r1, lsl#24
	mrs r2, cpsr		@ NZCV
	orr r9, r0, r2, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #10
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP85__:	@ "TST EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM85
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM85:
	ldrh r1, [r7, r10]
	mov r0, r0, lsl#16
	ands r0, r0, r1, lsl#16
	mrs r2, cpsr		@ NZCV
	mov r9, r0, lsl#8
	orr r9, r9, r2, lsr#28

	ldrb r3, [r4], #1
	subs r5, r5, #10
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP86__:	@ "XCHG EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM86
	ldrb r1, [r7, r10]
	strb r0, [r7, r10]
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #3
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM86:
	ldrb r1, [r7, r10]
	strb r0, [r7, r10]
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #18
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP87__:	@ "XCHG EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM87
	ldrh r1, [r7, r10]
	strh r0, [r7, r10]
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #3
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM87:
	ldrh r1, [r7, r10]
	strh r0, [r7, r10]
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #16
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP88__:	@ "MOV EA,Rl"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM88
	ldrb r1, [r7, r10]
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM88:
	ldrb r1, [r7, r10]
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	strneb r1, [r2, r0]
	moveq lr, pc	@ call "write8"
	ldreq pc, [r7, #0x48]

	ldrb r3, [r4], #1
	subs r5, r5, #9
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP89__:	@ "MOV EA,Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM89
	ldrh r1, [r7, r10]
	strb r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM89:
	ldrh r1, [r7, r10]
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #9
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8a__:	@ "MOV Rl,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x400	@ call getEAByte 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM8a
	strb r0, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM8a:
	strb r0, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8b__:	@ "MOV Rw,EA"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM8b
	strh r0, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM8b:
	strh r0, [r7, r10]

	ldrb r3, [r4], #1
	subs r5, r5, #11
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8c__:	@ "MOV EA,Rs"
	ldrb r2, [r4], #1
	add r3, r6, #0x800	@ call getEAWord 
	mov r11, pc
	ldr pc, [r3, r2, lsl#2]
	b jRM8c
	add r10, r10, #0x10
	ldrh r1, [r7, r10]
	strh r1, [r7, r8]

	ldrb r3, [r4], #1
	subs r5, r5, #2
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

jRM8c:
	add r10, r10, #0x10
	ldrh r1, [r7, r10]
	mov r0, r8
	ldr r2, [r7, #0x3C]		@ ppMemWrite
	mov r3, r0, lsr#11
	ldr r2, [r2, r3, lsl#2]
	cmp r2, #0
	addne r2, r2, r0
	strneb r1, [r2], #1
	movne r1, r1, lsr#8
	strneb r1, [r2]
	moveq lr, pc	@ call "write16"
	ldreq pc, [r7, #0x4C]

	ldrb r3, [r4], #1
	subs r5, r5, #10
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d__:	@ "LEA Rw"
	ldrb r2, [r4], #1
	add r3, r6, #0x1c00	@ call EA
	ldr pc, [r3, r2, lsl#2]

OP8d00:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d01:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d02:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d03:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d04:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d05:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d06:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d07:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d08:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d09:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d0f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d10:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d11:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d12:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d13:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d14:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d15:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d16:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d17:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d18:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d19:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d1f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d20:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d21:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d22:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d23:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d24:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d25:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d26:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d27:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d28:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d29:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d2f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d30:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d31:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d32:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d33:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d34:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d35:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d36:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d37:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d38:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d39:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IX + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = IY + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = FETCH16 + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d3f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = BW + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d40:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d41:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d42:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d43:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d44:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d45:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d46:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d47:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d48:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d49:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d4f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d50:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d51:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d52:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d53:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d54:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d55:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d56:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d57:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x04]	@ store EO into DW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d58:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d59:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d5f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x06]	@ store EO into BW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d60:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d61:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d62:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d63:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d64:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d65:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d66:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d67:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x08]	@ store EO into SP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d68:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d69:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d6f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0a]	@ store EO into BP

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d70:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d71:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d72:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d73:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d74:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d75:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d76:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d77:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0c]	@ store EO into IX

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d78:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IX + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d79:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + IY + FETCH8S) + DefaultBase(DS0)
	ldrh r2, [r7, #0x06]		@ BW
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IX + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0c]		@ IX
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + IY + FETCH8S) + DefaultBase(SS)
	ldrh r2, [r7, #0x0a]		@ BP
	ldrh r10, [r7, #0x0e]		@ IY
	mov r2, r2, lsl#16
	add r10, r2, r10, lsl#16
	ldrsb r2, [r4], #1
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IX + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0c]		@ IX
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (IY + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x0e]		@ IY
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BP + FETCH8S) + DefaultBase(SS)
	ldrh r10, [r7, #0x0a]		@ BP
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d7f:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (BW + FETCH8S) + DefaultBase(DS0)
	ldrh r10, [r7, #0x06]		@ BW
	ldrsb r2, [r4], #1
	mov r10, r10, lsl#16
	add r10, r10, r2, lsl#16
	mov r10, r10, lsr#16
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x0e]	@ store EO into IY

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d80:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d81:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d82:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d83:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d84:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d85:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d86:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d87:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BW) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl #8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x00]	@ store EO into AW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d88:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BW + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d89:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BW + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x06]		@ BW
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8a:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP + IX) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8b:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP + IY) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x30000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8c:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + IX) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0c]		@ IX
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8d:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + IY) + DefaultBase(DS0)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0e]		@ IY
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x16]		@ DS0
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8e:
	mov r8, #0x80000000		@ prefix seg to zero
	@ EA = (FETCH16S + BP) + DefaultBase(SS)
	ldrb r2, [r4], #1
	ldrb r10, [r4], #1
	orr r10, r2, r10, lsl#8
	ldrh r2, [r7, #0x0a]		@ BP
	add r10, r10, r2
	bic r10, r10, #0x10000
	tst r8, #0x80000000
	ldreqh r8, [r7, #0x14]		@ SS
	add r8, r10, r8, lsl#4
	strh r8, [r7, #0x02]	@ store EO into CW

	ldrb r3, [r4], #1
	subs r5, r5, #4
	ldrge pc, [r6, r3, asl#2]
	b ArmNecEnd

OP8d8f:

