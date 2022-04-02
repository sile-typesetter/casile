$(BUILDDIR)/%-$(_print)-pov-$(_front).png: %-$(_print).pdf $$(geometryfile)
	$(sourcegeometry)
	$(call pagetopng,1)

$(BUILDDIR)/%-$(_print)-pov-$(_back).png: %-$(_print).pdf $$(geometryfile)
	$(sourcegeometry)
	$(call pagetopng,$(call pagecount,$<))

$(BUILDDIR)/%-$(_print)-pov-$(_spine).png: $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) \
		$(MAGICKARGS) \
		-size $${pagewpx}x$${pagehpx} \
		xc:none \
		$@

$(BUILDDIR)/%-pov-$(_front).png: $(BUILDDIR)/%-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) \
		$(MAGICKARGS) \
		$< \
		-gravity East \
		-crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(and $(filter $(_paperback),$(call parse_binding,$@)),$(call magick_crease,0+)) \
		$(call magick_fray) \
		$@

$(BUILDDIR)/%-pov-$(_back).png: $(BUILDDIR)/%-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) \
		$(MAGICKARGS) \
		$< \
		-gravity West -crop $${pagewpx}x$${pagehpx}+$${bleedpx}+0! \
		$(call magick_emulateprint) \
		$(and $(filter $(_paperback),$(call parse_binding,$@)),$(call magick_crease,w-)) \
		$(call magick_fray) \
		$@

$(BUILDDIR)/%-pov-$(_spine).png: $(BUILDDIR)/%-$(_binding)-printcolor.png $$(geometryfile)
	$(sourcegeometry)
	$(MAGICK) \
		$(MAGICKARGS) \
		$< \
		-gravity Center \
		-crop $${spinepx}x$${pagehpx}+0+0! \
		-extent 200%x100% \
		$(call magick_emulateprint) \
		$@

BOOKSCENESINC := $(addprefix $(BUILDDIR)/,$(call pattern_list,$(SOURCES),$(RENDERED),.inc))
$(BOOKSCENESINC): $(BUILDDIR)/%.inc: $$(geometryfile) $(BUILDDIR)/%-pov-$(_front).png $(BUILDDIR)/%-pov-$(_back).png $(BUILDDIR)/%-pov-$(_spine).png
	$(sourcegeometry)
	cat <<- EOF > $@
		#declare FrontImg = "$(filter %-pov-$(_front).png,$^)";
		#declare BackImg = "$(filter %-pov-$(_back).png,$^)";
		#declare SpineImg = "$(filter %-pov-$(_spine).png,$^)";
		#declare BindingType = "$(call unlocalize,$(call parse_binding,$@))";
		#declare StapleCount = $(STAPLECOUNT);
		#declare CoilSpacing = $(COILSPACING);
		#declare CoilWidth = $(COILWIDTH);
		#declare CoilColor = $(COILCOLOR);
		#declare PaperWeight = $(PAPERWEIGHT);
		#declare BookThickness = max($${spinemm} / $${pagewmm} / 2, MinThickness);
		#declare HalfThick = BookThickness / 2;
	EOF

BOOKSCENES := $(addprefix $(BUILDDIR)/,$(call pattern_list,$(SOURCES),$(RENDERED),-$(_3d).pov))
$(BOOKSCENES): $(BUILDDIR)/%-$(_3d).pov: $$(geometryfile) $(BUILDDIR)/%.inc
	$(sourcegeometry)
	cat <<- EOF > $@
		#declare DefaultBook = "$(filter %.inc,$^)";
		#declare Lights = $(call scale,8,2);
		#declare BookAspect = $${pagewmm} / $${pagehmm};
		#declare BookThickness = max($${spinemm} / $${pagewmm} / 2, MinThickness);
		#declare HalfThick = BookThickness / 2;
		#declare toMM = 1 / $${pagehmm};
	EOF

