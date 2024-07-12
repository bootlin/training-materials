/* Configure the baud rate to 115200 */
clk = devm_clk_get(&pdev->dev, NULL);
if (IS_ERR(clk)) {
        ret = PTR_ERR(clk);
        goto disable_runtime_pm;
}

uartclk = clk_get_rate(clk);

baud_divisor = uartclk / 16 / 115200;
reg_write(serial, 0x07, UART_OMAP_MDR1);
reg_write(serial, 0x00, UART_LCR);
reg_write(serial, UART_LCR_DLAB, UART_LCR);
reg_write(serial, baud_divisor & 0xff, UART_DLL);
reg_write(serial, (baud_divisor >> 8) & 0xff, UART_DLM);
reg_write(serial, UART_LCR_WLEN8, UART_LCR);
reg_write(serial, 0x00, UART_OMAP_MDR1);
