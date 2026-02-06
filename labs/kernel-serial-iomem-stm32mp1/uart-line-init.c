serial->clk = devm_clk_get(&pdev->dev, NULL);
if (IS_ERR(serial->clk))
	return PTR_ERR(serial->clk);

/* Ensure that clk rate is correct by enabling the clk */
ret = clk_prepare_enable(serial->clk);
if (ret)
	goto err_clk;

uartclk = clk_get_rate(serial->clk);
if (!uartclk) {
	ret = -EINVAL;
	goto err_clk;
}

/* Configure the baud rate to 115200 */
baud_divisor = uartclk / 115200;
reg_write(serial, baud_divisor, USART_BRR);

/* Configure the line */
cr1 = USART_CR1_TE | USART_CR1_RE;
reg_write(serial, cr1, USART_CR1);

/* Enable USART */
cr1 |= USART_CR1_UE;
reg_write(serial, cr1, USART_CR1);

