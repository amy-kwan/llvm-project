//===-- M88kAsmPrinter.cpp - M88k LLVM assembly writer ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format M88k assembly language.
//
//===----------------------------------------------------------------------===//

#include "M88kMCInstLower.h"
#include "MCTargetDesc/M88kMCTargetDesc.h"
#include "TargetInfo/M88kTargetInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/TargetRegistry.h"
#include <memory>

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
class M88kAsmPrinter : public AsmPrinter {
public:
  explicit M88kAsmPrinter(
      TargetMachine &TM,
      std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override {
    return "M88k Assembly Printer";
  }

  void emitInstruction(const MachineInstr *MI) override;
};
} // end of anonymous namespace

void M88kAsmPrinter::emitInstruction(
    const MachineInstr *MI) {
  MCInst LoweredMI;
  M88kMCInstLower Lower;
  Lower.lower(MI, LoweredMI);
  EmitToStreamer(*OutStreamer, LoweredMI);
}

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeM88kAsmPrinter() {
  RegisterAsmPrinter<M88kAsmPrinter> X(
      getTheM88kTarget());
}
