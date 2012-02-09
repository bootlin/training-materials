# Required packages (tested on Ubuntu 11.10):
# inkscape texlive-latex-base texlive-font-utils dia python-pygments

# Needed tools
INKSCAPE = inkscape
PDFLATEX = pdflatex
DIA      = dia
EPSTOPDF = epstopdf

# List of labs for the different courses
SYSDEV_LABS   = setup \
		sysdev-toolchain \
		sysdev-u-boot \
		sysdev-kernel-fetch-and-patch \
		sysdev-kernel-cross-compiling \
		sysdev-tinysystem \
		sysdev-block-filesystems \
		sysdev-flash-filesystems \
		sysdev-thirdparty \
		sysdev-buildroot \
		sysdev-application-development \
		sysdev-application-debugging \
		sysdev-real-time \
		sysdev-mdev \
		backup
KERNEL_LABS   = setup \
		kernel-sources \
		kernel-module-environment \
		kernel-module-simple \
		kernel-serial-iomem \
		kernel-serial-output \
		kernel-serial-interrupt \
		kernel-locking \
		kernel-debugging \
		kernel-serial-driver \
		kernel-power-management \
		kernel-git \
		backup

# Output directory
OUTDIR   = $(PWD)/out

# Environment for pdflatex, which allows it to find the stylesheet in the
# common/ directory.
PDFLATEX_ENV = TEXINPUTS=.:$(PWD)/common:

# Arguments passed to pdflatex
PDFLATEX_OPT = -shell-escape -file-line-error -halt-on-error

# The common slide stylesheet
STYLESHEET = common/beamerthemeFreeElectrons.sty

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
	$(call PICTURES_NO_TRANSFORMATION,$(1),jpg)

# List of common pictures
COMMON_PICTURES   = $(call PICTURES,common)

default: help

#
# === Compilation of labs ===
#

ifdef LABS
# Compute the set of chapters to build depending on the name of the
# PDF file that was requested.
ifeq ($(LABS),full-kernel)
LABS_VARSFILE      = common/kernel-labs-vars.tex
LABS_CHAPTERS      = $(KERNEL_LABS)
else ifeq ($(LABS),full-sysdev)
LABS_VARSFILE      = common/sysdev-labs-vars.tex
LABS_CHAPTERS      = $(SYSDEV_LABS)
else
LABS_VARSFILE      = common/single-labs-vars.tex
LABS_CHAPTERS      = $(LABS)
endif

# Compute the set of corresponding .tex files and pictures
LABS_TEX      = \
	$(LABS_VARSFILE) \
	common/labs-header.tex \
	$(foreach s,$(LABS_CHAPTERS),$(wildcard labs/$(s)/$(s).tex)) \
	common/labs-footer.tex
LABS_PICTURES = $(call PICTURES,$(foreach s,$(LABS_CHAPTERS),labs/$(s))) $(COMMON_PICTURES)

%-labs.pdf: common/labs.sty $(LABS_TEX) $(LABS_PICTURES)
	@mkdir -p $(OUTDIR)
# We generate a .tex file with \input{} directives (instead of just
# concatenating all files) so that when there is an error, we are
# pointed at the right original file and the right line in that file.
	rm -f $(OUTDIR)/$(basename $@).tex
	for f in $(filter %.tex,$^) ; do \
		echo -n "\input{../"          >> $(OUTDIR)/$(basename $@).tex ; \
		echo -n $$f | sed 's%\.tex%%' >> $(OUTDIR)/$(basename $@).tex ; \
		echo "}"                      >> $(OUTDIR)/$(basename $@).tex ; \
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

#
# === Misc targets ===
#

clean:
	$(RM) -rf $(OUTDIR) *.pdf

help:
	@echo "Available targets:"
	@echo
	@echo " full-sysdev-labs.pdf		Complete labs for the 'sysdev' training"
	@echo " full-kernel-labs.pdf		Complete labs for the 'kernel' training"
	@echo " <some-chapter>-labs.pdf		Labs for a particular chapter in labs/"
	@echo
