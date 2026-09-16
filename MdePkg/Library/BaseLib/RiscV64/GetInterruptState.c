/** @file
  CPU get interrupt state function for RISC-V

  Copyright (c) 2020, Hewlett Packard Enterprise Development LP. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent
**/

#include "BaseLibInternals.h"
#include <Register/RiscV64/RiscVEncoding.h>

extern UINT32
RiscVGetSupervisorModeInterrupts (
  VOID
  );

#ifdef RISCV_CPUCP_M_MODE
extern UINT32
RiscVGetMachineModeInterrupts (
  VOID
  );
#endif

/**
  Retrieves the current CPU interrupt state.

  Returns TRUE is interrupts are currently enabled. Otherwise
  returns FALSE.

  @retval TRUE  CPU interrupts are enabled.
  @retval FALSE CPU interrupts are disabled.

**/
BOOLEAN
EFIAPI
GetInterruptState (
  VOID
  )
{
  unsigned long  RetValue;

#ifdef RISCV_CPUCP_M_MODE
  RetValue = RiscVGetMachineModeInterrupts ();
#else
  RetValue = RiscVGetSupervisorModeInterrupts ();
#endif

  return RetValue ? TRUE : FALSE;
}
