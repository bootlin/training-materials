#include <stdio.h>
#include <stdlib.h>
#include <hsm/hsm_api.h>

int main(int argc, char *argv[]) {
    open_session_args_t open_session_args = {0};
    hsm_hdl_t hsm_session_hdl;
    hsm_hdl_t key_store_hdl;
    hsm_err_t err;
    // open_svc_key_store_args_t open_svc_key_store_args = {0};
    // op_get_random_args_t rng_get_random_args

    open_session_args.mu_type = HSM1;

    err = hsm_open_session(&open_session_args, &hsm_session_hdl);

    if (err != HSM_NO_ERROR){
	printf("Opening the HSM session failed - err: 0x%x\n", err);
	return -1;
    }
}
