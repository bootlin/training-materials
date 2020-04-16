set_bit(ABS_X, input->absbit);
set_bit(ABS_Y, input->absbit);
input_set_abs_params(input, ABS_X, 30, 220, 4, 8);
input_set_abs_params(input, ABS_Y, 40, 200, 4, 8);
