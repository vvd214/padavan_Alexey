SRC_NAME=aria2-1.3X.X

COMMON_FLAGS = -ffunction-sections -fdata-sections -fvisibility=hidden
CFLAGS  += $(COMMON_FLAGS)
CXXFLAGS += $(COMMON_FLAGS) -fvisibility-inlines-hidden
LDFLAGS += -Wl,--gc-sections

all: config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	./configure \
		--prefix=/usr \
		--disable-nls \
		--without-libnettle \
		--without-libgmp \
		--without-libgcrypt \
		--without-libexpat \
		--without-libcares \
		--without-libssh2 \
		--without-wintls \
		--without-sqlite3 \
		--without-gnutls \
		--without-libuv \
		--with-libz \
		--with-openssl \
		--with-libxml2 \
		--with-xml-prefix=$(STAGEDIR) \
		--with-libiconv-prefix=$(STAGEDIR) \
		OPENSSL_CFLAGS="-I$(STAGEDIR)/include" \
		OPENSSL_LIBS="-L$(STAGEDIR)/lib -lssl -lcrypto" \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done ariang.zip
	rm -rf ariaweb

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL),y)
	wget -O ariang.zip https://github.com/mayswind/AriaNg/releases/download/1.2.3/AriaNg-1.2.3-AllInOne.zip
	unzip -o ariang.zip -d ariaweb
	rm -f ariaweb/LICENSE
	cp -rf ariaweb $(INSTALLDIR)/www
	cd $(INSTALLDIR)/www/ariaweb && ln -sf /mnt/aria/config/configuration.js configuration.js
endif
	$(ROMFSINST) $(SRC_NAME)/src/aria2c /usr/bin/aria2c
	$(ROMFSINST) -p +x /usr/bin/aria.sh
