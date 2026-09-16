//------------------------------------------------------------------------------
//
// RISC-V Supervisor Mode interrupt enable/disable
//
// Copyright (c) 2020, Hewlett Packard Enterprise Development LP. All rights reserved.<BR>
//
// SPDX-License-Identifier: BSD-2-Clause-Patent
//
//------------------------------------------------------------------------------

#include <Register/RiscV64/RiscVImpl.h>

ASM_GLOBAL ASM_PFX(RiscVDisableSupervisorModeInterrupts)
ASM_GLOBAL ASM_PFX(RiscVEnableSupervisorModeInterrupt)
ASM_GLOBAL ASM_PFX(RiscVGetSupervisorModeInterrupts)
#ifdef RISCV_CPUCP_M_MODE
ASM_GLOBAL ASM_PFX(RiscVDisableMachineModeInterrupts)
ASM_GLOBAL ASM_PFX(RiscVEnableMachineModeInterrupts)
ASM_GLOBAL ASM_PFX(RiscVGetMachineModeInterrupts)
ASM_GLOBAL ASM_PFX(RiscVDisableMachineSoftwareInterrupt)
ASM_GLOBAL ASM_PFX(RiscVDisableMachineLocalInterrupt0)
#endif

#define  SSTATUS_SPP_BIT_POSITION  8

//
// This routine disables supervisor mode interrupt
//
ASM_PFX(RiscVDisableSupervisorModeInterrupts):
  add   sp, sp, -(__SIZEOF_POINTER__)
  sd    a1, (sp)
  li    a1, SSTATUS_SIE
  csrc  CSR_SSTATUS, a1
  ld    a1, (sp)
  add   sp, sp, (__SIZEOF_POINTER__)
  ret

#ifdef RISCV_CPUCP_M_MODE
//
// CPUCP executes UEFI in Machine mode. The Machine-mode helpers below are
// selected only for CPUCP; generic RISC-V platforms continue to use the
// Supervisor-mode helpers below.
//
// This routine disables machine mode interrupt
//
ASM_PFX(RiscVDisableMachineModeInterrupts):
  add   sp, sp, -(__SIZEOF_POINTER__)
  sd    a1, (sp)
  li    a1, MSTATUS_MIE
  csrc  CSR_MSTATUS, a1
  ld    a1, (sp)
  add   sp, sp, (__SIZEOF_POINTER__)
  ret

//
// This routine enables machine mode interrupt
//
ASM_PFX(RiscVEnableMachineModeInterrupts):
  add   sp, sp, -(__SIZEOF_POINTER__)
  sd    a1, (sp)
  li    a1, MSTATUS_MIE
  csrs  CSR_MSTATUS, a1
  ld    a1, (sp)
  add   sp, sp, (__SIZEOF_POINTER__)
  ret
#endif

//
// This routine enables supervisor mode interrupt
//
ASM_PFX(RiscVEnableSupervisorModeInterrupt):
  add   sp, sp, -2*(__SIZEOF_POINTER__)
  sd    a0, (0*__SIZEOF_POINTER__)(sp)
  sd    a1, (1*__SIZEOF_POINTER__)(sp)

  csrr  a0, CSR_SSTATUS
  and   a0, a0, (1 << SSTATUS_SPP_BIT_POSITION)
  bnez  a0, InTrap      // We are in supervisor mode (SMode)
                        // trap handler.
                        // Skip enabling SIE becasue SIE
                        // is set to disabled by RISC-V hart
                        // when the trap takes hart to SMode.

  li    a1, SSTATUS_SIE
  csrs  CSR_SSTATUS, a1
InTrap:
  ld    a0, (0*__SIZEOF_POINTER__)(sp)
  ld    a1, (1*__SIZEOF_POINTER__)(sp)
  add   sp, sp, 2*(__SIZEOF_POINTER__)
  ret

//
// Set Supervisor mode trap vector.
// @param a0 : Value set to Supervisor mode trap vector
//
ASM_FUNC (RiscVSetSupervisorStvec)
    csrrw a1, CSR_STVEC, a0
    ret

//
// Get Supervisor mode trap vector.
// @retval a0 : Value in Supervisor mode trap vector
//
ASM_FUNC (RiscVGetSupervisorStvec)
    csrr a0, CSR_STVEC
    ret

//
// Get Supervisor trap cause CSR.
//
ASM_FUNC (RiscVGetSupervisorTrapCause)
    csrrs a0, CSR_SCAUSE, 0
    ret
//
// This routine returns supervisor mode interrupt
// status.
//
ASM_FUNC (RiscVGetSupervisorModeInterrupts)
  csrr a0, CSR_SSTATUS
  andi a0, a0, SSTATUS_SIE
  ret

#ifdef RISCV_CPUCP_M_MODE
//
// This routine returns machine mode interrupt
// status.
//
ASM_FUNC (RiscVGetMachineModeInterrupts)
  csrr a0, CSR_MSTATUS
  andi a0, a0, MSTATUS_MIE
  ret

//
// This routine disables machine timer interrupt.
//
ASM_FUNC (RiscVDisableTimerInterrupt)
    li   a0, MIP_MTIP
    csrc CSR_MIE, a0
    ret

//
// This routine enables machine timer interrupt.
//
ASM_FUNC (RiscVEnableTimerInterrupt)
    li   a0, MIP_MTIP
    csrs CSR_MIE, a0
    ret

ASM_FUNC (RiscVDisableMachineSoftwareInterrupt)
    li    a0, MIP_MSIP
    csrc  CSR_MIE, a0
    ret

//
// CPUCP Local Interrupt 0 (LIE0) is enabled before control reaches the
// UEFI entry point. CPUCP UEFI currently has no handler or documented
// acknowledge/clear sequence for the underlying interrupt source.
//
// Keep mie.LIE0 masked to prevent an unhandled Machine-mode interrupt
// after global interrupts are enabled.
//
ASM_FUNC (RiscVDisableMachineLocalInterrupt0)
    li    a0, 0x10000
    csrc  CSR_MIE, a0
    ret
#else
//
// This routine disables supervisor mode timer interrupt
//
ASM_FUNC (RiscVDisableTimerInterrupt)
    li   a0, SIP_STIP
    csrc CSR_SIE, a0
    ret

//
// This routine enables supervisor mode timer interrupt
//
ASM_FUNC (RiscVEnableTimerInterrupt)
    li    a0, SIP_STIP
    csrs CSR_SIE, a0
    ret

//
// This routine clears pending supervisor mode timer interrupt
//
ASM_FUNC (RiscVClearPendingTimerInterrupt)
    li   a0, SIP_STIP
    csrc CSR_SIP, a0
    ret
#endif