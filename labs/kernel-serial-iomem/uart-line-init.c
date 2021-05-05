/* Configure the baud rate to 115200 */

ret = of_property_read_u32(pdev->dev.of_node, "clock-frequency",
			   &uartclk);
if (ret) {
	dev_err(&pdev->dev,
		"clock-frequency property not found in Device Tree\n");
	return ret;
}

baud_divisor = uartclk / 16 / 115200;
reg_write(serial, 0x07, UART_OMAP_MDR1);
reg_write(serial, 0x00, UART_LCR);
reg_write(serial, UART_LCR_DLAB, UART_LCR);
reg_write(serial, baud_divisor & 0xff, UART_DLL);
reg_write(serial, (baud_divisor >> 8) & 0xff, UART_DLM);
reg_write(serial, UART_LCR_WLEN8, UART_LCR);
