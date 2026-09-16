/** @file
  CPU enable interrupt function for RISC-V

  Copyright (c) 2020, Hewlett Packard Enterprise Development LP. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent
**/

#include "BaseLibInternals.h"
#include <Register/RiscV64/RiscVEncoding.h>

extern VOID
RiscVEnableSupervisorModeInterrupt (
  VOID
  );

#ifdef RISCV_CPUCP_M_MODE
extern VOID
RiscVEnableMachineModeInterrupts (
  VOID
  );
#endif

/**
  Enables CPU interrupts.

**/
VOID
EFIAPI
EnableInterrupts (
  VOID
  )
{
#ifdef RISCV_CPUCP_M_MODE
  RiscVEnableMachineModeInterrupts ();
#else
  RiscVEnableSupervisorModeInterrupt ();
#endif
}
