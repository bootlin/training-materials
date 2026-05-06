#import "@local/bootlin:0.1.0": *

// Linux Elixir commands
#let manpage(arg1, arg2) = [
  #codelink("man "+arg2+ " " +arg1, "https://man7.org/linux/man-pages/man"+arg2+"/"+arg1+"."+arg2+".html")
]

// Generic Elixir commands
#let projdir(arg1, arg2) = [
  #codelink(arg2+"/","https://elixir.bootlin.com/"+arg1+"/latest/source/"+arg2)
]

#let projfile(arg1, arg2) = [
  #codelink(arg2, "https://elixir.bootlin.com/"+arg1+"/latest/source/"+arg2)
]

#let projsym(arg1, arg2) = [
  #codelink(arg2,"https://elixir.bootlin.com/"+arg1+"/latest/ident/"+arg2)
]

#let projfunc(arg1, arg2) = [
  #codelink(arg2+"()","https://elixir.bootlin.com/"+arg1+"/latest/ident/"+arg2)
]

#let projconfig(arg1, arg2) = [
  #codelink(arg2, "https://elixir.bootlin.com/"+arg1+"/latest/K/ident"+arg2)
]

#let projconfigval(arg1, arg2, arg3) = [
  #codelink(arg2+"="+arg3,"https://elixir.bootlin.com/"+arg1+"/latest/K/ident"+arg2)
]

#let projconfignotset(arg1, arg2) = [
  #codelink(arg2+ " is not set","https://elixir.bootlin.com/"+arg1+"/latzest/K/ident"+arg2)
]

// Linux Elixir commands
#let kfunc(arg) = [
  #codelink(arg+"()","https://elixir.bootlin.com/linux/latest/ident/"+arg)
]

#let ksym(arg) = [
  #codelink(arg, "https://elixir.bootlin.com/linux/latest/ident"+arg)
]

#let kcompat(arg1, arg2) = [
  #codelink(arg2, "https://elixir.bootlin.com/linux/latest/B/ident/"+arg1)
]

#let kstruct(arg) = [
  #codelink("struct "+arg, "https://elixir.bootlin.com/linux/latest/ident/"+arg)
]

#let kfile(arg) = [
  #projfile("linux", arg)
]

#let krelfile(arg1, arg2) = [
  #codelink(arg2,"https://elixir.bootlin.com/linux/latest/source/"+arg1+"/"+arg2)
]

#let kfileversion(arg1, arg2) = [
  #codelink(arg1, "https://elixir.bootlin.com/linux/v"+arg2+"/source/"+arg1)
]

#let kdir(arg) = [
  #projdir("linux", arg)
]

#let kreldir(arg1, arg2) = [
  #codelink(arg2+ "/", "https://elixir.bootlin.com/linux/latest/source/"+arg1+"/"+arg2)
]

#let ksubarch(arg) = [
  #codelink(arg, "https://elixir.bootlin.com/linux/latest/source/arch/"+arg+"/")
]

#let kconfig(arg) = [
  #codelink(arg, "https://elixir.bootlin.com/linux/latest/K/ident/"+arg)
]

#let kconfigval(arg1, arg2) = [
  #codelink(arg1+"="+arg2, "https://elixir.bootlin.com/linux/latest/K/ident/"+arg1)
]

#let kconfignotset(arg) = [
  #codelink("##"+arg + " is not set","https://elixir.bootlin.com/linux/latest/K/ident/"+arg)
]

#let kdoctext(arg) = [
  #codelink("Documentation/"+arg, "https://kernel.org/doc/Documentation/"+arg)
]

#let kdochtml(arg) = [
  #codelink(arg, "https://www.kernel.org/doc/html/latest/"+arg)
]

#let kdochtmldir(arg) = [
  #codelink(arg+"/", "https://www.kernel.org/doc/html/latest/"+arg+"/")
]

#let kdochtmlsection(arg1, arg2, arg3) = [
  #codelink(arg1+ "section " + [#emph(arg3)],"https://www.kernel.org/doc/html/latest/"+arg1+"/index.html#"+arg2)
]

// Yocto commands
#let yoctovar(arg) = [
  #codelink(arg,"https://docs.yoctoproject.org/ref-manual/variables.html#term-"+arg)
]