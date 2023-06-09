define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' > $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

all: tmp/settings build
	m4 -DLOCALPATH="$(call getsetting,tmp/settings,NEWPATH)" -DWEBPORT="$(call getsetting,tmp/settings,WEBPORT)" gitfiler.py.m4 > build/gitfiler.py
	cp -R templates build
	m4 -DBASEPATH="$(call getsetting,tmp/settings,GITPATH)" filelist.html.m4 > build/templates/filelist.html

tmp/settings: tmp
	$(call newsetting,Enter local path,NEWPATH,/tmp,tmp/settings)
	$(call newsetting,Enter web port,WEBPORT,8080,tmp/settings)
	$(call newsetting,Enter Git repository path,GITPATH,/repos,tmp/settings)

tmp:
	mkdir tmp

build:
	mkdir build

clean:
	rm -rf build
	rm -rf tmp
