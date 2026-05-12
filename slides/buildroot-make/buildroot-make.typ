#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= GNU Make 101

=== Introduction

- Buildroot being implemented in *GNU Make*, it is quite
  important to know the basics of this language

  - Basics of _make_ rules

  - Defining and referencing variables

  - Conditions

  - Defining and using functions

  - Useful _make_ functions

- This does not aim at replacing a full course on _GNU Make_

- #link("https://www.gnu.org/software/make/manual/make.html")

- #link("https://www.nostarch.com/gnumake")

=== Basics of _make_ rules

- At their core, _Makefiles_ are simply defining *rules* to
  create *targets* from *prerequisites* using
  *recipe commands*

  ```
  TARGET ...: PREREQUISITES ...
           RECIPE
           ...
  ```

- *target*: name of a file that is generated. Can also be an
  arbitrary action, like `clean`, in which case it's a *phony
  target*

- *prerequisites*: list of files or other targets that are needed
  as dependencies of building the current target.

- *recipe*: list of shell commands to create the target from the
  prerequisites

=== Rule example

#text(size: 15pt)[Makefile]
#v(-0.1em)
```make
clean:
        rm -rf $(TARGET_DIR) $(BINARIES_DIR) $(HOST_DIR) \
                $(BUILD_DIR) $(BASE_DIR)/staging \
                $(LEGAL_INFO_DIR)

distclean: clean
        [...]
        rm -rf $(BR2_CONFIG) $(CONFIG_DIR)/.config.old \
               $(CONFIG_DIR)/.auto.deps
```

- `clean` and `distclean` are phony targets

=== Defining and referencing variables

- Defining variables is done in different ways:

  - `FOOBAR = value`, expanded at time of use

  - `FOOBAR := value`, expanded at time of assignment

  - `FOOBAR += value`, append to the variable, with a separating space,
    defaults to expanded at the time of use

  - `FOOBAR ?= value`, defined only if not already defined

  - Multi-line variables are described using `define NAME ... endef`:

    ```
    define FOOBAR
    line 1
    line 2
    endef
    ```

- Make variables are referenced using the `$(FOOBAR)` syntax.

=== Conditions

#[
  #show raw.where(lang: "make", block: true): set text(size: 12pt)

  - With `ifeq` or `ifneq`

    ```make
    ifeq ($(BR2_CCACHE),y)
    CCACHE := $(HOST_DIR)/bin/ccache endif

    distclean: clean
    ifeq ($(DL_DIR),$(TOPDIR)/dl)
            rm -rf $(DL_DIR)
    endif
    ```

  - With the `$(if ...)` make function:

    ```make
    HOSTAPD_LIBS += $(if $(BR2_STATIC_LIBS),-lcrypto -lz)
    ```
]

=== Defining and using functions

#[
  #show raw.where(lang: "make", block: true): set text(size: 11pt)

  - Defining a function is exactly like defining a variable:

    ```make
    MESSAGE = echo "$(TERM_BOLD)>>> $($(PKG)_NAME) $($(PKG)_VERSION) $(call qstrip,$(1))$(TERM_RESET)"

    define legal-license-header # pkg, license-file, {HOST|TARGET}
            printf "$(LEGAL_INFO_SEPARATOR)nt$(1): \
                    $(2)n$(LEGAL_INFO_SEPARATOR)nnn" >>$(LEGAL_LICENSES_TXT_$(3))
    endef
    ```

  - Arguments accessible as `$(1)`, `$(2)`, etc.

  - Called using the `$(call func,arg1,arg2)` construct

    ```make
    $(BUILD_DIR)/%/.stamp_extracted:
            [...]
            @$(call MESSAGE,"Extracting")

    define legal-license-nofiles # pkg, {HOST|TARGET}
            $(call legal-license-header,$(1),unknown license file(s),$(2))
    endef
    ```
]

=== Useful _make_ functions

#[
  #show raw.where(lang: "make", block: true): set text(size: 12pt)

  - `subst` and `patsubst` to replace text

    ```make
    ICU_SOURCE = icu4c-$(subst .,_,$(ICU_VERSION))-src.tgz
    ```

  - `filter` and `filter-out` to filter entries

  - `foreach` to implement loops

    ```make
    $(foreach incdir,$(TI_GFX_HDR_DIRS),
          $(INSTALL) -d $(STAGING_DIR)/usr/include/$(notdir $(incdir)); \
          $(INSTALL) -D -m 0644 $(@D)/include/$(incdir)/*.h \
                  $(STAGING_DIR)/usr/include/$(notdir $(incdir))/
    )
    ```

  - `dir`, `notdir`, `addsuffix`, `addprefix` to manipulate file names

    ```make
    UBOOT_SOURCE = $(notdir $(UBOOT_TARBALL))

    IMAGEMAGICK_CONFIG_SCRIPTS = \
            $(addsuffix -config,Magick MagickCore MagickWand Wand)
    ```

  - And many more, see the _GNU Make_ manual for details.
]

=== Writing recipes

- Recipes are just shell commands

- Each line must be indented with one `Tab`

- Each line of shell command in a given recipe is independent from the
  other: variables are not shared between lines in the recipe

- Need to use a single line, possibly split using \\, to do complex
  shell constructs

- Shell variables must be referenced using `$$name`.

#v(0.5em)
#text(size: 15pt)[package/pppd/pppd.mk]
#v(-0.1em)
#[ #show raw.where(lang: "make", block: true): set text(size: 12pt)

  ```make
  define PPPD_INSTALL_RADIUS
          ...
          for m in $(PPPD_RADIUS_CONF); do \
                  $(INSTALL) -m 644 -D $(PPPD_DIR)/pppd/plugins/radius/etc/$$m \
                          $(TARGET_DIR)/etc/ppp/radius/$$m; \
          done
          ...
  endef
  ```
]
