MDBOOKS := $(call pattern_list,$(SOURCES),.mdbook)
$(MDBOOKS): %.mdbook: $(BUILDDIR)/%.mdbook/src/SUMMARY.md $(BUILDDIR)/%.mdbook/book.toml
	$(MDBOOK) build $(<D)/.. --dest-dir ../../$@

DISTDIRS += $(MDBOOKS)

$(BUILDDIR)/%.mdbook/src/SUMMARY.md: $(BUILDDIR)/%-$(_processed).md
	mkdir -p $(@D)
	split_mdbook_src.zsh $< $(@D) > $@

$(BUILDDIR)/%.mdbook/book.toml: %-manifest.yml
	mkdir -p $(@D)
	$(YQ) -t '{"book": {
			"title": .title,
			"author": .creator[] | select(.role == "author") | .text,
			"language": .lang
		}}' $< > $@
