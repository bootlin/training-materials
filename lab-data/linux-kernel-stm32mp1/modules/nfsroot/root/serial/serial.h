// SPDX-License-Identifier: GPL-2.0

#define USART_BRR 		0x0C

#define USART_CR1		0x00
#define USART_CR1_UE		BIT(0)
#define USART_CR1_RE		BIT(2)
#define USART_CR1_TE		BIT(3)
#define USART_CR1_IDLEIE	BIT(4)
#define USART_CR1_RXNEIE	BIT(5)
#define USART_CR1_TCIE		BIT(6)
#define USART_CR1_TXEIE		BIT(7)
#define USART_CR1_PEIE		BIT(8)

#define USART_CR2		0x04

#define USART_CR3		0x08
#define USART_CR3_DMAT		BIT(7)

#define USART_ISR		0x1C
#define USART_ISR_TC		BIT(6)
#define USART_ISR_TXE		BIT(7)

#define USART_RQR		0x18
#define USART_RQR_RXFRQ		BIT(3)

#define USART_RDR		0x24
#define USART_TDR		0x28

