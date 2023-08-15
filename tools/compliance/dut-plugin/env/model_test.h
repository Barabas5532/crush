#ifndef CRUSH_DUT_PLUGIN_ENV_MODEL_TEST_H
#define CRUSH_DUT_PLUGIN_ENV_MODEL_TEST_H

/*
 *
4.3.2. Required, Model-defined Macros

These macros are be defined by the owner of the test target in the file
model_test.h. These macros are required to define the signature regions and
also the logic required to halt/exit the test.

RVMODEL_DATA_BEGIN

        This macro marks the start of signature regions. The test-target should
        use this macro to create a label to indicate the begining of the
        signature region. For example : .globl begin_signature;
        begin_signature. This macro must also begin at a 16-byte boundary and
        must not include anything else.

RVMODEL_DATA_END

        This macros marks the end of the signature-region. The test-target must
        declare any labels required to indicate the end of the signature
        region. For example : .globl end_signature; end_signature. This label
        must be at a 16-byte boundary. The entire signature region must be
        included within the RVMODEL_DATA_BEGIN macro and the start of the
        RVMODEL_DATA_END macro. The RVMODEL_DATA_END macro can also contain
        other target specific data regions and initializations but only after
        the end of the signature.

RVMODEL_HALT

        This macros must define the test-target halt mechanism. This macro is
        called when the test is to be terminated either due to completion or
        dur to unsupported behavior. This macro could also include routines to
        dump the signature region to a file on the host system which can be
        used for comparison.
 */

#define RVMODEL_DATA_BEGIN .globl begin_signature; begin_signature
#define RVMODEL_DATA_END   .globl end_signature; end_signature
#define RVMODEL_HALT 

#endif // CRUSH_DUT_PLUGIN_ENV_MODEL_TEST_H
