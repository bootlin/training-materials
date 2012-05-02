package com.fe.android.backend;

import android.util.Log;

public class DummyBackend implements MissileBackendImpl {
	public final String TAG = getClass().getSimpleName();

	public void fire() {
		Log.i(TAG, "FIRE!");
		
	}

	public void move(Direction dir) {
		Log.i(TAG, "MOVE to " + dir);
	}

	public void stop() {
		Log.i(TAG, "Stop");
	}

}
