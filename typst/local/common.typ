#import "@local/bootlin:0.1.0": *

// Generic Elixir commands
#let projdir(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2 + "/",
  "https://elixir.bootlin.com/" + arg1 + "/latest/source/" + arg2,
)]

#let projfile(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2,
  "https://elixir.bootlin.com/" + arg1 + "/latest/source/" + arg2,
)]

#let projsym(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2,
  "https://elixir.bootlin.com/" + arg1 + "/latest/ident/" + arg2,
)]

#let projfunc(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2 + "()",
  "https://elixir.bootlin.com/" + arg1 + "/latest/ident/" + arg2,
)]

#let projconfig(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2,
  "https://elixir.bootlin.com/" + arg1 + "/latest/K/ident" + arg2,
)]

#let projconfigval(arg1, arg2, arg3) = text(size: 18pt)[#codelink(
  arg2 + "=" + arg3,
  "https://elixir.bootlin.com/" + arg1 + "/latest/K/ident" + arg2,
)]

#let projconfignotset(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2 + " is not set",
  "https://elixir.bootlin.com/" + arg1 + "/latest/K/ident" + arg2,
)]

// Linux Elixir commands
#let manpage(arg1, arg2) = text(size: 18pt)[#codelink(
  "man " + arg2 + " " + arg1,
  "https://man7.org/linux/man-pages/man"
    + arg2
    + "/"
    + arg1
    + "."
    + arg2
    + ".html",
)]

#let kfunc(arg) = text(size: 18pt)[#codelink(
  arg + "()",
  "https://elixir.bootlin.com/linux/latest/ident/" + arg,
)]

#let ksym(arg) = text(size: 18pt)[#codelink(
  arg,
  "https://elixir.bootlin.com/linux/latest/ident" + arg,
)]

#let kcompat(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2,
  "https://elixir.bootlin.com/linux/latest/B/ident/" + arg1,
)]

#let kstruct(arg) = text(size: 18pt)[#codelink(
  "struct " + arg,
  "https://elixir.bootlin.com/linux/latest/ident/" + arg,
)]

#let kfile(arg) = text(size: 18pt)[#projfile("linux", arg)]

#let krelfile(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2,
  "https://elixir.bootlin.com/linux/latest/source/" + arg1 + "/" + arg2,
)]

#let kfileversion(arg1, arg2) = text(size: 18pt)[#codelink(
  arg1,
  "https://elixir.bootlin.com/linux/v" + arg2 + "/source/" + arg1,
)]

#let kdir(arg) = text(size: 16pt)[#projdir("linux", arg)]

#let kreldir(arg1, arg2) = text(size: 18pt)[#codelink(
  arg2 + "/",
  "https://elixir.bootlin.com/linux/latest/source/" + arg1 + "/" + arg2,
)]

#let ksubarch(arg) = text(size: 18pt)[#codelink(
  arg,
  "https://elixir.bootlin.com/linux/latest/source/arch/" + arg + "/",
)]

#let kconfig(arg) = text(size: 18pt)[#text(size: 18pt)[#codelink(
  arg,
  "https://elixir.bootlin.com/linux/latest/K/ident/" + arg,
)]]

#let kconfigval(arg1, arg2) = text(size: 18pt)[#codelink(
  arg1 + "=" + arg2,
  "https://elixir.bootlin.com/linux/latest/K/ident/" + arg1,
)]

#let kconfignotset(arg) = text(size: 18pt)[#codelink(
  "##" + arg + " is not set",
  "https://elixir.bootlin.com/linux/latest/K/ident/" + arg,
)]

#let kdoctext(arg) = text(size: 18pt)[#codelink(
  "Documentation/" + arg,
  "https://kernel.org/doc/Documentation/" + arg,
)]

#let kdochtml(arg) = text(size: 18pt)[#codelink(
  arg,
  "https://www.kernel.org/doc/html/latest/" + arg + ".html",
)]

#let kdochtmldir(arg) = text(size: 18pt)[#codelink(
  arg + "/",
  "https://www.kernel.org/doc/html/latest/" + arg + "/",
)]

#let kdochtmlsection(arg1, arg2, arg3) = text(size: 18pt)[#codelink(
  arg1 + "section " + emph(arg3),
  "https://www.kernel.org/doc/html/latest/" + arg1 + "/index.html#" + arg2,
)]

// Yocto commands
#let _yoctolink(name, path, release: "", display_name: "") = {
  if release != "" {
    release = "/" + release
  }
  if display_name == "" {
    display_name = name
  }
  link(
    "https://docs.yoctoproject.org" + release + path + name,
    display_name,
  )
}

/// Usage:
///   yoctovar("IMAGE_INSTALL")
///   yoctovar("IMAGE_INSTALL", release: "scarthgap")
///   yoctovar("IMAGE_INSTALL", release: "5.2")
///
/// - varname (str): Name of the variable
/// - release (str): Optional release name. Can be a the codename or a tag. Empty
///   means latest release.
/// - display_name (str): Optionally change the display name (varname by
///   default).
#let yoctovar(varname, release: "", display_name: "") = {
  _yoctolink(
    varname,
    "/ref-manual/variables.html#term-",
    release: release,
    display_name: display_name,
  )
}

/// Usage:
///   yoctoclass("cve-check")
///   yoctoclass("cve-check", release: "scarthgap")
///   yoctoclass("cve-check", release: "5.2")
///
/// - classname (str): Name of the class
/// - release (str): Optional release name. Can be a the codename or a tag. Empty
///   means latest release.
/// - display_name (str): Optionally change the display name (classname by
///   default).
#let yoctoclass(classname, release: "", display_name: "") = {
  _yoctolink(
    classname,
    "/ref-manual/classes.html#",
    release: release,
    display_name: display_name,
  )
}

// Wikipedia command
#let wikipedia(name, display_name: "") = {
  if display_name == "" {
    display_name = name
  }
  link(
    "https://en.wikipedia.org/wiki/" + name,
    display_name,
  )
}
