SHELL := /bin/bash

define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

define certkeyval
@(test -n "$(call getsetting,tmp/settings,KEYFILE)" && test -n "$(call getsetting,tmp/settings,CERTFILE)" && test -f $(call getsetting,tmp/settings,KEYFILE) && test -f $(call getsetting,tmp/settings,CERTFILE) && test "$$(openssl rsa -modulus -noout -in $(call getsetting,tmp/settings,KEYFILE))" = "$$(openssl x509 -modulus -noout -in $(call getsetting,tmp/settings,CERTFILE))" && echo "Verified cert/key pair") || (echo "Error verifying cert/key pair"; exit 1)
endef

ISDEBIAN := $(shell awk '/^NAME=.*[Dd]ebian/ { print "Yes" }' /etc/*release*)

all: tmp/settings build
	$(call certkeyval)
	cp -R templates build
	cp -R assets build
	cp $(call getsetting,tmp/settings,CERTFILE) build
	cp $(call getsetting,tmp/settings,KEYFILE) build
	m4 -DLOCALPATH="$(call getsetting,tmp/settings,NEWPATH)" -DWEBPORT="$(call getsetting,tmp/settings,WEBPORT)" -DCERTFILE="$$(basename $(call getsetting,tmp/settings,CERTFILE))" -DKEYFILE="$$(basename $(call getsetting,tmp/settings,KEYFILE))" gitfiler.py.m4 > build/gitfiler.py
	m4 -DBASEPATH="$(call getsetting,tmp/settings,NEWPATH)" -DSSHPORT="$(call getsetting,tmp/settings,SSHPORT)" filelist.html.m4 > build/templates/filelist.html

ifneq ($(ISDEBIAN),Yes)
	$(error Debian is required to build)
endif

tmp/settings: tmp
	$(call newsetting,Enter local path (where repositories are),NEWPATH,/tmp,tmp/settings)
	$(call newsetting,Enter web port,WEBPORT,8443,tmp/settings)
	$(call newsetting,Enter SSH port,SSHPORT,22,tmp/settings)
	$(call newsetting,Enter SSL Key file,KEYFILE,,tmp/settings)
	$(call newsetting,Enter SSL Cert file,CERTFILE,,tmp/settings)

tmp:
	mkdir tmp

build:
	mkdir build

clean:
	rm -rf build
	rm -rf tmp
