# Required packages (tested on Ubuntu 12.04):
# inkscape texlive-latex-base texlive-font-utils dia python-pygments

# Needed tools
INKSCAPE = inkscape
PDFLATEX = pdflatex
DIA      = dia
EPSTOPDF = epstopdf

# Needed macros
UPPERCASE = $(shell echo $1 | tr "[:lower:]" "[:upper:]")

# List of slides for the different courses

KERNEL_SLIDES = \
		licensing \
		about-us \
		course-information-title \
		calao-board \
		course-information \
		kernel-introduction-title \
		sysdev-linux-intro-features \
		sysdev-linux-intro-versioning \
		kernel-introduction-lab \
		kernel-embedded-linux-usage-title \
		sysdev-linux-intro-sources \
		kernel-source-code-title \
		kernel-source-code-drivers \
		kernel-source-code-layout \
		kernel-source-code-management \
		kernel-source-code-lab-source-code \
		sysdev-linux-intro-configuration \
		sysdev-linux-intro-compilation \
		sysdev-linux-intro-cross-compilation \
		kernel-source-code-lab-module \
		sysdev-linux-intro-modules \
		kernel-driver-development-title \
		kernel-driver-development-modules \
		kernel-driver-development-lab-modules \
		kernel-driver-development-memory \
		kernel-driver-development-general-apis \
		kernel-driver-development-io-memory \
		kernel-driver-development-lab-io-memory \
		sysdev-root-filesystem-device-files \
		kernel-driver-development-character-drivers \
		kernel-driver-development-lab-character-drivers \
		kernel-driver-development-processes \
		kernel-driver-development-sleeping \
		kernel-driver-development-interrupts \
		kernel-driver-development-lab-interrupts \
		kernel-driver-development-concurrency \
		kernel-driver-development-lab-locking \
		kernel-driver-development-debugging \
		kernel-driver-development-lab-debugging \
		kernel-driver-development-mmap \
		kernel-driver-development-dma \
		kernel-driver-development-architecture-drivers \
		kernel-serial-drivers-title \
		kernel-serial-drivers-content \
		kernel-serial-drivers-lab \
		kernel-init-title \
		kernel-init-content \
		kernel-porting-title \
		kernel-porting-content \
		kernel-power-management-title \
		kernel-power-management-content \
		kernel-power-management-lab \
		kernel-resources-title \
		kernel-resources-advice \
		kernel-resources-references \
		kernel-git-title \
		kernel-git-content \
		kernel-git-lab \
		last-slides

SYSDEV_SLIDES = \
		licensing \
		about-us \
		course-information-title \
		igepv2-board \
		course-information \
		sysdev-intro \
		sysdev-dev-environment \
		sysdev-toolchains-title \
		sysdev-toolchains-definition \
		sysdev-toolchains-c-libraries \
		sysdev-toolchains-options \
		sysdev-toolchains-obtaining \
		sysdev-toolchains-lab \
		sysdev-bootloaders-title \
		sysdev-bootloaders-sequence \
		sysdev-bootloaders-u-boot \
		sysdev-bootloaders-lab \
		sysdev-linux-intro-title \
		sysdev-linux-intro-features \
		sysdev-linux-intro-versioning \
		sysdev-linux-intro-sources \
		sysdev-linux-intro-lab-sources \
		sysdev-linux-intro-configuration \
		sysdev-linux-intro-compilation \
		sysdev-linux-intro-cross-compilation \
		sysdev-linux-intro-lab-cross-compilation \
		sysdev-linux-intro-modules \
		sysdev-root-filesystem-title \
		sysdev-root-filesystem-principles \
		sysdev-root-filesystem-contents \
		sysdev-root-filesystem-device-files \
		sysdev-root-filesystem-virtual-fs \
		sysdev-root-filesystem-minimal \
		sysdev-busybox \
		sysdev-block-filesystems \
		sysdev-flash-filesystems \
		sysdev-embedded-linux \
		sysdev-application-development \
		sysdev-realtime \
		sysdev-references \
		last-slides

