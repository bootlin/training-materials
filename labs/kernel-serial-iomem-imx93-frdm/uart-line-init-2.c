/* --- Reset UART, flush FIFO, enable FIFO, and compute baud rate --- */

/* Retrieve the actual clock frequency for baud rate calculations */
unsigned long clk_frequency = clk_get_rate(serial->clk_ipg);

reg_write(serial, LPUART_GLOBAL_RST, LPUART_GLOBAL);
usleep_range(GLOBAL_RST_MIN_US, GLOBAL_RST_MAX_US);
reg_write(serial, 0x00000000, LPUART_GLOBAL);
reg_write(serial, 0x0, LPUART_CTRL);
reg_write(serial, LPUART_FIFO_TXFLUSH | LPUART_FIFO_RXFLUSH, LPUART_FIFO);
reg_write(serial, LPUART_FIFO_TXFE | LPUART_FIFO_RXFE, LPUART_FIFO);
ret = lpuart_build_baud_val(clk_frequency, 115200, &baud_val);
if (ret) {
    dev_err(&pdev->dev, "unable to calculate baud rate\n");
    goto disable_runtime_pm;
}
