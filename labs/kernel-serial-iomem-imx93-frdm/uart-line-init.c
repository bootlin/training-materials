#define LPUART_GLOBAL   0x08    /* Global Register */
#define LPUART_BAUD     0x10    /* Baud Rate Register */
#define LPUART_STAT     0x14    /* Status Register */
#define LPUART_CTRL     0x18    /* Control Register */
#define LPUART_DATA     0x1C    /* Data Register */
#define LPUART_FIFO     0x28    /* FIFO Register */
#define LPUART_CTRL_TE      (1 << 19)  /* Transmitter Enable */
#define LPUART_CTRL_RE      (1 << 18)  /* Receiver Enable */
#define LPUART_CTRL_RIE     (1 << 21)  /*Receiver Interrupt Enable*/
#define LPUART_STAT_TDRE    (1 << 23)  /* Transmit Data Register Empty */
#define LPUART_BAUD_SBR_MASK 0x1FFF    /* Baud Rate Modulo Divisor */
#define LPUART_BAUD_TDMAE	(1 << 23)  
#define LPUART_GLOBAL_RST   (1 << 1)   /* Software Reset */
#define LPUART_FIFO_TXFE    (1 << 23)  /* Transmit FIFO Enable */
#define LPUART_FIFO_RXFE    (1 << 22)  /* Receive FIFO Enable */
#define LPUART_FIFO_TXFLUSH (1 << 15)  /* Transmit FIFO Flush */
#define LPUART_FIFO_RXFLUSH (1 << 14)  /* Receive FIFO Flush */
#define GLOBAL_RST_MIN_US	20 /* Minimum time for global reset in microseconds */
#define GLOBAL_RST_MAX_US	40 /* Maximum time for global reset in microseconds */


static int lpuart_build_baud_val(unsigned long clk_hz, unsigned int baud,
				 u32 *baud_val_out)
{
	unsigned int best_osr = 0, best_sbr = 0;
	unsigned long best_err = ~0UL;

	if (!baud_val_out || !baud || !clk_hz)
		return -EINVAL;

	for (unsigned int osr = 4; osr <= 32; osr++) {
		unsigned int sbr = DIV_ROUND_CLOSEST(clk_hz, baud * osr);
		if (!sbr || sbr > LPUART_BAUD_SBR_MASK)
			continue;

		unsigned long actual = clk_hz / (sbr * osr);
		unsigned long err    = abs((long)actual - (long)baud);

		if (err < best_err) {
			best_err  = err;
			best_osr  = osr;
			best_sbr  = sbr;
			if (err == 0)
				break; 
		}
	}
	pr_info("OSR = %u, SBR = %u, err = %lu\n", best_osr, best_sbr, best_err);
	if (!best_osr)
		return -EINVAL;           

	if (best_err * 100 > baud * 3)
		return -EINVAL;

	*baud_val_out = ((best_osr - 1) << 24) | (best_sbr & LPUART_BAUD_SBR_MASK);
	return 0;
}
    
/*Part to put in probe function */

	serial->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
    if (IS_ERR(serial->clk_ipg)) {
        ret = PTR_ERR(serial->clk_ipg);
		dev_err(&pdev->dev, "failed to get uart ipg clk\n");
        goto disable_runtime_pm;
    }
    ret = clk_prepare_enable(serial->clk_ipg);
    if (ret) {
        dev_err(&pdev->dev, "Failed to enable ipg clock\n");
        goto disable_runtime_pm;
    }
	unsigned long clk_frequency = clk_get_rate(serial->clk_ipg);


    reg_write(serial, LPUART_GLOBAL_RST, LPUART_GLOBAL);
    usleep_range(GLOBAL_RST_MIN_US, GLOBAL_RST_MAX_US);
    reg_write(serial, 0x00000000, LPUART_GLOBAL);
    reg_write(serial, 0x0, LPUART_CTRL);
    reg_write(serial, LPUART_FIFO_TXFLUSH | LPUART_FIFO_RXFLUSH, LPUART_FIFO);
    reg_write(serial, LPUART_FIFO_TXFE | LPUART_FIFO_RXFE, LPUART_FIFO);
	ret = lpuart_build_baud_val(clk_get_rate(serial->clk_ipg), 115200, &baud_val);
	if (ret) {
		dev_err(&pdev->dev, "unable to calculate baud rate\n");
		goto disable_runtime_pm;
	}    
	reg_write(serial, baud_val, LPUART_BAUD);
    reg_write(serial, LPUART_CTRL_TE, LPUART_CTRL);
