#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>

#include <X11/Xlib.h>

extern char **environ;

static int
fileint(const char *filename)
{
        int fd;
        char buf[16];
        ssize_t sz;

        if ((fd = open(filename, O_RDONLY)) < 0)
                return -1;

        sz = read(fd, buf, sizeof(buf));
        (void) close(fd);

        if (sz < 0 || (size_t) sz >= sizeof(buf))
                return -1;

        buf[sz] = '\0';
        return atoi(buf);
}

static const char *
timestr(void)
{
	time_t now;
	struct tm *ti;
        static char buf[6];

        if ((now = time(NULL)) < 0 ||
            (ti = localtime(&now)) == NULL ||
            snprintf(buf, sizeof(buf), "%02d:%02d", ti->tm_hour, ti->tm_min) < 0)
                return "--:--";

        return buf;
}

static const char *
batstr(void)
{
        int now;
        int full;
        static char buf[5];

        if ((now = fileint("/sys/class/power_supply/BAT0/charge_now")) < 0 ||
            (full = fileint("/sys/class/power_supply/BAT0/charge_full")) < 0 ||
            snprintf(buf, sizeof(buf), "%3d%%", now / (full / 100)) < 0)
                return "---%";

        return buf;
}

static const char *
statusstr(void)
{
        static char buf[64];
        if (snprintf(buf, sizeof(buf), "%s %s", timestr(), batstr()) < 0)
                return "--";

        return buf;
}

static void
status(void)
{
	Display *dpy;

	if ((dpy = XOpenDisplay(NULL)) == NULL)
		exit(EXIT_FAILURE);

        /* Failing Xlib calls will terminate the application through
         * the default error handler */
        (void) XSetWindowBackground(dpy, DefaultRootWindow(dpy), BlackPixel(dpy, DefaultScreen(dpy)));
        (void) XClearWindow(dpy, DefaultRootWindow(dpy));

	for (;;) {
		(void) XStoreName(dpy, DefaultRootWindow(dpy), statusstr());
		(void) XSync(dpy, False);

                /* Ignore early returns */
		(void) sleep(90);
	}

	(void) XCloseDisplay(dpy);
}

static void
rundwm(void)
{
	char *const argv[] = { "/usr/local/bin/dwm", NULL };
	if (execve(argv[0], argv, environ) < 0)
                exit(EXIT_FAILURE);
}

int
main(void)
{
	if (fork() == 0)
		status();
	else
		rundwm();

	return 0;
}
