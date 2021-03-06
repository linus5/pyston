/* -----------------------------------------------------------------------
   aix_closure.S - Copyright (c) 2002, 2003, 2009 Free Software Foundation, Inc.
   based on darwin_closure.S

   PowerPC Assembly glue.

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   ``Software''), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be included
   in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND, EXPRESS
   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR
   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   OTHER DEALINGS IN THE SOFTWARE.
   ----------------------------------------------------------------------- */

	.set r0,0
	.set r1,1
	.set r2,2
	.set r3,3
	.set r4,4
	.set r5,5
	.set r6,6
	.set r7,7
	.set r8,8
	.set r9,9
	.set r10,10
	.set r11,11
	.set r12,12
	.set r13,13
	.set r14,14
	.set r15,15
	.set r16,16
	.set r17,17
	.set r18,18
	.set r19,19
	.set r20,20
	.set r21,21
	.set r22,22
	.set r23,23
	.set r24,24
	.set r25,25
	.set r26,26
	.set r27,27
	.set r28,28
	.set r29,29
	.set r30,30
	.set r31,31
	.set f0,0
	.set f1,1
	.set f2,2
	.set f3,3
	.set f4,4
	.set f5,5
	.set f6,6
	.set f7,7
	.set f8,8
	.set f9,9
	.set f10,10
	.set f11,11
	.set f12,12
	.set f13,13
	.set f14,14
	.set f15,15
	.set f16,16
	.set f17,17
	.set f18,18
	.set f19,19
	.set f20,20
	.set f21,21

	.extern .ffi_closure_helper_DARWIN

#define LIBFFI_ASM
#define JUMPTARGET(name) name
#define L(x) x
	.file "aix_closure.S"
	.toc
LC..60:
	.tc L..60[TC],L..60
	.csect .text[PR]
	.align 2

.csect .text[PR]
	.align 2
	.globl ffi_closure_ASM
	.globl .ffi_closure_ASM
.csect ffi_closure_ASM[DS]
ffi_closure_ASM:
#ifdef __64BIT__
	.llong .ffi_closure_ASM, TOC[tc0], 0
	.csect .text[PR]
.ffi_closure_ASM:
/* we want to build up an area for the parameters passed */
/* in registers (both floating point and integer) */

	/* we store gpr 3 to gpr 10 (aligned to 4)
	in the parents outgoing area  */
	std   r3, 48+(0*8)(r1)
	std   r4, 48+(1*8)(r1)
	std   r5, 48+(2*8)(r1)
	std   r6, 48+(3*8)(r1)
	mflr  r0

	std   r7, 48+(4*8)(r1)
	std   r8, 48+(5*8)(r1)
	std   r9, 48+(6*8)(r1)
	std   r10, 48+(7*8)(r1)
	std   r0, 16(r1)	/* save the return address */


	/* 48  Bytes (Linkage Area) */
	/* 64  Bytes (params) */
	/* 16  Bytes (result) */
	/* 104 Bytes (13*8 from FPR) */
	/* 8   Bytes (alignment) */
	/* 240 Bytes */

	stdu  r1, -240(r1)	/* skip over caller save area
				   keep stack aligned to 16  */

	/* next save fpr 1 to fpr 13 (aligned to 8) */
	stfd  f1, 128+(0*8)(r1)
	stfd  f2, 128+(1*8)(r1)
	stfd  f3, 128+(2*8)(r1)
	stfd  f4, 128+(3*8)(r1)
	stfd  f5, 128+(4*8)(r1)
	stfd  f6, 128+(5*8)(r1)
	stfd  f7, 128+(6*8)(r1)
	stfd  f8, 128+(7*8)(r1)
	stfd  f9, 128+(8*8)(r1)
	stfd  f10, 128+(9*8)(r1)
	stfd  f11, 128+(10*8)(r1)
	stfd  f12, 128+(11*8)(r1)
	stfd  f13, 128+(12*8)(r1)

	/* set up registers for the routine that actually does the work */
	/* get the context pointer from the trampoline */
	mr r3, r11

	/* now load up the pointer to the result storage */
	addi r4, r1, 112

	/* now load up the pointer to the saved gpr registers */
	addi r5, r1, 288

	/* now load up the pointer to the saved fpr registers */
	addi r6, r1, 128

	/* make the call */
	bl .ffi_closure_helper_DARWIN
	nop

	/* now r3 contains the return type */
	/* so use it to look up in a table */
	/* so we know how to deal with each type */

	/* look up the proper starting point in table  */
	/* by using return type as offset */
	lhz	r3, 10(r3)	/* load type from return type */
	ld	r4, LC..60(2)	/* get address of jump table */
	sldi	r3, r3, 4	/* now multiply return type by 16 */
	ld	r0, 240+16(r1)	/* load return address */
	add	r3, r3, r4	/* add contents of table to table address */
	mtctr	r3
	bctr			/* jump to it */

/* Each fragment must be exactly 16 bytes long (4 instructions).
   Align to 16 byte boundary for cache and dispatch efficiency.  */
	.align 4

L..60:
/* case FFI_TYPE_VOID */
	mtlr r0
	addi r1, r1, 240
	blr
	nop

