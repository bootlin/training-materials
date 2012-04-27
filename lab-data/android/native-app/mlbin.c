#include <stdio.h>
#include <stdlib.h>

#include <libusb.h>

#define ML_VENDOR_ID		0x0416
#define ML_DEVICE_ID		0x9391

#define ML_ACTION_FIRE			0x10
#define ML_ACTION_MOVE_DOWN		0x1
#define ML_ACTION_MOVE_LEFT		0x8
#define ML_ACTION_MOVE_RIGHT		0x4
#define ML_ACTION_MOVE_UP		0x2
#define ML_ACTION_STOP			0x0

static struct libusb_device_handle *devh;

int mlbin_init_usb(void)
{
	return 0;
}

int mlbin_free_usb(void)
{
	return 0;
}

int mlbin_fire(void)
{
	printf("Fire!\n");
	return 0;
}

int mlbin_move_down(void)
{
	printf("Move Down!\n");
	return 0;
}

int mlbin_move_left(void)
{
	printf("Move Left!\n");
	return 0;
}

int mlbin_move_right(void)
{
	printf("Move Right!\n");
	return 0;
}

int mlbin_move_up(void)
{
	printf("Move Up!\n");
	return 0;
}

int mlbin_stop(void)
{
	printf("Stop!\n");
	return 0;
}

int main(void)
{
	mlbin_init_usb();
	mlbin_move_down();
	sleep(5);
	mlbin_stop();
	mlbin_move_left();
	sleep(5);
	mlbin_stop();
	mlbin_fire();
	sleep(5);
	mlbin_stop();
	mlbin_move_up();
	sleep(5);
	mlbin_stop();
	mlbin_move_right();
	sleep(5);
	mlbin_stop();
	mlbin_free_usb();

	return 0;
}
