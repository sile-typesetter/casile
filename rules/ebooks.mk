EPUBS := $(call pattern_list,$(EDITIONEDITSOURCES),.epub)

$(EPUBS): private PANDOCFILTERS += --lua-filter=$(CASILEDIR)/pandoc-filters/epubclean.lua
$(EPUBS): %.epub: $(BUILDDIR)/%-$(_processed).md $(BUILDDIR)/%-epub-metadata.yml
	$(PANDOC) \
		$(PANDOCARGS) \
		$(PANDOCFILTERS) \
		$(filter %-epub-metadata.yml,$^) \
		$(filter %-$(_processed).md,$^) -o $@

DISTFILES += $(EPUBS)

$(BUILDDIR)/%-epub-metadata.yml: $$(call parse_bookid,$$*)-manifest.yml %-epub-$(_poster).jpg | $(BUILDDIR)
	echo '---' > $@
	$(YQ) -M -e -y \
		'{	title: [ { type: "main", text: .title  }, { type: "subtitle", text: (.subtitle // empty) } ],
			creator: .creator,
			contributor: .contributor,
			identifier: .identifier,
			date: .date | last | .text,
			published: .date | first | .text,
			lang: .lang,
			description: .abstract,
			rights: .rights,
			publisher: .publisher,
			source: (if .source then (try (.source? | map(select(.type == "title"))[0].text) // empty) else empty end),
			"cover-image": "$(filter %.jpg,$^)"
		}' < $< >> $@
	echo '...' >> $@

MOBIS := $(call pattern_list,$(EDITIONEDITSOURCES),.mobi)

$(MOBIS): %.mobi: %.epub
	$(KINDLEGEN) $< ||:

DISTFILES += $(MOBIS)

PLAYSOURCES := $(foreach ISBN,$(ISBNS),$(call isbntouid,$(ISBN)))
VIRTUALPLAYS := $(call pattern_list,$(PLAYSOURCES),.play)

.PHONY: $(VIRTUALPLAYS)
$(VIRTUALPLAYS): %.play: %_playbooks.csv
$(VIRTUALPLAYS): %.play: $$(call pattern_list,$$(call ebookisbn,$$*),.epub _frontcover.jpg _backcover.jpg)
$(VIRTUALPLAYS): %.play: $$(call pattern_list,$$(call printisbn,$$*),_interior.pdf _frontcover.jpg _backcover.jpg)

PLAYEPUBS := $(call pattern_list,$(ISBNS),.epub)

$(PLAYEPUBS): %.epub: $$(call isbntouid,$$*).epub
	$(EPUBCHECK) $<
	cp $< $@

DISTFILES += $(PLAYEPUBS)

PLAYMETADATAS := $(call pattern_list,$(PLAYSOURCES),_playbooks.csv)
$(PLAYMETADATAS): %_playbooks.csv: $$(addprefix $(BUILDDIR)/,$$(call pattern_list,$$(call ebookisbn,$$*) $$(call printisbn,$$*),_playbooks.json))
$(PLAYMETADATAS): %_playbooks.csv: $(BUILDDIR)/%-bio.html $(BUILDDIR)/%-description.html
$(PLAYMETADATAS): %_playbooks.csv:
$(PLAYMETADATAS): %_playbooks.csv:
	$(JQ) -M -e -s -r \
			--rawfile biohtml $(filter %-bio.html,$^) \
			--rawfile deshtml $(filter %-description.html,$^) \
			'[	"Identifier",
				"Enable for Sale?",
				"Title",
				"Subtitle",
				"Book Format",
				"Related Identifier [Format, Relationship], Semicolon-Separated",
				"Contributor [Role], Semicolon-Separated",
				"Biographical Note",
				"Subject Code [Schema], Semicolon-Separated",
				"Language",
				"Description",
				"Publication Date",
				"Page Count",
				"Series Name",
				"Volume in Series",
				"Buy Link",
				"On Sale Date",
				"TRY [Recommended Retail Price, Including Tax] Price",
				"Countries for TRY [Recommended Retail Price, Including Tax] Price"
			],
			(.[] | .[7] |= $$biohtml | .[10] |= $$deshtml | .[17] |= 0 | .[18] |= "WORLD")
			| map(. // "") | @csv' $(filter %_playbooks.json,$^) > $@

ISBNMETADATAS := $(addprefix $(BUILDDIR)/,$(call pattern_list,$(ISBNS),_playbooks.json))
$(ISBNMETADATAS): $(BUILDDIR)/%_playbooks.json: $$(call pattern_list,$$(call isbntouid,$$*)-,manifest.yml $(firstword $(LAYOUTS)).pdf)
	$(YQ) -M -e '
			([.identifier[] | select(.scheme == "ISBN-13").key] | length) as $$isbncount |
			(.lang | sub("tr"; "tur") | sub("en"; "eng")) as $$lang |
			(.date[] | select(."file-as" == "1\\. Basım").text | strptime("%Y-%m") | strftime("D:%Y-%m-01")) as $$date |
			([.creator[], .contributor[] | select (.role == "author").text + " [Author]", select (.role == "editor").text + " [Editor]", select (.role == "trl").text + " [Translator]"] | join("; ")) as $$contributors |
			(.identifier[] | select(.text == "$*").key) as $$format |
			[   "ISBN:$*",
				(if $$isbncount >= 2 and $$format == "paperback" then "No" else "Yes" end),
				.title,
				(.subtitle // empty),
				(if $$format == "paperback" then "Paperback" else "Digital" end),
				(if $$isbncount >= 2 then (.identifier[] | select(.key != $$format and .scheme == "ISBN-13") |
					(if .key == "ebook" then "ISBN:"+.text+" [Digital, Electronic version available as]" else "ISBN:"+.text+" [Paperback, Epublication based on]" end)) else "" end),
				$$contributors,
				"",
				([ .subjectcodes[] | .text + " [" + ."file-as" + "]" ] | join("; ")),
				$$lang,
				"",
				$$date,
				$(call pagecount,$(filter %.pdf,$^)),
				.seriestitle,
				(.seriestitle and .title as $$title | .seriestitles[] | select(.title == $$title).order),
				"$(call urlinfo,$(call isbntouid,$*))",
				$$date
			]' $(filter %-manifest.yml,$^) > $@

DISTFILES += $(PLAYMETADATAS)

PLAYFRONTS := $(call pattern_list,$(ISBNS),_frontcover.jpg)
$(PLAYFRONTS): %_frontcover.jpg: $(BUILDDIR)/$$(call isbntouid,$$*)-epub-$(_poster).jpg
	cp $< $@

DISTFILES += $(PLAYFRONTS)

PLAYBACKS := $(call pattern_list,$(ISBNS),_backcover.jpg)
$(PLAYBACKS): %_backcover.jpg: %_frontcover.jpg
	cp $< $@

DISTFILES += $(PLAYBACKS)

PLAYINTS := $(call pattern_list,$(ISBNS),_interior.pdf)
$(PLAYINTS): %_interior.pdf: $$(call isbntouid,$$*)-$(firstword $(LAYOUTS))-$(_cropped).pdf
	$(PDFTK) $< cat 2-end output $@

DISTFILES += $(PLAYINTS)
