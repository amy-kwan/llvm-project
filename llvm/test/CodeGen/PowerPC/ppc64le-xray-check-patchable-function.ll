; RUN: llc -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr8 -filetype=obj \
; RUN:   %s -o %t.o 2>&1 | FileCheck %s --check-prefix=NOERR --allow-empty

; This test ensures that XRay patchable-entry size mismatches no longer occur
; when emitting an object file.

; NOERR-NOT: In function: MyFunction
; NOERR-NOT: Size mismatch for: PATCHABLE_FUNCTION_ENTER

target datalayout = "e-m:e-Fn32-i64:64-i128:128-n32:64-S128-v256:256:256-v512:512:512"
target triple = "powerpc64le-unknown-linux-gnu"

define i16 @MyFunction() #0 {
entry:
  ret i16 0
}

attributes #0 = { "function-instrument"="xray-always" }
