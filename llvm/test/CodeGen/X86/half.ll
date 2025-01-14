; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=-f16c -fixup-byte-word-insts=1 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWON
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=-f16c  -fixup-byte-word-insts=0 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWOFF
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+f16c -fixup-byte-word-insts=1 \
; RUN:    | FileCheck %s -check-prefixes=CHECK,BWON,BWON-F16C
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr +sse2 -fixup-byte-word-insts=0  \
; RUN:    | FileCheck %s -check-prefixes=CHECK-I686

define void @test_load_store(half* %in, half* %out) #0 {
; CHECK-LIBCALL-LABEL: test_load_store:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rsi)
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_load_store:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vpinsrw $0, (%rdi), %xmm0, %xmm0
; BWON-F16C-NEXT:    vpextrw $0, %xmm0, (%rsi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_load_store:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    pinsrw $0, (%ecx), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %ecx
; CHECK-I686-NEXT:    movw %cx, (%eax)
; CHECK-I686-NEXT:    retl
  %val = load half, half* %in
  store half %val, half* %out
  ret void
}

define i16 @test_bitcast_from_half(half* %addr) #0 {
; BWON-LABEL: test_bitcast_from_half:
; BWON:       # %bb.0:
; BWON-NEXT:    movzwl (%rdi), %eax
; BWON-NEXT:    retq
;
; BWOFF-LABEL: test_bitcast_from_half:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movw (%rdi), %ax
; BWOFF-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_from_half:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movw (%eax), %ax
; CHECK-I686-NEXT:    retl
  %val = load half, half* %addr
  %val_int = bitcast half %val to i16
  ret i16 %val_int
}

define void @test_bitcast_to_half(half* %addr, i16 %in) #0 {
; CHECK-LABEL: test_bitcast_to_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movw %si, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_to_half:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movw {{[0-9]+}}(%esp), %ax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    movw %ax, (%ecx)
; CHECK-I686-NEXT:    retl
  %val_fp = bitcast i16 %in to half
  store half %val_fp, half* %addr
  ret void
}

define float @test_extend32(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    jmp __extendhfsf2@PLT # TAILCALL
;
; BWON-F16C-LABEL: test_extend32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movzwl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to float
  ret float %val32
}

define double @test_extend64(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    jmp __extendhfdf2@PLT # TAILCALL
;
; BWON-F16C-LABEL: test_extend64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movzwl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfdf2
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to double
  ret double %val32
}

