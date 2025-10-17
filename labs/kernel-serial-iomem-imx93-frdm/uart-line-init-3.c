/* --- Write final configuration to UART registers --- */
reg_write(serial, baud_val, LPUART_BAUD);
reg_write(serial, LPUART_CTRL_TE, LPUART_CTRL);
