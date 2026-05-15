#ifndef USER_TA_HEADER_DEFINES_H
#define USER_TA_HEADER_DEFINES_H

//TODO: define TA_UUID here

#define TA_FLAGS       (TA_FLAG_EXEC_DDR | \
                        TA_FLAG_SINGLE_INSTANCE | \
                        TA_FLAG_MULTI_SESSION)
#define TA_STACK_SIZE   (2 * 1024)
#define TA_DATA_SIZE    (32 * 1024)

#define TA_DESCRIPTION  "Small Trusted Application example."
#define TA_VERSION      "1.0"

#define TA_CURRENT_TA_EXT_PROPERTIES \
    { \
            "log-level", USER_TA_PROP_TYPE_U32, \
            &(const uint32_t){ CFG_TEE_TA_LOG_LEVEL } \
    } \

#endif /* USER_TA_HEADER_DEFINES_H */
