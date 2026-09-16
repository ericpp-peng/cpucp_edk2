/** @file
  CPU disable interrupt function for RISC-V

  Copyright (c) 2020, Hewlett Packard Enterprise Development LP. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent
**/
#include "BaseLibInternals.h"
#include <Register/RiscV64/RiscVEncoding.h>

extern VOID
RiscVDisableSupervisorModeInterrupts (
  VOID
  );

#ifdef RISCV_CPUCP_M_MODE
extern VOID
RiscVDisableMachineModeInterrupts (
  VOID
  );
#endif

/**
  Disables CPU interrupts.

**/
VOID
EFIAPI
DisableInterrupts (
  VOID
  )
{
#ifdef RISCV_CPUCP_M_MODE
  RiscVDisableMachineModeInterrupts ();
#else
  RiscVDisableSupervisorModeInterrupts ();
#endif
}
