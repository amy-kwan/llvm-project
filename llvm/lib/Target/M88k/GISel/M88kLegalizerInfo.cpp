//===-- M88kLegalizerInfo.cpp -----------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the Machinelegalizer class for M88k.
//===----------------------------------------------------------------------===//

#include "M88kLegalizerInfo.h"
#include "M88kInstrInfo.h"
#include "M88kSubtarget.h"
#include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"
#include "llvm/CodeGen/LowLevelType.h"
#include "llvm/CodeGen/TargetOpcodes.h"

using namespace llvm;

M88kLegalizerInfo::M88kLegalizerInfo(const M88kSubtarget &ST) {
  using namespace TargetOpcode;
  const LLT S32 = LLT::scalar(32);

  getActionDefinitionsBuilder({G_AND, G_OR, G_XOR})
      .legalFor({S32})
      .clampScalar(0, S32, S32);

  getLegacyLegalizerInfo().computeTables();
}
