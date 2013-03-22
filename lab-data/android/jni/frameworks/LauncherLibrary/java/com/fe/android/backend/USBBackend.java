package com.fe.android.backend;

public class USBBackend implements MissileBackendImpl {
	public final String TAG = getClass().getSimpleName();

	public int fire() {
		return 1;
	}

	public int stop() {
		return 1;
	}

	public void move(Direction dir) {
		return;
	}
}
