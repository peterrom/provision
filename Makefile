all: general wm other

# general packages and tools
.apt-repositories:
	sudo add-apt-repository ppa:ubuntu-elisp/ppa
	sudo apt-get update
	touch $@

.apt-packages: .apt-repositories
	sudo apt-get install -y \
		git \
		build-essential \
		glibc-doc \
		emacs-snapshot \
		silversearcher-ag \
		net-tools \
		python3.6 \
		python3.6-venv
	touch $@

~/.emacs.d:
	mkdir $@

~/.emacs.d/init.el: | ~/.emacs.d
	ln -s init.el $@

.PHONY: general
general: ~/.emacs.d/init.el

# dwm as window manager
dwm: .apt-packages
	git clone --depth 1 http://git.suckless.org/dwm $@

dmenu: .apt-packages
	git clone --depth 1 http://git.suckless.org/dmenu $@

.dwm-packages:
	sudo apt-get install -y \
		libx11-dev \
		libxft-dev \
		libxinerama-dev
	touch $@

.dwm-install: dwm-config.h .dwm-packages | dwm
	cp $< dwm/config.h
	sudo make -C dwm install
	touch $@

dwmrunner: dwmrunner.c
	$(CC) -o $@ $< -lX11

/usr/local/bin/dwmrunner: dwmrunner
	sudo cp $< $@

/usr/share/xsessions/dwm.desktop: dwm.desktop .dwm-install /usr/local/bin/dwmrunner
	sudo cp $< $@

.dmenu-install: | dmenu
	sudo make -C dmenu install
	touch $@

.PHONY: wm
wm: /usr/share/xsessions/dwm.desktop .dmenu-install

# other settings
.switch-apple-func-keys-mode:
	echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
	sudo update-initramfs -u -k all
	touch $@

/etc/xorg.conf: xorg.conf
	sudo cp $< $@

.PHONY: other
other: .switch-apple-func-keys-mode /etc/xorg.conf