define void @test_trunc32(float %in, half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_trunc32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movw %ax, (%rdi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc float %in to half
  store half %val16, half* %addr
  ret void
}

define void @test_trunc64(double %in, half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_trunc64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movw %ax, (%rdi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movq %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc double %in to half
  store half %val16, half* %addr
  ret void
}

define i64 @test_fptosi_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptosi_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_fptosi_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movzwl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvttss2si %xmm0, %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptosi_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __fixhfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptosi half %a to i64
  ret i64 %r
}

define void @test_sitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    callq __floatdihf@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_sitofp_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    pushq %rbx
; BWON-F16C-NEXT:    movq %rsi, %rbx
; BWON-F16C-NEXT:    callq __floatdihf@PLT
; BWON-F16C-NEXT:    vpextrw $0, %xmm0, (%rbx)
; BWON-F16C-NEXT:    popq %rbx
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __floatdihf
; CHECK-I686-NEXT:    addl $16, %esp
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = sitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define i64 @test_fptoui_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptoui_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rcx
; CHECK-LIBCALL-NEXT:    movq %rcx, %rdx
; CHECK-LIBCALL-NEXT:    sarq $63, %rdx
; CHECK-LIBCALL-NEXT:    subss {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    andq %rdx, %rax
; CHECK-LIBCALL-NEXT:    orq %rcx, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_fptoui_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movzwl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvttss2si %xmm0, %rcx
; BWON-F16C-NEXT:    movq %rcx, %rdx
; BWON-F16C-NEXT:    sarq $63, %rdx
; BWON-F16C-NEXT:    vsubss {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvttss2si %xmm0, %rax
; BWON-F16C-NEXT:    andq %rdx, %rax
; BWON-F16C-NEXT:    orq %rcx, %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptoui_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __fixunshfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptoui half %a to i64
  ret i64 %r
}

define void @test_uitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_uitofp_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    callq __floatundihf@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_uitofp_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    pushq %rbx
; BWON-F16C-NEXT:    movq %rsi, %rbx
; BWON-F16C-NEXT:    callq __floatundihf@PLT
; BWON-F16C-NEXT:    vpextrw $0, %xmm0, (%rbx)
; BWON-F16C-NEXT:    popq %rbx
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_uitofp_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __floatundihf
; CHECK-I686-NEXT:    addl $16, %esp
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = uitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define <4 x float> @test_extend32_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend32_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    subq $72, %rsp
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, 2(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, 4(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, 6(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    unpcklps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    unpcklps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; CHECK-LIBCALL-NEXT:    unpcklpd (%rsp), %xmm0 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = xmm0[0],mem[0]
; CHECK-LIBCALL-NEXT:    addq $72, %rsp
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_extend32_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtph2ps (%rdi), %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $88, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    pinsrw $0, 6(%eax), %xmm0
; CHECK-I686-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    pinsrw $0, 4(%eax), %xmm0
; CHECK-I686-NEXT:    pinsrw $0, 2(%eax), %xmm1
; CHECK-I686-NEXT:    pextrw $0, %xmm1, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; CHECK-I686-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; CHECK-I686-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-I686-NEXT:    addl $88, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x float>
  ret <4 x float> %b
}

define <4 x double> @test_extend64_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend64_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    subq $72, %rsp
; CHECK-LIBCALL-NEXT:    pinsrw $0, 4(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, 6(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    pinsrw $0, 2(%rdi), %xmm0
; CHECK-LIBCALL-NEXT:    callq __extendhfdf2@PLT
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfdf2@PLT
; CHECK-LIBCALL-NEXT:    unpcklpd {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = xmm0[0],mem[0]
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfdf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfdf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, %xmm1
; CHECK-LIBCALL-NEXT:    unpcklpd {{[-0-9]+}}(%r{{[sb]}}p), %xmm1 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = xmm1[0],mem[0]
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    addq $72, %rsp
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_extend64_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtph2ps (%rdi), %xmm0
; BWON-F16C-NEXT:    vcvtps2pd %xmm0, %ymm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $104, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, 6(%eax), %xmm0
; CHECK-I686-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    pinsrw $0, 2(%eax), %xmm0
; CHECK-I686-NEXT:    pinsrw $0, 4(%eax), %xmm1
; CHECK-I686-NEXT:    pextrw $0, %xmm1, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfdf2
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfdf2
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %esi
; CHECK-I686-NEXT:    calll __extendhfdf2
; CHECK-I686-NEXT:    movw %si, (%esp)
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __extendhfdf2
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movhps {{.*#+}} xmm0 = xmm0[0,1],mem[0,1]
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-I686-NEXT:    movhps {{.*#+}} xmm1 = xmm1[0,1],mem[0,1]
; CHECK-I686-NEXT:    addl $104, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x double>
  ret <4 x double> %b
}

define void @test_trunc32_vec4(<4 x float> %a, <4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_trunc32_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $64, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,1,1]
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movdqa (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 6(%rbx)
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 4(%rbx)
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 2(%rbx)
; CHECK-LIBCALL-NEXT:    addq $64, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc32_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, (%rdi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $88, %esp
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movaps %xmm0, %xmm1
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1],xmm0[1,1]
; CHECK-I686-NEXT:    movss %xmm1, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 6(%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 4(%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 2(%esi)
; CHECK-I686-NEXT:    addl $88, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x float> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

define void @test_trunc64_vec4(<4 x double> %a, <4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_trunc64_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $64, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movaps %xmm1, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 4(%rbx)
; CHECK-LIBCALL-NEXT:    movdqa (%rsp), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 6(%rbx)
; CHECK-LIBCALL-NEXT:    movdqa {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-LIBCALL-NEXT:    movw %ax, 2(%rbx)
; CHECK-LIBCALL-NEXT:    addq $64, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc64_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; BWON-F16C-NEXT:    vcvtsd2ss %xmm1, %xmm1, %xmm1
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; BWON-F16C-NEXT:    vmovd %xmm1, %eax
; BWON-F16C-NEXT:    vextractf128 $1, %ymm0, %xmm1
; BWON-F16C-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm1[1,0]
; BWON-F16C-NEXT:    vcvtsd2ss %xmm2, %xmm2, %xmm2
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm2, %xmm2
; BWON-F16C-NEXT:    vmovd %xmm2, %ecx
; BWON-F16C-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %edx
; BWON-F16C-NEXT:    vcvtsd2ss %xmm1, %xmm1, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %esi
; BWON-F16C-NEXT:    movw %si, 4(%rdi)
; BWON-F16C-NEXT:    movw %dx, (%rdi)
; BWON-F16C-NEXT:    movw %cx, 6(%rdi)
; BWON-F16C-NEXT:    movw %ax, 2(%rdi)
; BWON-F16C-NEXT:    vzeroupper
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $88, %esp
; CHECK-I686-NEXT:    movaps %xmm1, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 6(%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 4(%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, 2(%esi)
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $88, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x double> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

declare float @test_floatret();

; On i686, if SSE2 is available, the return value from test_floatret is loaded
; to f80 and then rounded to f32.  The DAG combiner should not combine this
; fp_round and the subsequent fptrunc from float to half.
define half @test_f80trunc_nodagcombine() #0 {
; CHECK-LIBCALL-LABEL: test_f80trunc_nodagcombine:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    callq test_floatret@PLT
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_f80trunc_nodagcombine:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    pushq %rax
; BWON-F16C-NEXT:    callq test_floatret@PLT
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    vpinsrw $0, %eax, %xmm0, %xmm0
; BWON-F16C-NEXT:    popq %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_f80trunc_nodagcombine:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    calll test_floatret@PLT
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %1 = call float @test_floatret()
  %2 = fptrunc float %1 to half
  ret half %2
}




define float @test_sitofp_fadd_i32(i32 %a, half* %b) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_fadd_i32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    subq $40, %rsp
; CHECK-LIBCALL-NEXT:    pinsrw $0, (%rsi), %xmm0
; CHECK-LIBCALL-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    addl $-2147483648, %edi # imm = 0x80000000
; CHECK-LIBCALL-NEXT:    movl %edi, {{[0-9]+}}(%rsp)
; CHECK-LIBCALL-NEXT:    movl $1127219200, {{[0-9]+}}(%rsp) # imm = 0x43300000
; CHECK-LIBCALL-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-LIBCALL-NEXT:    subsd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; CHECK-LIBCALL-NEXT:    callq __truncdfhf2@PLT
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movss {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    addss {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 4-byte Folded Reload
; CHECK-LIBCALL-NEXT:    callq __truncsfhf2@PLT
; CHECK-LIBCALL-NEXT:    addq $40, %rsp
; CHECK-LIBCALL-NEXT:    jmp __extendhfsf2@PLT # TAILCALL
;
; BWON-F16C-LABEL: test_sitofp_fadd_i32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movzwl (%rsi), %eax
; BWON-F16C-NEXT:    addl $-2147483648, %edi # imm = 0x80000000
; BWON-F16C-NEXT:    movl %edi, -{{[0-9]+}}(%rsp)
; BWON-F16C-NEXT:    movl $1127219200, -{{[0-9]+}}(%rsp) # imm = 0x43300000
; BWON-F16C-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; BWON-F16C-NEXT:    vsubsd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %ecx
; BWON-F16C-NEXT:    movzwl %cx, %ecx
; BWON-F16C-NEXT:    vmovd %ecx, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %eax, %xmm1
; BWON-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; BWON-F16C-NEXT:    vaddss %xmm0, %xmm1, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movzwl %ax, %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_fadd_i32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $76, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    pinsrw $0, (%eax), %xmm0
; CHECK-I686-NEXT:    movdqa %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movl $-2147483648, %eax # imm = 0x80000000
; CHECK-I686-NEXT:    xorl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movl $1127219200, {{[0-9]+}}(%esp) # imm = 0x43300000
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    subsd {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0
; CHECK-I686-NEXT:    movsd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movapd %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    movdqa {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    addss {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncsfhf2
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    addl $76, %esp
; CHECK-I686-NEXT:    retl
  %tmp0 = load half, half* %b
  %tmp1 = sitofp i32 %a to half
  %tmp2 = fadd half %tmp0, %tmp1
  %tmp3 = fpext half %tmp2 to float
  ret float %tmp3
}

define half @PR40273(half) #0 {
; CHECK-LIBCALL-LABEL: PR40273:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    xorl %eax, %eax
; CHECK-LIBCALL-NEXT:    xorps %xmm1, %xmm1
; CHECK-LIBCALL-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    movl $15360, %ecx # imm = 0x3C00
; CHECK-LIBCALL-NEXT:    cmovnel %ecx, %eax
; CHECK-LIBCALL-NEXT:    cmovpl %ecx, %eax
; CHECK-LIBCALL-NEXT:    pinsrw $0, %eax, %xmm0
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: PR40273:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vpextrw $0, %xmm0, %eax
; BWON-F16C-NEXT:    movzwl %ax, %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    xorl %eax, %eax
; BWON-F16C-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; BWON-F16C-NEXT:    vucomiss %xmm1, %xmm0
; BWON-F16C-NEXT:    movl $15360, %ecx # imm = 0x3C00
; BWON-F16C-NEXT:    cmovnel %ecx, %eax
; BWON-F16C-NEXT:    cmovpl %ecx, %eax
; BWON-F16C-NEXT:    vpinsrw $0, %eax, %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: PR40273:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    pinsrw $0, {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    xorl %eax, %eax
; CHECK-I686-NEXT:    xorps %xmm1, %xmm1
; CHECK-I686-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-I686-NEXT:    movl $15360, %ecx # imm = 0x3C00
; CHECK-I686-NEXT:    cmovnel %ecx, %eax
; CHECK-I686-NEXT:    cmovpl %ecx, %eax
; CHECK-I686-NEXT:    pinsrw $0, %eax, %xmm0
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %2 = fcmp une half %0, 0xH0000
  %3 = uitofp i1 %2 to half
  ret half %3
}

define dso_local void @brcond(half %0) {
; CHECK-LIBCALL-LABEL: brcond:
; CHECK-LIBCALL:       # %bb.0: # %entry
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    .cfi_def_cfa_offset 16
; CHECK-LIBCALL-NEXT:    callq __extendhfsf2@PLT
; CHECK-LIBCALL-NEXT:    xorps %xmm1, %xmm1
; CHECK-LIBCALL-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    setp %al
; CHECK-LIBCALL-NEXT:    setne %cl
; CHECK-LIBCALL-NEXT:    orb %al, %cl
; CHECK-LIBCALL-NEXT:    jne .LBB18_2
; CHECK-LIBCALL-NEXT:  # %bb.1: # %if.then
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    .cfi_def_cfa_offset 8
; CHECK-LIBCALL-NEXT:    retq
; CHECK-LIBCALL-NEXT:  .LBB18_2: # %if.end
;
; BWON-F16C-LABEL: brcond:
; BWON-F16C:       # %bb.0: # %entry
; BWON-F16C-NEXT:    vpextrw $0, %xmm0, %eax
; BWON-F16C-NEXT:    movzwl %ax, %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; BWON-F16C-NEXT:    vucomiss %xmm1, %xmm0
; BWON-F16C-NEXT:    setp %al
; BWON-F16C-NEXT:    setne %cl
; BWON-F16C-NEXT:    orb %al, %cl
; BWON-F16C-NEXT:    jne .LBB18_2
; BWON-F16C-NEXT:  # %bb.1: # %if.then
; BWON-F16C-NEXT:    retq
; BWON-F16C-NEXT:  .LBB18_2: # %if.end
;
; CHECK-I686-LABEL: brcond:
; CHECK-I686:       # %bb.0: # %entry
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    .cfi_def_cfa_offset 16
; CHECK-I686-NEXT:    pinsrw $0, {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    pextrw $0, %xmm0, %eax
; CHECK-I686-NEXT:    movw %ax, (%esp)
; CHECK-I686-NEXT:    calll __extendhfsf2
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    xorps %xmm1, %xmm1
; CHECK-I686-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-I686-NEXT:    setp %al
; CHECK-I686-NEXT:    setne %cl
; CHECK-I686-NEXT:    orb %al, %cl
; CHECK-I686-NEXT:    jne .LBB18_2
; CHECK-I686-NEXT:  # %bb.1: # %if.then
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    .cfi_def_cfa_offset 4
; CHECK-I686-NEXT:    retl
; CHECK-I686-NEXT:  .LBB18_2: # %if.end
entry:
  %cmp = fcmp oeq half 0xH0000, %0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  ret void

if.end:                                           ; preds = %entry
  unreachable
}

attributes #0 = { nounwind }
