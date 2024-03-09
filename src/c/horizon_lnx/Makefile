SUBDIRS := $(wildcard */.)
all:
	@for i in $(SUBDIRS); do \
		echo "make all in $$i..."; \
		(cd $$i; $(MAKE) all); done

		
clean:
	@for i in $(SUBDIRS); do \
		echo "make clean in $$i..."; \
		(cd $$i; $(MAKE) clean); done
		
