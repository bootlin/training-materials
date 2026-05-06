#let wikipedia(name, display_name: "") = {
  if display_name == "" {
    display_name = name
  }
  link(
    "https://en.wikipedia.org/wiki/" + name,
    display_name
  )
}
