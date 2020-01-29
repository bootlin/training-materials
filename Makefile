# See the README file for usage instructions

INKSCAPE = inkscape
PDFLATEX = xelatex
DIA      = dia
EPSTOPDF = epstopdf

# Needed macros
UPPERCASE = $(shell echo $1 | tr "[:lower:]" "[:upper:]")

define sep


endef

include $(wildcard mk/*.mk)

# Output directory
OUTDIR   = $(PWD)/out

# Latex variable definitions
VARS = $(OUTDIR)/vars

# Environment for pdflatex, which allows it to find the stylesheet in the
# common/ directory.
PDFLATEX_ENV = TEXINPUTS=.:$(PWD)/common: texfot

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

#
# === Compilation of slides ===
#

# This rule allows to build slides of the training. It is done in two
# parts with make calling itself because it is not possible to compute
# a list of prerequisites depending on the target name. See
# http://stackoverflow.com/questions/3381497/dynamic-targets-in-makefiles
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
ifeq ($(SLIDES_CHAPTERS),)
$(error "No chapter to build, maybe you're building a single chapter whose name doesn't start with a training session name")
endif

# Compute the set of corresponding .tex files and pictures
SLIDES_TEX      = \
	$(SLIDES_COMMON_BEFORE) \
	$(foreach s,$(SLIDES_CHAPTERS),$(wildcard slides/$(s)/$(s).tex)) \
	$(SLIDES_COMMON_AFTER)
SLIDES_PICTURES = $(call PICTURES,$(foreach s,$(SLIDES_CHAPTERS),slides/$(s))) $(COMMON_PICTURES)

%-slides.pdf: $(VARS) $(SLIDES_TEX) $(SLIDES_PICTURES) $(STYLESHEET)
	@echo $(SLIDES_CHAPTERS_NUM)
	@mkdir -p $(OUTDIR)
# We generate a .tex file with \input{} directives (instead of just
# concatenating all files) so that when there is an error, we are
# pointed at the right original file and the right line in that file.
	rm -f $(OUTDIR)/$(basename $@).tex
	echo "\input{$(VARS)}" >> $(OUTDIR)/$(basename $@).tex
	for f in $(filter %.tex,$^) ; do \
		echo -n "\input{../"          >> $(OUTDIR)/$(basename $@).tex ; \
		echo -n $$f | sed 's%\.tex%%' >> $(OUTDIR)/$(basename $@).tex ; \
		echo "}"                      >> $(OUTDIR)/$(basename $@).tex ; \
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

# Compute the set of corresponding .tex files and pictures
LABS_TEX      = \
	$(LABS_VARSFILE) \
	$(LABS_HEADER) \
	$(foreach s,$(LABS_CHAPTERS),$(wildcard labs/$(s)/$(s).tex)) \
	$(LABS_FOOTER)
LABS_PICTURES = $(call PICTURES,$(foreach s,$(LABS_CHAPTERS),labs/$(s))) $(COMMON_PICTURES)

%-labs.pdf: common/labs.sty $(VARS) $(LABS_TEX) $(LABS_PICTURES)
	@mkdir -p $(OUTDIR)
# We generate a .tex file with \input{} directives (instead of just
# concatenating all files) so that when there is an error, we are
# pointed at the right original file and the right line in that file.
	rm -f $(OUTDIR)/$(basename $@).tex
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
	rsync --exclude=.git -a -k --delete lab-data/$(LAB_DATA)/ $(OUT_LAB_DATA)
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

%-agenda.pdf: common/agenda.sty $(AGENDA_TEX) $(AGENDA_PICTURES)
	rm -f $(OUTDIR)/$(basename $@).tex
	cp $(filter %.tex,$^) $(OUTDIR)/$(basename $@).tex
	(cd $(OUTDIR); $(PDFLATEX_ENV) $(PDFLATEX) $(basename $@).tex)
	cat $(OUTDIR)/$@ > $@
else
FORCE:
%-agenda.pdf: FORCE
	@$(MAKE) $@ AGENDA=$*
endif

#
# === Picture generation ===
#

.PRECIOUS: $(OUTDIR)/%.pdf

$(OUTDIR)/%.pdf: %.svg
	@printf "%-15s%-20s->%20s\n" INKSCAPE $(notdir $^) $(notdir $@)
	@mkdir -p $(dir $@)
ifeq ($(V),)
	$(INKSCAPE) -D -A $@ $< > /dev/null 2>&1
else
	$(INKSCAPE) -D -A $@ $<
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
	/bin/echo "\def \sessionurl {$(SESSION_URL)}" > $@
	/bin/echo "\def \training {$(TRAINING)}" >> $@
	/bin/echo "\def \trainer {$(TRAINER)}" >> $@

clean:
	$(RM) -rf $(OUTDIR) *.pdf *-labs *.xz

ALL_TRAININGS = $(sort $(patsubst %.mk,%,$(notdir $(wildcard mk/*.mk))))

all: $(foreach p,$(ALL_TRAININGS),full-$(p)-slides.pdf full-$(p)-labs.pdf $(p)-agenda.pdf)

list-courses:
	@echo $(ALL_TRAININGS)

HELP_FIELD_FORMAT = " %-34s %s\n"

help:
	@echo "Available targets:"
	@echo
	$(foreach p,$(ALL_TRAININGS),\
		@printf $(HELP_FIELD_FORMAT) "full-$(p)-labs.pdf" "Complete labs for the '$(p)' course"$(sep))
	$(foreach p,$(ALL_TRAININGS),\
		@printf $(HELP_FIELD_FORMAT) "full-$(p)-slides.pdf" "Complete slides for the '$(p)' course"$(sep))
	$(foreach p,$(ALL_TRAININGS),\
		@printf $(HELP_FIELD_FORMAT) "$(p)-agenda.pdf" "Agenda for the '$(p)' course"$(sep))
	$(foreach p,$(ALL_TRAININGS),\
		@printf $(HELP_FIELD_FORMAT) "$(p)-labs.tar.xz" "Lab data for the '$(p)' course"$(sep))
	@echo
	@printf $(HELP_FIELD_FORMAT) "<some-chapter>-slides.pdf" "Slides for a particular chapter in slides/"
	@printf $(HELP_FIELD_FORMAT) "<some-chapter>-labs.pdf" "Labs for a particular chapter in labs/"
	@echo
	@printf $(HELP_FIELD_FORMAT) "list-courses" "List all courses"
