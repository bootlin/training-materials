/* Configure the baud rate to 115200 */

of_property_read_u32(pdev->dev.of_node, "clock-frequency",
                     &uartclk);
baud_divisor = uartclk / 16 / 115200;
reg_write(dev, 0x07, UART_OMAP_MDR1);
reg_write(dev, 0x00, UART_LCR);
reg_write(dev, UART_LCR_DLAB, UART_LCR);
reg_write(dev, baud_divisor & 0xff, UART_DLL);
reg_write(dev, (baud_divisor >> 8) & 0xff, UART_DLM);
reg_write(dev, UART_LCR_WLEN8, UART_LCR);
