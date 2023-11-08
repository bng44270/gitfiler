SHELL := /bin/bash

define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

ISDEBIAN := $(shell awk '/^NAME=.*[Dd]ebian/ { print "Yes" }' /etc/*release*)

all: tmp/settings build
	cp -R templates build
	cp -R assets build
	m4 -DLOCALPATH="$(call getsetting,tmp/settings,NEWPATH)" -DWEBPORT="$(call getsetting,tmp/settings,WEBPORT)" gitfiler.py.m4 > build/gitfiler.py
	m4 -DBASEPATH="$(call getsetting,tmp/settings,NEWPATH)" -DSSHPORT="$(call getsetting,tmp/settings,SSHPORT)" filelist.html.m4 > build/templates/filelist.html
	m4 -DSSHPORT="$(call getsetting,tmp/settings,SSHPORT)" dropbear-run.m4 > build/run
	@[[ -f /.dockerenv ]] && make install || echo "Skipping docker procedure"

ifneq ($(ISDEBIAN),Yes)
	$(error Debian is required to build)
endif

tmp/settings: tmp
	$(call newsetting,Enter local path (where repositories are),NEWPATH,/tmp,tmp/settings)
	$(call newsetting,Enter web port,WEBPORT,8080,tmp/settings)
	$(call newsetting,Enter SSH port,SSHPORT,22,tmp/settings)
	$(call newsetting,Enter install path,INSTPATH,/opt/gitfiler,tmp/settings)

tmp:
	mkdir tmp

build:
	mkdir build

clean:
	rm -rf build
	rm -rf tmp
