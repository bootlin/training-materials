// Internal for yocto* functions
#let _yoctolink(name, path, release: "", display_name: "") = {
  if release != "" {
    release = "/" + release
  }
  if display_name == "" {
    display_name = name
  }
  link(
    "https://docs.yoctoproject.org" + release + path + name,
    display_name
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
  _yoctolink(varname, "/ref-manual/variables.html#term-", release: release, display_name: display_name)
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
  _yoctolink(classname, "/ref-manual/classes.html#", release: release, display_name: display_name)
}