/* case FFI_TYPE_INT */
	lwa r3, 112+4(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_FLOAT */
	lfs f1, 112+0(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_DOUBLE */
	lfd f1, 112+0(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_LONGDOUBLE */
	lfd f1, 112+0(r1)
	mtlr r0
	lfd f2, 112+8(r1)
	b L..finish

/* case FFI_TYPE_UINT8 */
	lbz r3, 112+7(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_SINT8 */
	lbz r3, 112+7(r1)
	mtlr r0
	extsb r3, r3
	b L..finish

/* case FFI_TYPE_UINT16 */
	lhz r3, 112+6(r1)
	mtlr r0
L..finish:
	addi r1, r1, 240
	blr

/* case FFI_TYPE_SINT16 */
	lha r3, 112+6(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_UINT32 */
	lwz r3, 112+4(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_SINT32 */
	lwa r3, 112+4(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_UINT64 */
	ld r3, 112+0(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_SINT64 */
	ld r3, 112+0(r1)
	mtlr r0
	addi r1, r1, 240
	blr

/* case FFI_TYPE_STRUCT */
	mtlr r0
	addi r1, r1, 240
	blr
	nop

/* case FFI_TYPE_POINTER */
	ld r3, 112+0(r1)
	mtlr r0
	addi r1, r1, 240
	blr

#else /* ! __64BIT__ */
	
	.long .ffi_closure_ASM, TOC[tc0], 0
	.csect .text[PR]
.ffi_closure_ASM:
/* we want to build up an area for the parameters passed */
/* in registers (both floating point and integer) */

	/* we store gpr 3 to gpr 10 (aligned to 4)
	in the parents outgoing area  */
	stw   r3, 24+(0*4)(r1)
	stw   r4, 24+(1*4)(r1)
	stw   r5, 24+(2*4)(r1)
	stw   r6, 24+(3*4)(r1)
	mflr  r0

	stw   r7, 24+(4*4)(r1)
	stw   r8, 24+(5*4)(r1)
	stw   r9, 24+(6*4)(r1)
	stw   r10, 24+(7*4)(r1)
	stw   r0, 8(r1)

	/* 24 Bytes (Linkage Area) */
	/* 32 Bytes (params) */
	/* 16  Bytes (result) */
	/* 104 Bytes (13*8 from FPR) */
	/* 176 Bytes */

	stwu  r1, -176(r1)	/* skip over caller save area
				   keep stack aligned to 16  */

	/* next save fpr 1 to fpr 13 (aligned to 8) */
	stfd  f1, 72+(0*8)(r1)
	stfd  f2, 72+(1*8)(r1)
	stfd  f3, 72+(2*8)(r1)
	stfd  f4, 72+(3*8)(r1)
	stfd  f5, 72+(4*8)(r1)
	stfd  f6, 72+(5*8)(r1)
	stfd  f7, 72+(6*8)(r1)
	stfd  f8, 72+(7*8)(r1)
	stfd  f9, 72+(8*8)(r1)
	stfd  f10, 72+(9*8)(r1)
	stfd  f11, 72+(10*8)(r1)
	stfd  f12, 72+(11*8)(r1)
	stfd  f13, 72+(12*8)(r1)

	/* set up registers for the routine that actually does the work */
	/* get the context pointer from the trampoline */
	mr r3, r11

	/* now load up the pointer to the result storage */
	addi r4, r1, 56

	/* now load up the pointer to the saved gpr registers */
	addi r5, r1, 200

	/* now load up the pointer to the saved fpr registers */
	addi r6, r1, 72

	/* make the call */
	bl .ffi_closure_helper_DARWIN
	nop

	/* now r3 contains the return type */
	/* so use it to look up in a table */
	/* so we know how to deal with each type */

	/* look up the proper starting point in table  */
	/* by using return type as offset */
	lhz	r3, 6(r3)	/* load type from return type */
	lwz	r4, LC..60(2)	/* get address of jump table */
	slwi	r3, r3, 4	/* now multiply return type by 16 */
	lwz	r0, 176+8(r1)	/* load return address */
	add	r3, r3, r4	/* add contents of table to table address */
	mtctr	r3
	bctr			/* jump to it */

/* Each fragment must be exactly 16 bytes long (4 instructions).
   Align to 16 byte boundary for cache and dispatch efficiency.  */
	.align 4

L..60:
/* case FFI_TYPE_VOID */
	mtlr r0
	addi r1, r1, 176
	blr
	nop

/* case FFI_TYPE_INT */
	lwz r3, 56+0(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_FLOAT */
	lfs f1, 56+0(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_DOUBLE */
	lfd f1, 56+0(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_LONGDOUBLE */
	lfd f1, 56+0(r1)
	mtlr r0
	lfd f2, 56+8(r1)
	b L..finish

/* case FFI_TYPE_UINT8 */
	lbz r3, 56+3(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_SINT8 */
	lbz r3, 56+3(r1)
	mtlr r0
	extsb r3, r3
	b L..finish

/* case FFI_TYPE_UINT16 */
	lhz r3, 56+2(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_SINT16 */
	lha r3, 56+2(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_UINT32 */
	lwz r3, 56+0(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_SINT32 */
	lwz r3, 56+0(r1)
	mtlr r0
	addi r1, r1, 176
	blr

/* case FFI_TYPE_UINT64 */
	lwz r3, 56+0(r1)
	mtlr r0
	lwz r4, 56+4(r1)
	b L..finish

/* case FFI_TYPE_SINT64 */
	lwz r3, 56+0(r1)
	mtlr r0
	lwz r4, 56+4(r1)
	b L..finish

/* case FFI_TYPE_STRUCT */
	mtlr r0
	addi r1, r1, 176
	blr
	nop

/* case FFI_TYPE_POINTER */
	lwz r3, 56+0(r1)
	mtlr r0
L..finish:
	addi r1, r1, 176
	blr
#endif
/* END(ffi_closure_ASM) */
