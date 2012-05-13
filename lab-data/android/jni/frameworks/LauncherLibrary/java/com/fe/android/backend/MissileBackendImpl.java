package com.fe.android.backend;

public interface MissileBackendImpl
{
	public static enum Direction {
		UP, DOWN, LEFT, RIGHT
	}

	public void fire();
	public void move(Direction dir);
	public void stop();
}
