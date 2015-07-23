input_event(polled_input->input,
	    EV_KEY, BTN_Z, zpressed);
input_event(polled_input->input,
	    EV_KEY, BTN_C, cpressed);
input_sync(polled_input->input);
