//===-- M88kCallLowering.cpp - Call lowering --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
/// This file implements the lowering of LLVM calls to machine code calls for
/// GlobalISel.
//
//===----------------------------------------------------------------------===//

#include "M88kCallLowering.h"
#include "M88kISelLowering.h"
#include "MCTargetDesc/M88kMCTargetDesc.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/GlobalISel/CallLowering.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"
#include "llvm/CodeGen/GlobalISel/Utils.h"
#include "llvm/CodeGen/LowLevelType.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/Register.h"
#include "llvm/CodeGen/TargetCallingConv.h"
#include <cstdint>

using namespace llvm;

// The generated calling convention is included twice.
#include "M88kGenCallingConv.inc"

M88kCallLowering::M88kCallLowering(const M88kTargetLowering &TLI)
    : CallLowering(&TLI) {}

namespace {

struct OutgoingArgHandler : public CallLowering::OutgoingValueHandler {
  OutgoingArgHandler(MachineIRBuilder &MIRBuilder, MachineRegisterInfo &MRI,
                     MachineInstrBuilder MIB)
      : OutgoingValueHandler(MIRBuilder, MRI), MIB(MIB) {}

  void assignValueToReg(Register ValVReg, Register PhysReg,
                        CCValAssign VA) override;

  void assignValueToAddress(Register ValVReg, Register Addr, LLT MemTy,
                            MachinePointerInfo &MPO,
                            CCValAssign &VA) override{};

  Register getStackAddress(uint64_t Size, int64_t Offset,
                           MachinePointerInfo &MPO,
                           ISD::ArgFlagsTy Flags) override {
    return Register();
  };

  MachineInstrBuilder MIB;
};

struct FormalArgHandler : public CallLowering::IncomingValueHandler {
  FormalArgHandler(MachineIRBuilder &MIRBuilder, MachineRegisterInfo &MRI)
      : CallLowering::IncomingValueHandler(MIRBuilder, MRI) {}

  void assignValueToReg(Register ValVReg, Register PhysReg,
                        CCValAssign VA) override;

  void assignValueToAddress(Register ValVReg, Register Addr, LLT MemTy,
                            MachinePointerInfo &MPO,
                            CCValAssign &VA) override{};

  Register getStackAddress(uint64_t Size, int64_t Offset,
                           MachinePointerInfo &MPO,
                           ISD::ArgFlagsTy Flags) override {
    return Register();
  };
};

} // namespace

void OutgoingArgHandler::assignValueToReg(Register ValVReg, Register PhysReg,
                                          CCValAssign VA) {
  MIB.addUse(PhysReg, RegState::Implicit);
  Register ExtReg = extendRegister(ValVReg, VA);
  MIRBuilder.buildCopy(PhysReg, ExtReg);
}

void FormalArgHandler::assignValueToReg(Register ValVReg, Register PhysReg,
                                        CCValAssign VA) {
  MIRBuilder.getMRI()->addLiveIn(PhysReg);
  MIRBuilder.getMBB().addLiveIn(PhysReg);
  CallLowering::IncomingValueHandler::assignValueToReg(ValVReg, PhysReg, VA);
}

bool M88kCallLowering::lowerReturn(MachineIRBuilder &MIRBuilder,
                                   const Value *Val, ArrayRef<Register> VRegs,
                                   FunctionLoweringInfo &FLI,
                                   Register SwiftErrorVReg) const {
  MachineFunction &MF = MIRBuilder.getMF();
  const Function &F = MF.getFunction();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  auto &DL = F.getParent()->getDataLayout();

  auto MIB = MIRBuilder.buildInstrNoInsert(M88k::RET);

  bool Success = true;
  if (!VRegs.empty()) {
    SmallVector<ArgInfo, 8> SplitArgs;
    ArgInfo OrigArg{VRegs, Val->getType(), 0};
    setArgFlags(OrigArg, AttributeList::ReturnIndex, DL, F);
    splitToValueTypes(OrigArg, SplitArgs, DL, F.getCallingConv());
    OutgoingValueAssigner ArgAssigner(RetCC_M88k);
    OutgoingArgHandler ArgHandler(MIRBuilder, MRI, MIB);
    Success = determineAndHandleAssignments(ArgHandler, ArgAssigner, SplitArgs,
                                            MIRBuilder, F.getCallingConv(),
                                            F.isVarArg());
  }

  MIRBuilder.insertInstr(MIB);
  return Success;
}

bool M88kCallLowering::lowerFormalArguments(MachineIRBuilder &MIRBuilder,
                                            const Function &F,
                                            ArrayRef<ArrayRef<Register>> VRegs,
                                            FunctionLoweringInfo &FLI) const {
  MachineFunction &MF = MIRBuilder.getMF();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const auto &DL = F.getParent()->getDataLayout();

  SmallVector<ArgInfo, 8> SplitArgs;
  for (const auto &[I, Arg] : llvm::enumerate(F.args())) {
    ArgInfo OrigArg{VRegs[I], Arg.getType(), static_cast<unsigned>(I)};
    setArgFlags(OrigArg, I + AttributeList::FirstArgIndex, DL, F);
    splitToValueTypes(OrigArg, SplitArgs, DL, F.getCallingConv());
  }

  IncomingValueAssigner ArgAssigner(CC_M88k);
  FormalArgHandler ArgHandler(MIRBuilder, MRI);
  return determineAndHandleAssignments(ArgHandler, ArgAssigner, SplitArgs,
                                       MIRBuilder, F.getCallingConv(),
                                       F.isVarArg());
}
