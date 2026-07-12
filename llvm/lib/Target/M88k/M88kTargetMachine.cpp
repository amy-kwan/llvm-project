//===-- M88kTargetMachine.cpp - Define TargetMachine for M88k ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "M88kTargetMachine.h"
#include "M88k.h"
#include "TargetInfo/M88kTargetInfo.h"
#include "llvm/CodeGen/GlobalISel/IRTranslator.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelect.h"
#include "llvm/CodeGen/GlobalISel/Legalizer.h"
#include "llvm/CodeGen/GlobalISel/RegBankSelect.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeM88kTarget() {
  // Register the target.
  RegisterTargetMachine<M88kTargetMachine> X(
      getTheM88kTarget());
  auto &PR = *PassRegistry::getPassRegistry();
  initializeM88kDAGToDAGISelPass(PR);
}

namespace {
// TODO: Check.
std::string computeDataLayout(const Triple &TT,
                              StringRef CPU,
                              StringRef FS) {
  std::string Ret;

  // Big endian.
  Ret += "E";

  // Data mangling.
  Ret += DataLayout::getManglingComponent(TT);

  // Pointers are 32 bit.
  Ret += "-p:32:32:32";

  // All scalar types are naturally aligned.
  Ret += "-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64";

  // Floats and doubles are also naturally aligned.
  Ret += "-f32:32:32-f64:64:64";

  // We prefer 16 bits of aligned for all globals; see
  // above.
  Ret += "-a:8:16";

  // Integer registers are 32bits.
  Ret += "-n32";

  return Ret;
}
} // namespace

/// Create an M88k architecture model.
M88kTargetMachine::M88kTargetMachine(
    const Target &T, const Triple &TT, StringRef CPU,
    StringRef FS, const TargetOptions &Options,
    std::optional<Reloc::Model> RM,
    std::optional<CodeModel::Model> CM,
    CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(
          T, computeDataLayout(TT, CPU, FS), TT, CPU,
          FS, Options, !RM ? Reloc::Static : *RM,
          getEffectiveCodeModel(CM, CodeModel::Medium),
          OL),
      TLOF(std::make_unique<
           TargetLoweringObjectFileELF>()) {
  initAsmInfo();
}

M88kTargetMachine::~M88kTargetMachine() {}

const M88kSubtarget *
M88kTargetMachine::getSubtargetImpl(
    const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute FSAttr =
      F.getFnAttribute("target-features");

  std::string CPU =
      !CPUAttr.hasAttribute(Attribute::None)
          ? CPUAttr.getValueAsString().str()
          : TargetCPU;
  std::string FS = !FSAttr.hasAttribute(Attribute::None)
                       ? FSAttr.getValueAsString().str()
                       : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new
    // subtarget since any creation will depend on the
    // TM and the code generation flags on the function
    // that reside in TargetOptions.
    resetTargetOptions(F);
    I = std::make_unique<M88kSubtarget>(TargetTriple,
                                        CPU, FS, *this);
  }

  return I.get();
}

namespace {
/// M88k Code Generator Pass Configuration Options.
class M88kPassConfig : public TargetPassConfig {
public:
  M88kPassConfig(M88kTargetMachine &TM,
                 PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  bool addInstSelector() override;
  void addPreEmitPass() override;

  // GlobalISEL
  bool addIRTranslator() override;
  bool addLegalizeMachineIR() override;
  bool addRegBankSelect() override;
  bool addGlobalInstructionSelect() override;
};
} // namespace

TargetPassConfig *M88kTargetMachine::createPassConfig(
    PassManagerBase &PM) {
  return new M88kPassConfig(*this, PM);
}

bool M88kPassConfig::addInstSelector() {
  addPass(createM88kISelDag(getTM<M88kTargetMachine>(),
                            getOptLevel()));
  return false;
}

void M88kPassConfig::addPreEmitPass() {
  // TODO Add pass for div-by-zero check.
}

// Global ISEL
bool M88kPassConfig::addIRTranslator() {
  addPass(new IRTranslator());
  return false;
}

bool M88kPassConfig::addLegalizeMachineIR() {
  addPass(new Legalizer());
  return false;
}

bool M88kPassConfig::addRegBankSelect() {
  addPass(new RegBankSelect());
  return false;
}

bool M88kPassConfig::addGlobalInstructionSelect() {
  addPass(new InstructionSelect(getOptLevel()));
  return false;
}
