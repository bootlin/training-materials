package com.fe.android.backend;

import android.util.Log;

public class USBBackend implements MissileBackendImpl {
	static {
		System.loadLibrary("launcher_jni");
	}

	public native void fire();

	private native int freeUSB();
	private native int initUSB();
	private native int moveDown();
	private native int moveLeft();
	private native int moveRight();
	private native int moveUp();
	public native void stop();

	public USBBackend() {
		initUSB();
	}

	public void finalize() {
		freeUSB();
	}

	public void move(Direction dir) {
		System.out.println("move");
		switch(dir) {
		case DOWN:
			moveDown();
			break;
		case LEFT:
			moveLeft();
			break;
		case RIGHT:
			moveRight();
			break;
		case UP:
			moveUp();
			break;
		}
		try {
			Thread.sleep(1000);
		} catch (Exception e) {
			return;
		}
	}
}
