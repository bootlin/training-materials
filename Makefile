# See the README file for usage instructions

# SELF_CALL avoids checking other instances, which fails with --jobs > 1.
# https://gitlab.com/inkscape/inkscape/-/issues/4716#note_1898150983
INKSCAPE = SELF_CALL=true inkscape
PDFLATEX = xelatex
DIA      = dia
EPSTOPDF = epstopdf

INKSCAPE_IS_NEW = $(shell $(INKSCAPE) --version | grep -q "^Inkscape 1" && echo YES)

ifeq ($(INKSCAPE_IS_NEW),YES)
INKSCAPE_PDF_OPT = -o
else
INKSCAPE_PDF_OPT = -A
endif

# Needed macros
UPPERCASE = $(shell echo $1 | tr "[:lower:]-" "[:upper:]_")

define sep


endef

include $(wildcard mk/*.mk)

# Output directory
OUTDIR   = $(shell pwd)/out

# Latex variable definitions
VARS = $(OUTDIR)/vars

# Environment for pdflatex, which allows it to find the stylesheet in the
# common/ directory.
PDFLATEX_ENV = TEXINPUTS=.:$(shell pwd):$(shell pwd)/common: texfot --tee /tmp/fot.`id -u`

# Arguments passed to pdflatex
PDFLATEX_OPT = -shell-escape -file-line-error -halt-on-error

# The common slide stylesheet
STYLESHEET = common/beamerthemeBootlin.sty

#
# === Picture lookup ===
#

# Function that computes the list of pictures of the extension given
# in $(2) from the directories in $(1), and transforms the filenames
# in .pdf in the output directory. This is used to compute the list of
# .pdf files that need to be generated from .dia or .svg files.
PICTURES_WITH_TRANSFORMATION = \
	$(patsubst %.$(2),$(OUTDIR)/%.pdf,$(foreach s,$(1),$(wildcard $(s)/*.$(2))))

# Function that computes the list of pictures of the extension given
# in $(2) from the directories in $(1). This is used for pictures that
# to not need any transformation, such as bitmap files in the .png or
# .jpg formats.
PICTURES_NO_TRANSFORMATION = \
	$(patsubst %,$(OUTDIR)/%,$(foreach s,$(1),$(wildcard $(s)/*.$(2))))

# Function that computes the list of pictures from the directories in
# $(1) and returns output filenames in the output directory.
PICTURES = \
	$(call PICTURES_WITH_TRANSFORMATION,$(1),svg) \
	$(call PICTURES_WITH_TRANSFORMATION,$(1),dia) \
	$(call PICTURES_NO_TRANSFORMATION,$(1),png)   \
	$(call PICTURES_NO_TRANSFORMATION,$(1),jpg)   \
	$(call PICTURES_NO_TRANSFORMATION,$(1),pdf)

# List of common pictures
COMMON_PICTURES   = $(call PICTURES,common)

default: help

# List of all supported boards among all trainings.
# /!\ You need to update this variable when you support a new board in any
# training
BOARD_SUFFIXES = \
		 -native \
		 -bbb \
		 -beagleplay \
		 -espressobin \
		 -imx93-frdm \
		 -qemu \
		 -stm32mp1 \
		 -stm32mp2

#
# === Compilation of slides ===
#

# This rule allows to build slides of the training. It is done in two
# parts with make calling itself because it is not possible to compute
# a list of prerequisites depending on the target name. See
# https://stackoverflow.com/questions/3381497/dynamic-targets-in-makefiles
# for details.
#
# The value of slide can be "full-kernel", "full-sysdev" (for the
# complete trainings) or the name of an individual chapter.
ifdef SLIDES
# Compute the set of chapters to build depending on the name of the
# PDF file that was requested.
ifeq ($(firstword $(subst -, , $(SLIDES))),full)
SLIDES_TRAINING      = $(strip $(subst -slides, , $(subst full-, , $(SLIDES))))
SLIDES_COMMON_BEFORE = common/slide-header.tex \
		       common/$(SLIDES_TRAINING)-title.tex
SLIDES_CHAPTERS      = $($(call UPPERCASE, $(subst  -,_, $(SLIDES_TRAINING)))_SLIDES)
SLIDES_COMMON_AFTER  = common/slide-footer.tex
else
SLIDES_TRAINING      = $(firstword $(subst -, ,  $(SLIDES)))
ifeq ($(SLIDES_TRAINING),sysdev)
SLIDES_TRAINING = embedded-linux
endif
# We might be building multiple chapters that share a common
# prefix. In this case, we want to build them in the order they are
# listed in the <training>_SLIDES variable that corresponds to the
# current training, as identified by the first component of the
# chapter name.
SLIDES_CHAPTERS      = $(filter $(SLIDES)%, $($(call UPPERCASE, $(SLIDES_TRAINING))_SLIDES))
ifeq ($(words $(SLIDES_CHAPTERS)),1)
SLIDES_COMMON_BEFORE = common/slide-header.tex common/single-subsection-slide-title.tex
else
SLIDES_COMMON_BEFORE = common/slide-header.tex common/single-slide-title.tex
endif
SLIDES_COMMON_AFTER  = common/slide-footer.tex
endif

TRAINING = $(SLIDES_TRAINING)

TRAINING_TYPE = $(TRAINING)
$(foreach s,$(BOARD_SUFFIXES),$(eval TRAINING_TYPE := $(subst $(s),,$(TRAINING_TYPE))))
BOARD_TYPE = $(strip $(subst $(TRAINING_TYPE)-,,$(TRAINING)))

ifeq ($(SLIDES_CHAPTERS),)
$(error "No chapter to build, maybe you're building a single chapter whose name doesn't start with a training session name")
endif

# Compute the set of corresponding .tex files and pictures
SLIDES_TEX      = \
	$(SLIDES_COMMON_BEFORE) \
	$(foreach s,$(SLIDES_CHAPTERS),$(wildcard slides/$(s)/$(s).tex)) \
	$(SLIDES_COMMON_AFTER)
SLIDES_PICTURES = $(call PICTURES,$(foreach s,$(SLIDES_CHAPTERS),slides/$(s))) $(COMMON_PICTURES)

# Check for all slides .tex file to exist
$(foreach file,$(SLIDES_TEX),$(if $(wildcard $(file)),,$(error Missing file $(file) !)))

%-slides.pdf: $(VARS) $(SLIDES_TEX) $(SLIDES_PICTURES) $(STYLESHEET) $(OUTDIR)/last-update.tex
	@mkdir -p $(OUTDIR)
# We generate a .tex file with \input{} directives (instead of just
# concatenating all files) so that when there is an error, we are
# pointed at the right original file and the right line in that file.
	rm -f $(OUTDIR)/$(basename $@).tex
	echo "\input{last-update}" >> $(OUTDIR)/$(basename $@).tex
	echo "\input{$(VARS)}" >> $(OUTDIR)/$(basename $@).tex
	for f in $(filter %.tex,$^) ; do \
		cp $$f $(OUTDIR)/`basename $$f` ; \
		sed -i 's%__SESSION_NAME__%$(SLIDES_TRAINING)%' $(OUTDIR)/`basename $$f` ; \
		printf "\input{%s}\n" `basename $$f .tex` >> $(OUTDIR)/$(basename $@).tex ; \
	done
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(PDFLATEX_OPT) $(basename $@).tex)
# The second call to pdflatex is to be sure that we have a correct table of
# content and index
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(PDFLATEX_OPT) $(basename $@).tex > /dev/null 2>&1)
# We use cat to overwrite the final destination file instead of mv, so
# that evince notices that the file has changed and automatically
# reloads it (which doesn't happen if we use mv here). This is called
# 'Maxime's feature'.
	cat out/$@ > $@
else
FORCE:
%-slides.pdf: FORCE
	@$(MAKE) $@ SLIDES=$*
endif

#
# === Compilation of labs ===
#

ifdef LABS
ifeq ($(firstword $(subst -, , $(LABS))),full)
LABS_TRAINING      = $(strip $(subst -labs, , $(subst full-, , $(LABS))))
LABS_HEADER        = common/labs-header.tex
LABS_VARSFILE      = common/$(LABS_TRAINING)-labs-vars.tex
LABS_CHAPTERS      = $($(call UPPERCASE, $(subst  -,_, $(LABS_TRAINING)))_LABS)
LABS_FOOTER        = common/labs-footer.tex
else
LABS_TRAINING      = $(firstword $(subst -, , $(LABS)))
LABS_VARSFILE      = common/single-lab-vars.tex
LABS_CHAPTERS      = $(LABS)
LABS_HEADER        = common/single-lab-header.tex
LABS_FOOTER        = common/labs-footer.tex
endif

TRAINING           = $(LABS_TRAINING)

TRAINING_TYPE = $(TRAINING)
$(foreach s,$(BOARD_SUFFIXES),$(eval TRAINING_TYPE := $(subst $(s),,$(TRAINING_TYPE))))
BOARD_TYPE = $(strip $(subst $(TRAINING_TYPE)-,,$(TRAINING)))

# Compute the set of corresponding .tex files and pictures
LABS_TEX      = \
	$(LABS_VARSFILE) \
	$(LABS_HEADER) \
	$(foreach s,$(LABS_CHAPTERS),$(wildcard labs/$(s)/$(s).tex)) \
	$(LABS_FOOTER)
LABS_PICTURES = $(call PICTURES,$(foreach s,$(LABS_CHAPTERS),labs/$(s))) $(COMMON_PICTURES)


# Check for all labs .tex file to exist
$(foreach file,$(LABS_TEX),$(if $(wildcard $(file)),,$(error Missing file $(file) !)))

%-labs.pdf: common/labs.sty $(VARS) $(LABS_TEX) $(LABS_PICTURES) $(OUTDIR)/last-update.tex
	@mkdir -p $(OUTDIR)
# We generate a .tex file with \input{} directives (instead of just
# concatenating all files) so that when there is an error, we are
# pointed at the right original file and the right line in that file.
	rm -f $(OUTDIR)/$(basename $@).tex
	echo "\input{last-update}" >> $(OUTDIR)/$(basename $@).tex
	echo "\input{$(VARS)}" >> $(OUTDIR)/$(basename $@).tex
	for f in $(filter %.tex,$^) ; do \
		cp $$f $(OUTDIR)/`basename $$f` ; \
		sed -i 's%__SESSION_NAME__%$(LABS_TRAINING)%' $(OUTDIR)/`basename $$f` ; \
		printf "\input{%s}\n" `basename $$f .tex` >> $(OUTDIR)/$(basename $@).tex ; \
	done
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(basename $@).tex)
# The second call to pdflatex is to be sure that we have a correct table of
# content and index
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(basename $@).tex > /dev/null 2>&1)
# We use cat to overwrite the final destination file instead of mv, so
# that evince notices that the file has changed and automatically
# reloads it (which doesn't happen if we use mv here). This is called
# 'Maxime's feature'.
	cat out/$@ > $@
else
FORCE:
%-labs.pdf: FORCE
	@$(MAKE) $@ LABS=$*
endif

#
# Lab data archive generation
#

%-labs.tar.xz: LAB_DATA=$(patsubst %-labs.tar.xz,%,$@)
%-labs.tar.xz: OUT_LAB_DATA=$(OUTDIR)/$(LAB_DATA)-labs
%-labs.tar.xz:
	rm -rf $(OUT_LAB_DATA)
	mkdir -p $(OUT_LAB_DATA)
	rsync --exclude=.git -a -k --delete --copy-links lab-data/$(LAB_DATA)/ $(OUT_LAB_DATA)
	fakeroot common/process-lab-data.sh $(OUT_LAB_DATA)
	find $(OUT_LAB_DATA) -name '*.xz' -exec unxz {} \;
	(cd $(OUTDIR); tar Jcf $@ $(LAB_DATA)-labs)
	mv $(OUTDIR)/$@ $@

#
# === Compilation of agendas ===
#
ifdef AGENDA
AGENDA_TEX = agenda/$(AGENDA)-agenda.tex
AGENDA_PICTURES = $(COMMON_PICTURES) $(call PICTURES,agenda)

TRAINING_TYPE = $(AGENDA)
AGENDA_MODIFIERS = -fr -online
$(foreach s,$(AGENDA_MODIFIERS),$(eval TRAINING_TYPE := $(subst $(s),,$(TRAINING_TYPE))))

%-agenda.pdf: common/agenda_old.sty common/agenda.sty $(VARS) $(AGENDA_TEX) $(AGENDA_PICTURES) $(OUTDIR)/last-update.tex
	rm -f $(OUTDIR)/$(basename $@).tex
	echo "\input{$(VARS)}" >> $(OUTDIR)/$(basename $@).tex
	echo "\input{$(filter %-agenda.tex,$^)}" >> $(OUTDIR)/$(basename $@).tex
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(basename $@).tex)
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(basename $@).tex > /dev/null 2>&1)
	cat $(OUTDIR)/$@ > $@
else
FORCE:
%-agenda.pdf: FORCE
	@$(MAKE) $@ AGENDA=$*
endif

#
# === Last update file generation ===
#
$(OUTDIR)/last-update.tex: FORCE
	mkdir -p $(@D)
	t=`git log -1 --format=%ct` && printf "\def \lastupdateen{%s}\n" "`(LANG=en_EN.UTF-8 date -d @$${t} +'%B %d, %Y')`" > $@
	t=`git log -1 --format=%ct` && printf "\def \lastupdatefr{%s}\n" "`(LANG=fr_FR.UTF-8 date -d @$${t} +'%d %B %Y')`" >> $@


#
# === Picture generation ===
#

.PRECIOUS: $(OUTDIR)/%.pdf

$(OUTDIR)/%.pdf: %.svg
	@printf "%-15s%-20s->%20s\n" INKSCAPE $(notdir $^) $(notdir $@)
	@mkdir -p $(dir $@)
ifeq ($(V),)
	$(INKSCAPE) -D $(INKSCAPE_PDF_OPT) $@ $< > /dev/null 2>&1
else
	$(INKSCAPE) -D $(INKSCAPE_PDF_OPT) $@ $<
endif

$(OUTDIR)/%.pdf: $(OUTDIR)/%.eps
	@printf "%-15s%-20s->%20s\n" EPSTOPDF $(notdir $^) $(notdir $@)
	@mkdir -p $(dir $@)
	$(EPSTOPDF) --outfile=$@ $^

.PRECIOUS: $(OUTDIR)/%.eps

$(OUTDIR)/%.eps: %.dia
	@printf "%-15s%-20s->%20s\n" DIA $(notdir $^) $(notdir $@)
	@mkdir -p $(dir $@)
	$(DIA) -e $@ -t eps $^

.PRECIOUS: $(OUTDIR)/%.png

$(OUTDIR)/%.png: %.png
	@mkdir -p $(dir $@)
	@cp $^ $@

.PRECIOUS: $(OUTDIR)/%.jpg

$(OUTDIR)/%.jpg: %.jpg
	mkdir -p $(dir $@)
	@cp $^ $@

$(OUTDIR)/%.pdf: %.pdf
	mkdir -p $(dir $@)
	@cp $^ $@

#
# === Misc targets ===
#

$(VARS): FORCE
	@mkdir -p $(dir $@)
	/bin/echo "\def \sessionurl {$(patsubst %/,%,$(SESSION_URL))}" > $@
	/bin/echo "\def \training {$(TRAINING_TYPE)}" >> $@
	/bin/echo "\def \board {$(BOARD_TYPE)}" >> $@
	/bin/echo "\def \trainer {$(TRAINER)}" >> $@

clean:
	$(RM) -rf $(OUTDIR) *.pdf *-labs *.xz

ALL_TRAININGS_MKS = $(sort $(notdir $(wildcard mk/*.mk)))
ALL_TRAININGS = $(patsubst %.mk,%,$(ALL_TRAININGS_MKS))

ALL_SLIDES = $(foreach p,$(ALL_TRAININGS),$(if $($(call UPPERCASE,$(p)_SLIDES)),full-$(p)-slides.pdf))
ALL_LABS = $(foreach p,$(ALL_TRAININGS),$(foreach b,$(BOARD_SUFFIXES),$(if $($(call UPPERCASE,$(p)$(subst -,_,$(b))_LABS)),full-$(p)$(b)-labs.pdf)))
ALL_AGENDAS = $(patsubst %.tex,%.pdf,$(filter-out %.inc.tex,$(notdir $(wildcard agenda/*.tex))))
ALL_LABS_TARBALLS = $(patsubst %,%-labs.tar.xz,$(filter-out common,$(notdir $(wildcard lab-data/*))))

all: $(ALL_SLIDES) $(ALL_LABS) $(ALL_AGENDAS) $(ALL_LABS_TARBALLS)

list-courses:
	@echo $(ALL_TRAININGS)

.PHONY: $(ALL_TRAININGS)
$(ALL_TRAININGS):
	$(MAKE) \
		$(filter full-$@%,$(ALL_SLIDES)) \
		$(filter full-$@%,$(ALL_LABS)) \
		$(filter $@%,$(ALL_AGENDAS)) \
		$(filter $@%,$(ALL_LABS_TARBALLS))

HELP_FIELD_FORMAT = " %-36s %s\n"

help:
	@echo "Available targets:"
	@echo
	@echo "Slides:"
	$(foreach p,$(ALL_SLIDES),\
		@printf $(sort $(HELP_FIELD_FORMAT)) "$(p)" "Complete slides for the '$(patsubst full-%-slides.pdf,%,$(p))' course"$(sep))
	@echo
	@echo "Labs:"
	$(foreach p,$(ALL_LABS),\
		@printf $(sort $(HELP_FIELD_FORMAT)) "$(p)" "Complete labs for the '$(patsubst full-%-labs.pdf,%,$(p))' course"$(sep))
	@echo
	@echo "Agendas:"
	$(foreach p,$(ALL_AGENDAS),\
		@printf $(sort $(HELP_FIELD_FORMAT)) "$(p)" "Agenda for the '$(patsubst %-agenda.pdf,%,$(p))' course"$(sep))
	@echo
	@echo "Tarballs:"
	$(foreach p,$(ALL_LABS_TARBALLS),\
		@printf $(sort $(HELP_FIELD_FORMAT)) "$(p)" "Lab data for the '$(patsubst %-labs.tar.xz,%,$(p))' course"$(sep))
	@echo
	@printf $(HELP_FIELD_FORMAT) "<some-chapter>-slides.pdf" "Slides for a particular chapter in slides/"
	@printf $(HELP_FIELD_FORMAT) "<some-chapter>-labs.pdf" "Labs for a particular chapter in labs/"
	@echo
	@printf $(HELP_FIELD_FORMAT) "list-courses" "List all courses"
	@printf $(HELP_FIELD_FORMAT) "<course>" "Slides, labs, agendas and tarballs for the course"
	@printf $(HELP_FIELD_FORMAT) "linux-kernel" "Slides, labs, agendas and tarballs for all variants of the course"
