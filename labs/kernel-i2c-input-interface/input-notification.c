        input_event(nunchuk->polled_input->input,
                    EV_KEY, BTN_Z, zpressed);
        input_event(nunchuk->polled_input->input,
                    EV_KEY, BTN_C, cpressed);

        input_sync(nunchuk->polled_input->input);
