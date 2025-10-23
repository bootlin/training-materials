/* LPUART register offsets and bitfields */
/* Version ID Register */
#define LPUART_VERID 0x00
/* Global Register */
#define LPUART_GLOBAL 0x08
#define   LPUART_GLOBAL_RST BIT(1) /* Software Reset */
/* Baud Rate Register */
#define LPUART_BAUD 0x10
#define   LPUART_BAUD_SBR_MASK 0x1FFF /* Baud Rate Modulo Divisor */
#define   LPUART_BAUD_BOTHEDGE BIT(17) /* Sample on both edges when receiving */
#define   LPUART_BAUD_TDMAE BIT(23) /* Transmit DMA Enable */
/* Status Register */
#define LPUART_STAT 0x14
#define   LPUART_STAT_TDRE BIT(23) /* Transmit Data Register Empty */
/* Control Register */
#define LPUART_CTRL 0x18
#define   LPUART_CTRL_TE BIT(19) /* Transmitter Enable */
#define   LPUART_CTRL_RE BIT(18) /* Receiver Enable */
#define   LPUART_CTRL_RIE BIT(21) /* Receiver Interrupt Enable */
/* Data Register */
#define LPUART_DATA 0x1C
/* FIFO Register */
#define LPUART_FIFO 0x28
#define   LPUART_FIFO_TXFE BIT(7) /* Transmit FIFO Enable */
#define   LPUART_FIFO_RXFE BIT(3) /* Receive FIFO Enable */
#define   LPUART_FIFO_TXFLUSH BIT(15) /* Transmit FIFO Flush */
#define   LPUART_FIFO_RXFLUSH BIT(14) /* Receive FIFO Flush */

/* Time window for the global reset in microseconds */
#define GLOBAL_RST_MIN_US 20
#define GLOBAL_RST_MAX_US 40

/*
 * Compute the LPUART baud rate register value (OSR + SBR) for a given clock
 * and baud rate, picking the closest match (error < 3%).
 *
 * Example: clk = 80 MHz, baud = 115200 -> OSR=16, SBR=43
 */
static int lpuart_build_baud_val(unsigned long clk_hz, unsigned int baud,
				 u32 *baud_val_out)
{
	unsigned int best_osr = 0;
	unsigned int best_sbr = 0;
	unsigned long best_err = ~0UL;
	unsigned int osr;
	unsigned int sbr;
	unsigned long actual;
	unsigned long err;

	if (!baud_val_out || !baud || !clk_hz)
		return -EINVAL;

	for (osr = 4; osr <= 32; osr++) {
		sbr = DIV_ROUND_CLOSEST(clk_hz, baud * osr);

		if (!sbr || sbr > LPUART_BAUD_SBR_MASK)
			continue;

		actual = clk_hz / (sbr * osr);
		err = abs((long)actual - (long)baud);

		if (err < best_err) {
			best_err = err;
			best_osr = osr;
			best_sbr = sbr;
			if (!err)
				break;
		}
	}

	if (!best_osr || best_err * 100 > baud * 3)
		return -EINVAL;

	*baud_val_out = ((best_osr - 1) << 24) | (best_sbr & LPUART_BAUD_SBR_MASK);

	return 0;
}

static int serial_init_controller(struct serial_dev *serial)
{
	unsigned long clk_freq;
	u32 baud_val;
	int ret;

	/* Retrieve the actual clock frequency for baud rate calculations */
	clk_freq = clk_get_rate(serial->clk);

	/* Reset the controller, enable and flush the FIFOs, compute the prescaler */
	writel(LPUART_GLOBAL_RST, serial->regs + LPUART_GLOBAL);
	usleep_range(GLOBAL_RST_MIN_US, GLOBAL_RST_MAX_US);
	writel(0x00000000, serial->regs + LPUART_GLOBAL);
	writel(0x0, serial->regs + LPUART_CTRL);
	writel(LPUART_FIFO_TXFLUSH | LPUART_FIFO_RXFLUSH, serial->regs + LPUART_FIFO);
	writel(LPUART_FIFO_TXFE | LPUART_FIFO_RXFE, serial->regs + LPUART_FIFO);

	/* Set the baudrate and enable the transmitter */
	ret = lpuart_build_baud_val(clk_freq, 115200, &baud_val);
	if (ret)
		return ret;

	writel(baud_val | LPUART_BAUD_BOTHEDGE, serial->regs + LPUART_BAUD);
	writel(LPUART_CTRL_TE, serial->regs + LPUART_CTRL);

	return 0;
}