ANDROID_SLIDES = \
		licensing \
		about-us \
		course-information-title \
		devkit8000-board \
		android-linaro-introduction \
		android-course-outline \
		course-information \
		android-introduction-title \
		android-introduction-features \
		android-introduction-history \
		android-introduction-architecture \
		android-introduction-lab \
		android-source-title \
		android-source-obtaining \
		android-source-organization \
		android-source-compilation \
		android-source-contribute \
		android-source-lab \
		sysdev-linux-intro-title \
		sysdev-linux-intro-features \
		sysdev-linux-intro-versioning \
		sysdev-linux-intro-configuration \
		sysdev-linux-intro-compilation \
		sysdev-linux-intro-cross-compilation \
		android-kernel-lab-compilation \
		android-kernel-changes-title \
		android-kernel-changes-wakelocks \
		android-kernel-changes-binder \
		android-kernel-changes-klogger \
		android-kernel-changes-ashmem \
		android-kernel-changes-timers \
		android-kernel-changes-network \
		android-kernel-changes-lmk \
		android-kernel-changes-misc \
		android-bootloaders-title \
		sysdev-bootloaders-sequence \
		android-bootloaders-fastboot \
		android-new-board-lab \
		android-adb-title \
		android-adb-introduction \
		android-adb-use \
		android-adb-examples \
		android-adb-lab \
		android-fs-title \
		sysdev-root-filesystem-principles \
		android-fs-contents \
		sysdev-root-filesystem-device-files \
		sysdev-root-filesystem-minimal \
		android-build-system-title \
		android-build-system-basics \
		android-build-system-envsetup \
		android-build-system-configuration \
		android-build-system-modules \
		android-build-system-lab-library \
		android-build-system-product \
		android-build-system-lab-product \
		android-native-layer-title \
		sysdev-toolchains-definition \
		android-native-layer-bionic \
		android-native-layer-toolbox \
		android-native-layer-init \
		android-native-layer-daemons \
		android-native-layer-flingers \
		android-native-layer-stagefright \
		android-native-layer-dalvik \
		android-native-layer-hal \
		android-native-layer-jni \
		android-native-layer-lab-binary \
		android-framework-title \
		android-framework-native-services \
		android-framework-ipc \
		android-framework-java-services \
		android-framework-extend \
		android-framework-lab \
		android-application-title \
		android-application-basics \
		android-application-activities \
		android-application-services \
		android-application-providers \
		android-application-intents \
		android-application-processes \
		android-application-resources \
		android-application-storage \
		android-application-apk \
		android-application-lab \
		android-resources \
		last-slides

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

ANDROID_LABS  = setup \
		android-source-code \
		android-first-compilation \
		android-boot \
		android-new-board \
		android-adb \
		android-native-library \
		android-system-customization \
		android-native-app \
		android-jni-library \
		android-application \


# Output directory
OUTDIR   = $(PWD)/out

# Latex variable definitions
VARS = $(OUTDIR)/vars

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
SLIDES_TRAINING      = $(lastword $(subst -, , $(SLIDES)))
SLIDES_COMMON_BEFORE = common/slide-header.tex \
		       common/$(SLIDES_TRAINING)-title.tex
SLIDES_CHAPTERS      = $($(call UPPERCASE, $(SLIDES_TRAINING))_SLIDES)
SLIDES_COMMON_AFTER  = common/slide-footer.tex
else
SLIDES_TRAINING      = $(firstword $(subst -, ,  $(SLIDES)))
SLIDES_CHAPTERS      = $(filter $(SLIDES)%, $($(call UPPERCASE, $(SLIDES_TRAINING))_SLIDES))
ifeq ($(words $(SLIDES_CHAPTERS)),1)
SLIDES_COMMON_BEFORE = common/slide-header.tex common/single-subsection-slide-title.tex
else
SLIDES_COMMON_BEFORE = common/slide-header.tex common/single-slide-title.tex
endif
SLIDES_COMMON_AFTER  = common/slide-footer.tex
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
# Compute the set of chapters to build depending on the name of the
# PDF file that was requested.
ifeq ($(LABS),full-kernel)
LABS_VARSFILE      = common/kernel-labs-vars.tex
LABS_CHAPTERS      = $(KERNEL_LABS)
else ifeq ($(LABS),full-sysdev)
LABS_VARSFILE      = common/sysdev-labs-vars.tex
LABS_CHAPTERS      = $(SYSDEV_LABS)
else ifeq ($(LABS),full-android)
LABS_VARSFILE      = common/android-labs-vars.tex
LABS_CHAPTERS      = $(ANDROID_LABS)
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
# === Compilation of agendas ===
#
ifdef AGENDA
AGENDA_TEX = agenda/$(AGENDA)-agenda.tex
AGENDA_PICTURES = $(COMMON_PICTURES)

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

#
# === Misc targets ===
#

$(VARS): FORCE
	@mkdir -p $(dir $@)
	/bin/echo "\def \sessionurl {$(SESSION_URL)}" > $@
	/bin/echo "\def \training {$(SLIDES_TRAINING)}" >> $@

clean:
	$(RM) -rf $(OUTDIR) *.pdf

help:
	@echo "Available targets:"
	@echo
	@echo " full-sysdev-labs.pdf		Complete labs for the 'sysdev' course"
	@echo " full-kernel-labs.pdf		Complete labs for the 'kernel' course"
	@echo " full-android-labs.pdf		Complete labs for the 'android' course"
	@echo " full-sysdev-slides.pdf		Complete slides for the 'sysdev' course"
	@echo " full-kernel-slides.pdf		Complete slides for the 'kernel' course"
	@echo " full-android-slides.pdf		Complete slides for the 'android' course"
	@echo " kernel-agenda.pdf		Agenda for the 'kernel' course"
	@echo " <some-chapter>-slides.pdf	Slides for a particular chapter in slides/"
	@echo
	@echo " <some-chapter>-labs.pdf		Labs for a particular chapter in labs/"
	@echo
