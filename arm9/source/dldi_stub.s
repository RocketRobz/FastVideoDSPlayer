/*---------------------------------------------------------------------------------

  Copyright (C) 2006 - 2016
    Michael Chisholm (Chishm)
    Dave Murphy (WinterMute)

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any
  damages arising from the use of this software.

  Permission is granted to anyone to use this software for any
  purpose, including commercial applications, and to alter it and
  redistribute it freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you
     must not claim that you wrote the original software. If you use
     this software in a product, an acknowledgment in the product
     documentation would be appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and
     must not be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
     distribution.

---------------------------------------------------------------------------------*/

#include <nds/arm9/dldi_asm.h>

	.align	4
	.arm
	.global gDldiStub
@---------------------------------------------------------------------------------

#ifdef LARGE_DLDI
.equ DLDI_ALLOCATED_SPACE,		32768
#else
.equ DLDI_ALLOCATED_SPACE,		16384
#endif

gDldiStub:

dldi_start:

@---------------------------------------------------------------------------------
@ Driver patch file standard header -- 16 bytes
	.word	0xBF8DA5ED		@ Magic number to identify this region
	.asciz	" Chishm"		@ Identifying Magic string (8 bytes with null terminator)
	.byte	0x01			@ Version number
#ifdef LARGE_DLDI
	.byte	DLDI_SIZE_32KB	@32KiB	@ Log [base-2] of the size of this driver in bytes.
	.byte	0x00			@ Sections to fix
	.byte 	DLDI_SIZE_32KB	@32KiB	@ Log [base-2] of the allocated space in bytes.
#else
	.byte	DLDI_SIZE_16KB	@16KiB	@ Log [base-2] of the size of this driver in bytes.
	.byte	0x00			@ Sections to fix
	.byte 	DLDI_SIZE_16KB	@16KiB	@ Log [base-2] of the allocated space in bytes.
#endif
	
@---------------------------------------------------------------------------------
@ Text identifier - can be anything up to 47 chars + terminating null -- 16 bytes
	.align	4
	.asciz "Default (No interface)"

@---------------------------------------------------------------------------------
@ Offsets to important sections within the data	-- 32 bytes
	.align	6
#ifdef LARGE_DLDI
	.word   dldi_start		@ data start
	.word   dldi_end		@ data end
#else
	.word   0x037F8000		@ data start
	.word   0x037FC000		@ data end
#endif
	.word	0x00000000		@ Interworking glue start	-- Needs address fixing
	.word	0x00000000		@ Interworking glue end
	.word   0x00000000		@ GOT start					-- Needs address fixing
	.word   0x00000000		@ GOT end
	.word   0x00000000		@ bss start					-- Needs setting to zero
	.word   0x00000000		@ bss end

@---------------------------------------------------------------------------------
@ DISC_INTERFACE data -- 32 bytes
	.ascii	"DLDI"				@ ioType
	.word	0x00000000			@ Features
	.word	_DLDI_startup			@ 
	.word	_DLDI_isInserted		@ 
	.word	_DLDI_readSectors		@   Function pointers to standard device driver functions
	.word	_DLDI_writeSectors		@ 
	.word	_DLDI_clearStatus		@ 
	.word	_DLDI_shutdown			@ 
	
@---------------------------------------------------------------------------------

_DLDI_startup:
_DLDI_isInserted:
_DLDI_readSectors:
_DLDI_writeSectors:
_DLDI_clearStatus:
_DLDI_shutdown:
	mov		r0, #0x00				@ Return false for every function
	bx		lr



@---------------------------------------------------------------------------------
	.align
	.pool

dldi_data_end:

@ Pad to end of allocated space
.space DLDI_ALLOCATED_SPACE - (dldi_data_end - dldi_start)	

dldi_end:
	.end
@---------------------------------------------------------------------------------
