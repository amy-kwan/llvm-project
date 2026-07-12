//===-- M88k.td - Describe the M88000 Target Machine -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "M88kRegisterInfo.td"
include "M88kInstrFormats.td"
include "M88kInstrInfo.td"

// LLVM generic pseudos such as LOAD_STACK_GUARD and PREALLOCATED_ARG
// use the placeholder PointerLikeRegClass. LLVM require each target to
// explicitly remap those operands to the target's actual pointer-capable
// register class, rather than relying on generic PointerLikeRegClass handling.
defm : RemapAllTargetPseudoPointerOperands<GPR>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def M88kInstrInfo : InstrInfo;
def M88kAsmParser : AsmParser;
def M88kAsmParserVariant : AsmParserVariant {
  let RegisterPrefix = "%";
}

def M88k : Target {
  let InstructionSet = M88kInstrInfo;
  let AssemblyParsers  = [M88kAsmParser];
  let AssemblyParserVariants = [M88kAsmParserVariant];
}
