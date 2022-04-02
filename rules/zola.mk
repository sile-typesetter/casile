VIRTUALWEBS := $(call pattern_list,$(SOURCES),.web)

.PHONY: $(VIRTUALWEBS)
$(VIRTUALWEBS): %.web: %-manifest.yml %.promotionals %.renderings %.mdbook

# Unlike most other rules, the static site stuff doesn't depend on much being generated, it mostly looks what *has been* generated and goes from there
list_extant_resources = $(filter $1%,$(filter-out $1.static,$(wildcard $(DISTFILES) $(DISTDIRS))))

STATICS := $(call pattern_list,$(SOURCES),.static)
$(STATICS): %.static: $(addprefix $(BUILDDIR)/%.static/,config.toml content/_index.md templates/index.html sass/style.sass) %-epub-$(_poster).jpg $$(call list_extant_resources,$$*) | $(BUILDDIR)
	:
	local resourcedir="$(<D)/static"
	rm -rf "$$resourcedir"
	mkdir -p "$$resourcedir"
	$(and $(filter $*%,$^),cp -a $(filter $*%,$^) "$$resourcedir")
	$(and $(filter $*.mdbook,$^),mv $$resourcedir/$*.mdbook $$resourcedir/$(_read))
	rm -rf $@
	$(ZOLA) -r "$(<D)" build -o "$@"

DISTDIRS += $(STATICS)

$(BUILDDIR)/%.static/content/_index.md: %-manifest.yml %-epub-$(_poster).jpg $$(call list_extant_resources,$$*) | $(BUILDDIR)
	mkdir -p $(@D)
	$(ZSH) << 'EOF' # inception to break out of CaSILE’s make shell wrapper
	exec > $@ # grey magic to capture output
	echo "+++"
	$(YQ) -t "{
			\"slug\": \"$*\",
			\"extra\": { \"coverimg\": \"$(firstword $(filter $(call pattern_list,$*,$(LAYOUTS),$(_3b)-$(_on).png),$^) $*-epub-$(_poster).jpg)\" }
		}" $<
	echo "+++"
	$(YQ) -r '.abstract | if . == null then "" else . end' $<
	$(and $(filter $*.mdbook,$^),echo "- [Online oku]($(_read))")
	$(and $(filter $*.epub,$^),echo "- EPUB olarak indir: [epub]($*.epub)")
	$(and $(filter $*.mobi,$^),echo "- MOBI olarak indir: [mobi]($*.mobi)")
	for pdf in $(filter $(call pattern_list,$*,$(LAYOUTS),.pdf),$^); do
		echo "- PDF olarak indir: [$${$${pdf$(hash)$*-}%.pdf}]($$pdf)"
	done
	EOF

$(BUILDDIR)/%.static/templates/index.html: $(ZOLA_TEMPLATE) | $(BUILDDIR)
	mkdir -p $(@D)
	cp $< $@

$(BUILDDIR)/%.static/sass/style.sass: $(ZOLA_STYLE) | $(BUILDDIR)
	mkdir -p $(@D)
	cp $< $@

$(BUILDDIR)/%.static/config.toml: %-manifest.yml | $(BUILDDIR)
	mkdir -p $(@D)
	$(YQ) -t '{
			"title": .title,
			"base_url": "$(call urlinfo,$*)",
			"compile_sass": true
		}' $< > $@

