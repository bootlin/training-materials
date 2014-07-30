#include <curses.h>
#include <stdlib.h>
#include <time.h>

int main(void)
{
	WINDOW * mainwin;
	int ch, x, y, mx, my, tx, ty;
	int won = 0;

	srand(time(NULL));

	/*  Initialize ncurses  */
	mainwin = initscr();
	if (mainwin == NULL) {
		fprintf(stderr, "Error initializing ncurses.\n");
		exit(EXIT_FAILURE);
	}

	noecho();					/*  Turn off key echoing                 */
	keypad(mainwin, TRUE);		/*  Enable the keypad for non-char keys  */
	curs_set(0);				/* Turn off cursor */

	getmaxyx(mainwin, mx, my);
	mx--;
	my--;

	x = mx / 2;
	y = my / 2;
	tx = rand() % mx;	/* Never do that, distribution is not uniform */
	ty = rand() % my;	/* Never do that, distribution is not uniform */

	mvaddstr(0, my / 2 - 6, "Hello World!");
	mvaddstr(mx, 0, "Move to the target (X), 'q' to quit");
	mvprintw(x, y, "O");
	mvprintw(tx, ty, "X");
	move(mx, my); /* In case the cursor can't be turned off */
	refresh();

	/*  Loop until user presses 'q'  */
	while ((ch = getch()) != 'q') {
		if (won)
			continue;

		mvaddch(x, y, ' ');
		switch(ch) {
			case KEY_DOWN:
				ch = 'v';
				x++;
				break;
			case KEY_LEFT:
				ch = '<';
				y--;
				break;
			case KEY_RIGHT:
				ch = '>';
				y++;
				break;
			case KEY_UP:
				ch = '^';
				x--;
				break;
		}

		if (x < 1)
			x = 1;
		if (x > mx - 1)
			x = mx - 1;
		if (y < 0)
			y = 0;
		if (y > my)
			y = my;
		mvaddch(x, y, ch);

		if ((x == tx) && (y == ty))
		{
			mvaddch(x, y, ' ');
			mvprintw(mx / 2, my / 2 - 4, "You won!");
			won = 1;
		}
		move(mx, my); /* In case the cursor can't be turned off */
		refresh();
	}

	/* Clean */
	delwin(mainwin);
	endwin();
	refresh();

	return EXIT_SUCCESS;
}
