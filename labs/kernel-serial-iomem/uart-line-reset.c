/* Soft reset */
reg_write(dev, UART_FCR_CLEAR_RCVR | UART_FCR_CLEAR_XMIT, UART_FCR);
reg_write(dev, 0x00, UART_OMAP_MDR1);
