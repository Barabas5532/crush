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
    .globl begin_signature

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
    .globl end_signature


/* This macros must define the test-target halt mechanism. This macro is
 * called when the test is to be terminated either due to completion or dur to
 * unsupported behavior. This macro could also include routines to dump the
 * signature region to a file on the host system which can be used for
 * comparison.
 */
#define RVMODEL_HALT \
    la x1, 0x30000000; \
    lw x1, 0(x1)

/* contains boot code for the test-target; may include emulation code or trap
 * stub. If the test-target enforces alignment or value restrictions on the
 * mtvec csr, it is required that this macro sets the value of mtvec to a
 * region which is readable and writable by the machine mode. May include code
 * to copy the data sections from boot device to ram. Or any other code that
 * needs to be run prior to running the tests.
 */
#define RVMODEL_BOOT \
    /* Copy data section from flash to RAM */ \
    la x1, _srelocate; \
    la x2, _erelocate; \
    la x3, _etext; \
rvmodel_boot_loop: \
    beq x1, x2, rvmodel_boot_done; \
    lw x31, 0(x3); \
    sw x31, 0(x1); \
    addi x1, x1, 4; \
    addi x3, x3, 4; \
    j rvmodel_boot_loop; \
rvmodel_boot_done:

/* debug assertion that GPR should have value
 *
 * outputs a debug message if Reg!=Value
 *
 * ScrReg is a scratch register used by the output routine; its final value
 * cannot be guaranteed
 *
 * Can be used to help debug what tests have passed/failed
 */
#define RVMODEL_IO_ASSERT_GPR_EQ(ScrReg, Reg, Value)

#endif // CRUSH_ENV_MODEL_TEST_H
