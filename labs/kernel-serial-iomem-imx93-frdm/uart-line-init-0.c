#define LPUART_GLOBAL        0x08    /* Global Register */
#define LPUART_BAUD          0x10    /* Baud Rate Register */
#define LPUART_STAT          0x14    /* Status Register */
#define LPUART_CTRL          0x18    /* Control Register */
#define LPUART_DATA          0x1C    /* Data Register */
#define LPUART_FIFO          0x28    /* FIFO Register */

#define LPUART_CTRL_TE       BIT(19) /* Transmitter Enable */
#define LPUART_CTRL_RE       BIT(18) /* Receiver Enable */
#define LPUART_CTRL_RIE      BIT(21) /* Receiver Interrupt Enable */

#define LPUART_STAT_TDRE     BIT(23) /* Transmit Data Register Empty */

#define LPUART_BAUD_SBR_MASK 0x1FFF  /* Baud Rate Modulo Divisor */
#define LPUART_BAUD_TDMAE    BIT(23) /* Transmit DMA Enable */

#define LPUART_GLOBAL_RST    BIT(1)  /* Software Reset */

#define LPUART_FIFO_TXFE     BIT(23) /* Transmit FIFO Enable */
#define LPUART_FIFO_RXFE     BIT(22) /* Receive FIFO Enable */
#define LPUART_FIFO_TXFLUSH  BIT(15) /* Transmit FIFO Flush */
#define LPUART_FIFO_RXFLUSH  BIT(14) /* Receive FIFO Flush */

#define GLOBAL_RST_MIN_US    20      /* Minimum time for global reset in microseconds */
#define GLOBAL_RST_MAX_US    40      /* Maximum time for global reset in microseconds */

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
