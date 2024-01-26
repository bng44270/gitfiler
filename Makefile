# Makefile Confuration
TARGET_DIR = build
TMP_DIR = tmp
C_PY_FILE = gitfiler.py.c
C_HTML_FILE = filelist.html.c
H_FILE = $(TMP_DIR)/gitfiler.h
HTML_FILE = $(TARGET_DIR)/templates/filelist.html
PY_FILE = $(TARGET_DIR)/gitfiler.py

SHELL := bash

define newdefine
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) $(3)" >> $(4) || echo "#define $(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

define newdefinestr
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "#define $(2) \"$(3)\"" >> $(4) || echo "#define $(2) \"$$thisset\"" | sed 's/\/$$//g' >> $(4)
endef

define getdefine
$$((cpp -P <<< "$$(cat $(1) ; echo "$(2)")") | sed 's/"//g')
endef

define certkeyval
@(test -n "$(1)" && test -n "$(2)" && test -f $(1) && test -f $(2) && test "$$(openssl rsa -modulus -noout -in $(1))" = "$$(openssl x509 -modulus -noout -in $(2))" && echo "Verified cert/key pair") || (echo "Error verifying cert/key pair"; exit 1)
endef

ISDEBIAN := $(shell awk '/^NAME=.*[Dd]ebian/ { print "Yes" }' /etc/*release*)

all: $(H_FILE) $(TARGET_DIR)
	$(call certkeyval,$(call getdefine,$(H_FILE),KEYFILE),$(call getdefine,$(H_FILE),CERTFILE))
	cp -R templates $(TARGET_DIR)
	cp -R assets $(TARGET_DIR)
	cp $(call getdefine,$(H_FILE),CERTFILE) $(TARGET_DIR)
	cp $(call getdefine,$(H_FILE),KEYFILE) $(TARGET_DIR)
	cpp -P $(C_PY_FILE) > $(PY_FILE)
	cpp -P $(C_HTML_FILE) > $(HTML_FILE)

ifneq ($(ISDEBIAN),Yes)
	$(error Debian is required to build)
endif

$(H_FILE): $(TMP_DIR)
	$(call newdefinestr,Enter local path (where repositories are),LOCALPATH,/tmp,$(H_FILE))
	$(call newdefine,Enter web port,WEBPORT,8443,$(H_FILE))
	$(call newdefinestr,Enter SSH port,SSHPORT,22,$(H_FILE))
	$(call newdefinestr,Enter SSL Key file,KEYFILE,,$(H_FILE))
	$(call newdefinestr,Enter SSL Cert file,CERTFILE,,$(H_FILE))

$(TMP_DIR):
	mkdir $(TMP_DIR)

$(TARGET_DIR):
	mkdir $(TARGET_DIR)

clean:
	rm -rf $(TARGET_DIR)
	rm -rf $(TMP_DIR)
