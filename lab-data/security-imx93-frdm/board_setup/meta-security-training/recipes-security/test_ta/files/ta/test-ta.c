#define STR_TRACE_USER_TA "bootlin-test-ta"
#include <tee_internal_api.h>


TEE_Result TA_CreateEntryPoint(void)
{
    /* Allocate some resources, init something, ... */
    DMSG("TA_CreateEntryPoint - Nothing to do");
    /* Return with a status */
    return TEE_SUCCESS;
}

void TA_DestroyEntryPoint(void)
{
    /* Release resources if required before TA destruction */
    DMSG("TA_DestroyEntryPoint - Nothing to do");
}

TEE_Result TA_OpenSessionEntryPoint(uint32_t ptype,
                                    TEE_Param param[4],
                                    void **session_id_ptr)
{
    /* Check client identity, and alloc/init some session resources if any */
    DMSG("TA_OpenSessionEntryPoint - Nothing to do");

    /* Return with a status */
    return TEE_SUCCESS;
}

void TA_CloseSessionEntryPoint(void *sess_ptr)
{
    /* check client and handle session resource release, if any */
    DMSG("TA_CloseSessionEntryPoint - Nothing to do");
}

TEE_Result get_current_el(uint32_t parameters_type, TEE_Param parameters[4]);
// TODO: implement get_current_el() here

TEE_Result TA_InvokeCommandEntryPoint(void *session_id,
                                      uint32_t command_id,
                                      uint32_t parameters_type,
                                      TEE_Param parameters[4])
{
    /* Decode the command and process execution of the target service */
    DMSG("TA_InvokeCommandEntryPoint");

    if(command_id != 0)
        return TEE_ERROR_BAD_PARAMETERS;

    return get_current_el(parameters_type, parameters);
}

