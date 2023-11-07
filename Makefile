SHELL := /bin/bash

define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

ISDEBIAN := $(shell awk '/^NAME=.*[Dd]ebian/ { print "Yes" }' /etc/*release*)

all: 
	@echo "usage:  make <make | install | start | stop>"
	@echo "     make - build files"
	@echo "     install - install files to designated folder"
	@echo "     start - start gitfiler and dropbear"
	@echo "     stop - stop gitfiler and dropbear"


ifneq ($(ISDEBIAN),Yes)
	$(error Debian is required to build)
endif

make: tmp/settings build
	cp -R templates build
	cp -R assets build
	m4 -DLOCALPATH="$(call getsetting,tmp/settings,NEWPATH)" -DWEBPORT="$(call getsetting,tmp/settings,WEBPORT)" gitfiler.py.m4 > build/gitfiler.py
	m4 -DBASEPATH="$(call getsetting,tmp/settings,NEWPATH)" -DSSHPORT="$(call getsetting,tmp/settings,SSHPORT)" filelist.html.m4 > build/templates/filelist.html
	m4 -DSSHPORT="$(call getsetting,tmp/settings,SSHPORT)" dropbear-run.m4 > build/run
	@[[ -f /.dockerenv ]] && make install || echo "Skipping docker procedure"

tmp/settings: tmp
	$(call newsetting,Enter local path (where repositories are),NEWPATH,/tmp,tmp/settings)
	$(call newsetting,Enter web port,WEBPORT,8080,tmp/settings)
	$(call newsetting,Enter SSH port,SSHPORT,22,tmp/settings)
	$(call newsetting,Enter install path,INSTPATH,/opt/gitfiler,tmp/settings)

install:
	apt-get update
	apt-get install dropbear
	mkdir -p $(call getsetting,tmp/settings,INSTPATH)
	cp -R build/* $(call getsetting,tmp/settings,INSTPATH)
	cp /etc/dropbear/run /etc/dropbear/run.ORIG
	mv $(call getsetting,tmp/settings,INSTPATH)/run /etc/dropbear/run
	chmod +x /etc/dropbear/run
	chmod +x $(call getsetting,tmp/settings,INSTPATH)/start
	chmod +x $(call getsetting,tmp/settings,INSTPATH)/stop
	@[[ -f /.dockerenv ]] && make start || echo "Skipping docker procedure"

start:
	@/etc/dropbear/run
	$(call getsetting,tmp/settings,INSTPATH)/start

stop:
	$(call getsetting,tmp/settings,INSTPATH)/stop
	kill -9 $(cat /etc/dropbear/dropbear.PID)
	rm /etc/dropbear/dropbear.PID
	
tmp:
	mkdir tmp

build:
	mkdir build

clean:
	rm -rf build
	rm -rf tmp
