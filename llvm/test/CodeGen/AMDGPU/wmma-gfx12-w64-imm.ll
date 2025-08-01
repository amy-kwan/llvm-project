; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn -mcpu=gfx1200 -mattr=+wavefrontsize64 < %s | FileCheck %s --check-prefix=GFX12

define amdgpu_ps void @test_wmma_f32_16x16x16_f16_imm(<4 x half> %A, <4 x half> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_f16_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_f16 v[6:9], v[0:1], v[2:3], 1.0
; GFX12-NEXT:    global_store_b128 v[4:5], v[6:9], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float>@llvm.amdgcn.wmma.f32.16x16x16.f16.v4f32.v4f16(<4 x half> %A, <4 x half> %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_f16_imm_non_inlineable(<4 x half> %A, <4 x half> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_f16_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v6, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v7, v6
; GFX12-NEXT:    v_mov_b32_e32 v8, v6
; GFX12-NEXT:    v_mov_b32_e32 v9, v6
; GFX12-NEXT:    v_wmma_f32_16x16x16_f16 v[6:9], v[0:1], v[2:3], v[6:9]
; GFX12-NEXT:    global_store_b128 v[4:5], v[6:9], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float>@llvm.amdgcn.wmma.f32.16x16x16.f16.v4f32.v4f16(<4 x half> %A, <4 x half> %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf16_imm(<4 x i16> %A, <4 x i16> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf16_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf16 v[6:9], v[0:1], v[2:3], 1.0
; GFX12-NEXT:    global_store_b128 v[4:5], v[6:9], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf16.v4f32.v4i16(<4 x i16> %A, <4 x i16> %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf16_imm_non_inlineable(<4 x i16> %A, <4 x i16> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf16_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v6, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v7, v6
; GFX12-NEXT:    v_mov_b32_e32 v8, v6
; GFX12-NEXT:    v_mov_b32_e32 v9, v6
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf16 v[6:9], v[0:1], v[2:3], v[6:9]
; GFX12-NEXT:    global_store_b128 v[4:5], v[6:9], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf16.v4f32.v4i16(<4 x i16> %A, <4 x i16> %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f16_16x16x16_f16_imm(<4 x half> %A, <4 x half> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f16_16x16x16_f16_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f16_16x16x16_f16 v[6:7], v[0:1], v[2:3], 1.0
; GFX12-NEXT:    global_store_b64 v[4:5], v[6:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x half> @llvm.amdgcn.wmma.f16.16x16x16.f16.v4f16.v4f16(<4 x half> %A, <4 x half> %B, <4 x half> <half 1.0, half 1.0, half 1.0, half 1.0>, i1 0)
  store <4 x half> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f16_16x16x16_f16_imm_non_inlineable(<4 x half> %A, <4 x half> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f16_16x16x16_f16_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v6, 0x42004200
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v7, v6
; GFX12-NEXT:    v_wmma_f16_16x16x16_f16 v[6:7], v[0:1], v[2:3], v[6:7]
; GFX12-NEXT:    global_store_b64 v[4:5], v[6:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x half> @llvm.amdgcn.wmma.f16.16x16x16.f16.v4f16.v4f16(<4 x half> %A, <4 x half> %B, <4 x half> <half 3.0, half 3.0, half 3.0, half 3.0>, i1 0)
  store <4 x half> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_bf16_16x16x16_bf16_imm(<4 x i16> %A, <4 x i16> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_bf16_16x16x16_bf16_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v6, 0x3f803f80
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v7, v6
; GFX12-NEXT:    v_wmma_bf16_16x16x16_bf16 v[6:7], v[0:1], v[2:3], v[6:7]
; GFX12-NEXT:    global_store_b64 v[4:5], v[6:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i16> @llvm.amdgcn.wmma.bf16.16x16x16.bf16.v4i16.v4i16(<4 x i16> %A, <4 x i16> %B, <4 x i16> <i16 16256, i16 16256, i16 16256, i16 16256>, i1 0)
  store <4 x i16> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_bf16_16x16x16_bf16_imm_non_inlineable(<4 x i16> %A, <4 x i16> %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_bf16_16x16x16_bf16_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v6, 0x3fc03fc0
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v7, v6
; GFX12-NEXT:    v_wmma_bf16_16x16x16_bf16 v[6:7], v[0:1], v[2:3], v[6:7]
; GFX12-NEXT:    global_store_b64 v[4:5], v[6:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i16> @llvm.amdgcn.wmma.bf16.16x16x16.bf16.v4i16.v4i16(<4 x i16> %A, <4 x i16> %B, <4 x i16> <i16 16320, i16 16320, i16 16320, i16 16320>, i1 0)
  store <4 x i16> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x16_iu8_imm(i32 %A, i32 %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x16_iu8_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_i32_16x16x16_iu8 v[4:7], v0, v1, 1
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu8.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x16_iu8_imm_non_inlineable(i32 %A, i32 %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x16_iu8_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x80
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_i32_16x16x16_iu8 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu8.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 128, i32 128, i32 128, i32 128>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x16_iu4_imm(i32 %A, i32 %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x16_iu4_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_i32_16x16x16_iu4 v[4:7], v0, v1, 1
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu4.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x16_iu4_imm_non_inlineable(i32 %A, i32 %B, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x16_iu4_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x80
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_i32_16x16x16_iu4 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu4.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 128, i32 128, i32 128, i32 128>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_fp8_fp8_imm(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_fp8_fp8_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_fp8_fp8 v[4:7], v0, v1, 1.0
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.fp8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_fp8_fp8_imm_non_inlineable(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_fp8_fp8_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_f32_16x16x16_fp8_fp8 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.fp8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf8_fp8_imm(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf8_fp8_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf8_fp8 v[4:7], v0, v1, 1.0
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.fp8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf8_fp8_imm_non_inlineable(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf8_fp8_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf8_fp8 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.fp8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_fp8_bf8_imm(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_fp8_bf8_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_fp8_bf8 v[4:7], v0, v1, 1.0
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.bf8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_fp8_bf8_imm_non_inlineable(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_fp8_bf8_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_f32_16x16x16_fp8_bf8 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.bf8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf8_bf8_imm(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf8_bf8_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf8_bf8 v[4:7], v0, v1, 1.0
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.bf8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_f32_16x16x16_bf8_bf8_imm_non_inlineable(i32 %A, i32 %B, <4 x float> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_f32_16x16x16_bf8_bf8_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x40400000
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_f32_16x16x16_bf8_bf8 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.bf8.v4f32.i32(i32 %A, i32 %B, <4 x float> <float 3.0, float 3.0, float 3.0, float 3.0>)
  store <4 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x32_iu4_imm(i32 %A, i32 %B, <4 x i32> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x32_iu4_imm:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_wmma_i32_16x16x32_iu4 v[4:7], v0, v1, 1
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x32.iu4.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_ps void @test_wmma_i32_16x16x32_iu4_imm_non_inlineable(i32 %A, i32 %B, <4 x i32> %C, ptr addrspace(1) %out) {
; GFX12-LABEL: test_wmma_i32_16x16x32_iu4_imm_non_inlineable:
; GFX12:       ; %bb.0: ; %bb
; GFX12-NEXT:    v_mov_b32_e32 v4, 0x80
; GFX12-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
; GFX12-NEXT:    v_mov_b32_e32 v5, v4
; GFX12-NEXT:    v_mov_b32_e32 v6, v4
; GFX12-NEXT:    v_mov_b32_e32 v7, v4
; GFX12-NEXT:    v_wmma_i32_16x16x32_iu4 v[4:7], v0, v1, v[4:7]
; GFX12-NEXT:    global_store_b128 v[2:3], v[4:7], off
; GFX12-NEXT:    s_endpgm
bb:
  %res = call <4 x i32> @llvm.amdgcn.wmma.i32.16x16x32.iu4.v4i32.i32(i1 0, i32 %A, i1 0, i32 %B, <4 x i32> <i32 128, i32 128, i32 128, i32 128>, i1 0)
  store <4 x i32> %res, ptr addrspace(1) %out
  ret void
}

declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.f16.v4f32.v4f16(<4 x half>, <4 x half>, <4 x float>)
declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf16.v4f32.v4i16(<4 x i16>, <4 x i16>, <4 x float>)
declare <4 x half> @llvm.amdgcn.wmma.f16.16x16x16.f16.v4f16.v4f16(<4 x half>, <4 x half>, <4 x half>, i1 immarg)
declare <4 x i16> @llvm.amdgcn.wmma.bf16.16x16x16.bf16.v4i16.v4i16(<4 x i16>, <4 x i16>, <4 x i16>, i1 immarg)
declare <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu8.v4i32.i32(i1 immarg, i32, i1 immarg, i32, <4 x i32>, i1 immarg)
declare <4 x i32> @llvm.amdgcn.wmma.i32.16x16x16.iu4.v4i32.i32(i1 immarg, i32, i1 immarg, i32, <4 x i32>, i1 immarg)
declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.fp8.v4f32.i32(i32, i32, <4 x float>)
declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.fp8.bf8.v4f32.i32(i32, i32, <4 x float>)
declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.fp8.v4f32.i32(i32, i32, <4 x float>)
declare <4 x float> @llvm.amdgcn.wmma.f32.16x16x16.bf8.bf8.v4f32.i32(i32, i32, <4 x float>)
declare <4 x i32> @llvm.amdgcn.wmma.i32.16x16x32.iu4.v4i32.i32(i1 immarg, i32, i1 immarg, i32, <4 x i32>, i1 immarg)
