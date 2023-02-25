MDBOOKS := $(call pattern_list,$(SOURCES),.mdbook)
$(MDBOOKS): %.mdbook: $(BUILDDIR)/%.mdbook/src/SUMMARY.md $(BUILDDIR)/%.mdbook/book.toml
	$(MDBOOK) build $(<D)/.. --dest-dir ../../$@

DISTDIRS += $(MDBOOKS)

$(BUILDDIR)/%-mdbook.md: private PANDOCFILTERARGS = --markdown-headings=atx --wrap=none --reference-location=section --to=commonmark_x-smart
$(BUILDDIR)/%-mdbook.md: private PANDOCFILTERS += --lua-filter=$(CASILEDIR)/pandoc-filters/strip_for_mdbook.lua
$(BUILDDIR)/%-mdbook.md: $(BUILDDIR)/%-$(_processed).md
	$(PANDOC) --standalone \
		$(PANDOCARGS) $(PANDOCFILTERS) $(PANDOCFILTERARGS) \
		$(filter %.md,$^) -o $@

$(BUILDDIR)/%.mdbook/src/SUMMARY.md: $(BUILDDIR)/%-mdbook.md
	$(MKDIR_P) $(@D)
	split_mdbook_src.zsh $< $(@D) > $@

$(BUILDDIR)/%.mdbook/book.toml: %-manifest.yml
	$(MKDIR_P) $(@D)
	$(YQ) -t '{"book": {
			"title": .title,
			"author": (try (.creator[] | select(.role == "author") | .text) catch ""),
			"language": .lang
		}}' $< > $@
