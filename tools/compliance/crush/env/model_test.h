#ifndef CRUSH_ENV_MODEL_TEST_H
#define CRUSH_ENV_MODEL_TEST_H

// https://github.com/riscv-non-isa/riscv-arch-test/blob/main/spec/TestFormatSpec.adoc#432-required-model-defined-macros

/* This macro marks the start of signature regions. The test-target should use
 * this macro to create a label to indicate the begining of the signature
 * region. For example : .globl begin_signature; begin_signature. This macro
 * must also begin at a 16-byte boundary and must not include anything else.
 */
#define RVMODEL_DATA_BEGIN \
    .align 4; \
    .globl begin_signature; begin_signature

/* This macros marks the end of the signature-region. The test-target must
 * declare any labels required to indicate the end of the signature region. For
 * example : .globl end_signature; end_signature. This label must be at a
 * 16-byte boundary. The entire signature region must be included within the
 * RVMODEL_DATA_BEGIN macro and the start of the RVMODEL_DATA_END macro. The
 * RVMODEL_DATA_END macro can also contain other target specific data regions
 * and initializations but only after the end of the signature.
 */
#define RVMODEL_DATA_END \
    .align 4; \
    .globl end_signature; end_signature


/* This macros must define the test-target halt mechanism. This macro is
 * called when the test is to be terminated either due to completion or dur to
 * unsupported behavior. This macro could also include routines to dump the
 * signature region to a file on the host system which can be used for
 * comparison.
 */
#define RVMODEL_HALT \
    la a0, 0x3000_0000 \
    lw a0, 0(a0)

#endif // CRUSH_ENV_MODEL_TEST_H