ifneq ($(strip $(SOURCES)),$(strip $(PROJECT)))
SERIESSCENES := $(addprefix $(BUILDDIR)/,$(call pattern_list,$(PROJECT),$(RENDERED),-$(_3d).pov))
$(SERIESSCENES): $(BUILDDIR)/$(PROJECT)-%-$(_3d).pov: $(BUILDDIR)/$(firstword $(SOURCES))-%-$(_3d).pov $(addprefix $(BUILDDIR)/,$(call pattern_list,$(SOURCES),-%.inc))
	cat <<- EOF > $@
		#include "$<"
		#declare BookCount = $(words $(TARGETS));
		#declare Books = array[BookCount] {
		$(subst $(space),$(,)
		,$(foreach INC,$(call series_sort,$(filter %.inc,$^)),"$(INC)")) }
	EOF
endif

$(BUILDDIR)/%-$(_light).png: private SCENELIGHT = rgb<1,1,1>
$(BUILDDIR)/%-$(_dark).png:  private SCENELIGHT = rgb<0,0,0>

$(BUILDDIR)/%-$(_3d)-$(_front)-$(_light).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/front.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/front.pov,$^),$@,$(SCENEX),$(SCENEY))

$(BUILDDIR)/%-$(_3d)-$(_front)-$(_dark).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/front.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/front.pov,$^),$@,$(SCENEX),$(SCENEY))

$(BUILDDIR)/%-$(_3d)-$(_back)-$(_light).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/back.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/back.pov,$^),$@,$(SCENEX),$(SCENEY))

$(BUILDDIR)/%-$(_3d)-$(_back)-$(_dark).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/back.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/back.pov,$^),$@,$(SCENEX),$(SCENEY))

$(BUILDDIR)/%-$(_3d)-$(_pile)-$(_light).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/pile.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/pile.pov,$^),$@,$(SCENEY),$(SCENEX))

$(BUILDDIR)/%-$(_3d)-$(_pile)-$(_dark).png: $(CASILEDIR)/book.pov $(BUILDDIR)/%-$(_3d).pov $(CASILEDIR)/pile.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/pile.pov,$^),$@,$(SCENEY),$(SCENEX))

$(BUILDDIR)/$(PROJECT)-%-$(_3d)-$(_montage)-$(_light).png: $(CASILEDIR)/book.pov $(BUILDDIR)/$(PROJECT)-%-$(_3d).pov $(CASILEDIR)/montage.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/montage.pov,$^),$@,$(SCENEY),$(SCENEX))

$(BUILDDIR)/$(PROJECT)-%-$(_3d)-$(_montage)-$(_dark).png: $(CASILEDIR)/book.pov $(BUILDDIR)/$(PROJECT)-%-$(_3d).pov $(CASILEDIR)/montage.pov
	$(call povray,$(filter %/book.pov,$^),$(filter %-$(_3d).pov,$^),$(filter %/montage.pov,$^),$@,$(SCENEY),$(SCENEX))

# Combine black / white background renderings into transparent one with shadows
%.png: $(BUILDDIR)/%-$(_dark).png $(BUILDDIR)/%-$(_light).png
	$(MAGICK) \
		$(MAGICKARGS) \
		$(filter %.png,$^) \
		-alpha Off \
		\( -clone 0,1 -compose Difference -composite -negate \) \
		\( -clone 0,2 +swap -compose Divide -composite \) \
		-delete 0,1 +swap -compose CopyOpacity -composite \
		-compose Copy -alpha On -layers Flatten +repage \
		-channel Alpha -fx 'a > 0.5 ? 1 : a' -channel All \
		$(call pov_crop,$(if $(findstring $(_pile),$*),$(SCENEY)x$(SCENEX),$(SCENEX)x$(SCENEY))) \
		$@

# Already set to catch other resources
# DISTFILES += *.png

%.jpg: $(BUILDDIR)/%.png
	$(MAGICK) \
		$(MAGICKARGS) \
		$< \
		-background '$(call povtomagick,$(SCENELIGHT))' \
		-alpha Remove \
		-alpha Off \
		-quality 85 \
		$@

%.jpg: %.png
	$(MAGICK) \
		$(MAGICKARGS) \
		$< \
		-background '$(call povtomagick,$(SCENELIGHT))' \
		-alpha Remove \
		-alpha Off \
		-quality 85 \
		$@

# Already set to catch other resources
# DISTFILES += *.jpg
