package com.fe.android.backend;

import android.util.Log;

public class DummyBackend implements MissileBackendImpl {
	public final String TAG = getClass().getSimpleName();

	public int fire() {
		Log.i(TAG, "FIRE!");

		return 0;
	}

	public void move(Direction dir) {
		Log.i(TAG, "MOVE to " + dir);
	}

	public int stop() {
		Log.i(TAG, "Stop");

		return 0;
	}

}
