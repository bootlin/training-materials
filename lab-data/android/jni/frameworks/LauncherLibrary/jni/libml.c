#include <jni.h>
#include <stdio.h>
#include <stdlib.h>

#include <libusb.h>

#include <utils/Log.h>

#define LOG_TAG			"LIBML_JNI"

#define ML_VENDOR_ID		0x0416
#define ML_DEVICE_ID		0x9391

#define ML_ACTION_STOP		0x0
#define ML_ACTION_MOVE_DOWN	0x1
#define ML_ACTION_MOVE_UP	0x2
#define ML_ACTION_MOVE_RIGHT	0x4
#define ML_ACTION_MOVE_LEFT	0x8
#define ML_ACTION_FIRE		0x10

static struct libusb_device_handle *devh;

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_initUSB(JNIEnv *env, jobject this)
{
	libusb_device **list;
	libusb_device *device = NULL;
	int count, ret, i;

	LOGD("Calling initUSB\n");

	ret = libusb_init(NULL);

	if(ret < 0) {
		LOGE("Couldn't initialize libusb.\n");
		goto error;
	}

	count = libusb_get_device_list(NULL, &list);
	if (count < 0) {
		LOGE("Couldn't get device list\n");
		goto list_error;
	}

	for (i = 0; i < count; i++) {
		struct libusb_device_descriptor desc;
		device = list[i];
		libusb_get_device_descriptor(device, &desc);
		LOGD("Found a new device : %x:%x\n",
			desc.idVendor, desc.idProduct);
		if (desc.idVendor == ML_VENDOR_ID &&
			desc.idProduct == ML_DEVICE_ID)
			break;
		device = NULL;
	}

	if (!device) {
		LOGE("Couldn't find the device\n");
		goto not_found_error;
	}

	ret = libusb_open(device, &devh);
	if (ret) {
		LOGE("Couldn't open device: %d\n", ret);
		goto open_dev_error;
	}

	ret = libusb_detach_kernel_driver(devh, 0);
	if (ret) {
		LOGE("Couldn't detach kernel driver: %d\n", ret);
	}

	ret = libusb_claim_interface(devh, 0);
	if(ret < 0) {
		LOGE("Couldn't claim the interface : %d.\n", ret);
		goto if_error;
	}

	libusb_free_device_list(list, count);

	LOGI("Interface setup.\n");
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

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_freeUSB(JNIEnv *env, jobject this)
{
	libusb_release_interface(devh, 0);
	libusb_close(devh);
	libusb_exit(NULL);
	LOGI("FreeUSB exiting");
	return 0;
}

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_fire(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_FIRE, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Fire!\n");
	return 0;
}

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_moveDown(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_DOWN, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Move Down!\n");
	return 0;
}

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_moveLeft(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_LEFT, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Move Left!\n");
	return 0;
}

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_moveRight(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_RIGHT, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Move Right!\n");
	return 0;
}

JNIEXPORT jint JNICALL Java_com_fe_android_backend_USBBackend_moveUp(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_MOVE_UP, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Move Up!\n");
	return 0;
}

JNIEXPORT jboolean JNICALL Java_com_fe_android_backend_USBBackend_stop(JNIEnv *env, jobject this)
{
	unsigned char data[] = {0x5f, ML_ACTION_STOP, 0xe0, 0xff, 0xfe};
	libusb_control_transfer(devh, 0x21, 0x09, 0, 0, data, 5, 300);

	LOGD("Stop!\n");
	return 0;
}
