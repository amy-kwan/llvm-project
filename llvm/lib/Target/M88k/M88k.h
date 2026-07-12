//===-- M88k.h - Top-level interface for M88k representation ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// M88k back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_M88K_M88K_H
#define LLVM_LIB_TARGET_M88K_M88K_H

#include "llvm/Support/CodeGen.h"

namespace llvm {
class M88kRegisterBankInfo;
class M88kSubtarget;
class M88kTargetMachine;
class FunctionPass;
class InstructionSelector;
class PassRegistry;

FunctionPass *createM88kISelDag(M88kTargetMachine &TM,
                                CodeGenOpt::Level OptLevel);

void initializeM88kDAGToDAGISelPass(PassRegistry &);

InstructionSelector *
createM88kInstructionSelector(const M88kTargetMachine &, const M88kSubtarget &,
                              const M88kRegisterBankInfo &);
} // end namespace llvm
#endif
