#include <stdio.h>
#include <stdlib.h>

#include <libusb.h>

#define ML_VENDOR_ID			0x0416
#define ML_DEVICE_ID			0x9391

#define ML_ACTION_FIRE			0x10
#define ML_ACTION_MOVE_DOWN		0x1
#define ML_ACTION_MOVE_LEFT		0x8
#define ML_ACTION_MOVE_RIGHT		0x4
#define ML_ACTION_MOVE_UP		0x2
#define ML_ACTION_STOP			0x0

static struct libusb_device_handle *devh;

int mlbin_init_usb(void)
{
	libusb_device **list;
	libusb_device *device = NULL;
	int count, ret, i;

	printf("Calling mlbin_init\n");

	ret = libusb_init(NULL);

	if(ret < 0) {
		printf("Couldn't initialize libusb.\n");
		goto error;
	}

	count = libusb_get_device_list(NULL, &list);
	if (count < 0) {
		printf("Couldn't get device list\n");
		goto list_error;
	}

	for (i = 0; i < count; i++) {
		struct libusb_device_descriptor desc;
		device = list[i];
		libusb_get_device_descriptor(device, &desc);
		printf("Found a new device : %x:%x\n",
			desc.idVendor, desc.idProduct);
		if (desc.idVendor == ML_VENDOR_ID &&
			desc.idProduct == ML_DEVICE_ID)
			break;
		device = NULL;
	}

	if (!device) {
		printf("Couldn't find the device\n");
		goto not_found_error;
	}

	ret = libusb_open(device, &devh);
	if (ret) {
		printf("Couldn't open device: %d\n", ret);
		goto open_dev_error;
	}

	libusb_detach_kernel_driver(devh, 0);
	ret = libusb_claim_interface(devh, 0);
	if(ret < 0) {
		printf("Couldn't claim the interface : %d.\n", ret);
		goto if_error;
	}

	libusb_free_device_list(list, count);

	printf("Interface setup.\n");
	return 0;

if_error:
	libusb_close(devh);
detach_error:
open_dev_error:
not_found_error:
	libusb_free_device_list(list, count);
list_error:
	libusb_exit(NULL);
error:
	exit(1);
}

int mlbin_free_usb(void)
{
	libusb_release_interface(devh, 0);
	libusb_close(devh);
	libusb_exit(NULL);
	printf("mlbin exiting\n");
	return 0;
}

int mlbin_fire(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_FIRE, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Fire!\n");
	return 0;
}

int mlbin_move_down(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_DOWN, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Move Down!\n");
	return 0;
}

int mlbin_move_left(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_LEFT, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Move Left!\n");
	return 0;
}

int mlbin_move_right(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_RIGHT, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Move Right!\n");
	return 0;
}

int mlbin_move_up(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_UP, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Move Up!\n");
	return 0;
}

int mlbin_stop(void)
{
	unsigned char data[] = {0x5f, ML_ACTION_STOP, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	printf("Stop!\n");
	return 0;
}

int main(void)
{
	int ret;
	char dir;
	int time;

	mlbin_init_usb();
	mlbin_stop();

	do {
		ret = scanf("%c %d", &dir, &time);
		if (ret != 2)
			continue;

		printf("%c for %d\n", dir, time);
		switch(dir) {
			case 'L':
				mlbin_move_left();
				break;
			case 'R':
				mlbin_move_right();
				break;
			case 'U':
				mlbin_move_up();
				break;
			case 'D':
				mlbin_move_down();
				break;
			case 'F':
				mlbin_fire();
				break;
			default:
				break;
		}
		sleep(time);
		mlbin_stop();
	} while(ret != EOF);

	mlbin_free_usb();

	return 0;
}
