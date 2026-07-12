//===-- M88kInstrInfo.cpp - M88k instruction information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the M88k implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "M88kInstrInfo.h"
#include "M88kSubtarget.h"
#include "MCTargetDesc/M88kMCTargetDesc.h"
#include "llvm/CodeGen/LiveIntervals.h"
#include "llvm/CodeGen/LiveVariables.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#define GET_INSTRMAP_INFO
#include "M88kGenInstrInfo.inc"

#define DEBUG_TYPE "m88k-ii"

// Pin the vtable to this file.
void M88kInstrInfo::anchor() {}

M88kInstrInfo::M88kInstrInfo(M88kSubtarget &STI)
    : M88kGenInstrInfo(), RI(), STI(STI) {}

bool M88kInstrInfo::expandPostRAPseudo(
    MachineInstr &MI) const {
  MachineBasicBlock &MBB = *MI.getParent();

  switch (MI.getOpcode()) {
  default:
    return false;
  case M88k::RET: {
    MachineInstrBuilder MIB =
        BuildMI(MBB, &MI, MI.getDebugLoc(),
                get(M88k::JMP))
            .addReg(M88k::R1, RegState::Undef);

    // Retain any imp-use flags.
    for (auto &MO : MI.operands()) {
      if (MO.isImplicit())
        MIB.add(MO);
    }
    break;
  }
  }

  // Erase the pseudo instruction.
  MBB.erase(MI);
  return true;
}
