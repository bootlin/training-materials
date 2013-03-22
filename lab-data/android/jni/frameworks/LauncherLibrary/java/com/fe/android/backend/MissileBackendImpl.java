package com.fe.android.backend;

public interface MissileBackendImpl
{
	public static enum Direction {
		UP, DOWN, LEFT, RIGHT
	}

	public int fire();
	public void move(Direction dir);
	public int stop();
}
