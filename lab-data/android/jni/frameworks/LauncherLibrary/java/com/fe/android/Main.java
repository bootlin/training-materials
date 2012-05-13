package com.fe.android;

import com.fe.android.backend.USBBackend;
import com.fe.android.backend.MissileBackendImpl;
import com.fe.android.backend.MissileBackendImpl.Direction;

class Main {
	public static void main(String[] args) {
		USBBackend usb = new USBBackend();
		usb.move(Direction.DOWN);	
		usb.fire();
		usb.stop();
	}
}	
