
xml2rfc ?= xml2rfc
mmark ?= mmark -xml2 -page
kramdown-rfc2629 ?= kramdown-rfc2629

ifneq (,$(XML_LIBRARY))
  mmark += -bib-id $(XML_LIBRARY)/ -bib-rfc $(XML_LIBRARY)/
endif

DRAFT = draft-uberti-avtcore-cryptex

ifeq (,$(VERSION))
	VERSION = latest
endif

.PHONY: all clean all
.PRECIOUS: %.xml

all:  $(DRAFT)-$(VERSION).txt $(DRAFT)-$(VERSION).html 

clean:
	-rm $(DRAFT)-??.txt $(DRAFT)-??.html $(DRAFT)-??.xml
	-rm $(DRAFT)-$(VERSION).txt $(DRAFT)-$(VERSION).html $(DRAFT)-$(VERSION).xml

%.txt: %.xml 
	$(xml2rfc) $< -o $@ --text

%.html: %.xml 
	$(xml2rfc) $< -o $@ --html

$(DRAFT)-$(VERSION).xml: $(DRAFT).md
	$(kramdown-rfc2629) $< > $@
