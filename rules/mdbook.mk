MDBOOKS := $(call pattern_list,$(SOURCES),.mdbook)
$(MDBOOKS): %.mdbook: $(BUILDDIR)/%.mdbook/src/SUMMARY.md $(BUILDDIR)/%.mdbook/book.toml
	$(MDBOOK) build $(<D)/.. --dest-dir ../../$@

DISTDIRS += $(MDBOOKS)

$(BUILDDIR)/%.mdbook/src/SUMMARY.md: $(BUILDDIR)/%-$(_processed).md
	$(MKDIR_P) $(@D)
	split_mdbook_src.zsh $< $(@D) > $@

$(BUILDDIR)/%.mdbook/book.toml: %-manifest.yml
	$(MKDIR_P) $(@D)
	$(YQ) -t '{"book": {
			"title": .title,
			"author": (try (.creator[] | select(.role == "author") | .text) catch ""),
			"language": .lang
		}}' $< > $@
