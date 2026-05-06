#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Overview of major embedded Linux software stacks

===  D-Bus

#table(columns: (75%, 25%), stroke: none, [

- _Message-oriented middleware mechanism that allows communication
  between multiple processes running concurrently on the same machine_

- Relies on a daemon to pass messages between applications

- Mainly used by system daemons to offer services to client applications

- Example: a network configuration daemon, running as _root_,
  offers a D-Bus API that CLI and GUI clients can use to configure
  networking

- Several busses

  - One system bus, accessible by all users, for system services

  - One session bus for each user logged in

- Object model: interfaces, objects, methods, signals

- #link("https://www.freedesktop.org/wiki/Software/dbus/")

],[

#align(center, [#image("dbus.pdf", width: 100%)])

])

===  systemd (1)

- Modern _init_ system used by almost all Linux desktop/server
  distributions

- Much more complex than _Busybox init_, but also much more
  powerful

- Only supported with _glibc_, not with _uClibc_ and
  _Musl_

- Provides features such as

  - Parallel startup of services, taking into account dependencies

  - Monitoring of services

  - On-demand startup of services, through _socket activation_

  - Resource-management of services: CPU limits, memory limits

- Configuration based on _unit files_

  - Declarative language, instead of shell scripts used in other init
    systems

===  systemd (2)

- Systemd also provides

  - _journald_, logging daemon, replacement for _syslogd_

  - _networkd_, network configuration management

  - _udevd_, hotplugging and `/dev` management

  - _logind_, login management

  - _systemctl_, tool to control/monitor systemd

  - And many, many other things

- #link("https://systemd.io/")

===  systemd service unit file example

#text(size: 16pt)[
/usr/lib/systemd/system/sshd.service]

#text(size: 17.5pt)[
```
[Unit]
Description=OpenSSH server daemon 
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service 
Wants=sshd-keygen.service

[Service]
EnvironmentFile=/etc/sysconfig/sshd 
ExecStart=/usr/sbin/sshd -D $ OPTIONS
ExecReload=/bin/kill -HUP $ MAINPID
KillMode=process 
Restart=on-failure 
RestartSec=42s

[Install]
WantedBy=multi-user.target
```]

===  Example systemctl/journalctl commands

- `systemctl status`, status of all services

- `systemctl status <service>`, status of one service

- `systemctl [start|stop] <service>`, start or stop a service

- `systemctl [enable|disable] <service>`, enable or disable a
  service, i.e. whether it should start at boot time

- `systemctl list-units`, list all available units

- `journalctl -a`, all logs

- `journalctl -f`, show the last entries, and keep printing new entries
  as they arrive

- `journalctl -u`, logs from a particular service

===  Linux graphics stack overview

#align(center, [#image("graphics-stack.pdf", height: 95%)])

===  Display controller support

- Deprecated Linux kernel subsystem: _fbdev_

  - Still a few old graphics drivers only available in this subsystem

  - If possible, don't use!

  - #link("https://en.wikipedia.org/wiki/Linux_framebuffer")[https://en.wikipedia.org/wiki/Linux_framebuffer]

- Modern Linux kernel subsystem: _DRM_

  - Supports display controllers of SoC or graphics cards, and all types
    of display panels and bridges: parallel, LVDS, DSI, HDMI,
    DisplayPort, etc.

  - Also supports small display panels connected over I2C or SPI

  - Devices exposed as `/dev/dri/cardX`

  - Companion user-space library: `libdrm`, includes a very handy test
    tool: `modetest`

  - #link("https://en.wikipedia.org/wiki/Direct_Rendering_Manager")[https://en.wikipedia.org/wiki/Direct_Rendering_Manager]

===  GPU support: OpenGL acceleration

- Open-source

  - A kernel driver in the DRM subsystem to send commands to the GPU and
    manage memory

  - `mesa3d` user-space library implementing the various OpenGL APIs,
    contains massive GPU-specific logic

  - More and more GPUs supported

  - #link("https://www.mesa3d.org/")

- Proprietary

  - Many embedded GPUs used to be supported only through proprietary
    blobs → long-term maintenance issues

  - A kernel driver provided out-of-tree by the vendor → they
    are not accepted upstream if the user-space is closed source

  - A (huge) closed-source user-space binary blob implementing the
    various OpenGL APIs

===  Concept of display servers

#table(columns: (60%, 40%), stroke: none, gutter: 15pt, [

- The Linux kernel does not handle the _multiplexing_ of the
  display and input devices between applications

  - Only one user-space application can use a display and a given set of
    input devices

- Display servers are special user-space applications that multiplex
  display/input by:

  - Allowing multiple client GUI applications to submit their window
    contents

  - Composing the final frame visible on the screen, based on contents
    submitted by applications, window visibility and layering

  - Propagating input events to the appropriate clients, based on focus

],[

#align(center, [#image("display-server.pdf", width: 100%)])

])

===  X11 and X.org

#table(columns: (75%, 25%), stroke: none, gutter: 15pt, [

- _X.org_ is the historical display server on UNIX systems,
  including Linux

- Implements the _X11_ protocol, used between clients and the
  server

  - UNIX socket for local clients, TCP for remote clients

- On modern Linux, works on top of DRM or fbdev for graphics, input
  subsystem for input events

- Still maintained, but now legacy.

- X11 license

- #link("https://www.x.org")

],[

#align(center, [#image("xorg.pdf", width: 100%)])

])

===  Wayland

#table(columns: (80%, 20%), stroke: none, gutter: 15pt, [

- _Communication *protocol* that specifies the communication
  between a display server and its clients, as well as a C library
  implementation of that protocol_

- A display server using the Wayland protocol is called a Wayland
  *compositor*

- Modern replacement for the aging X11 protocol

- More heavily based on OpenGL technologies

- #link("https://wayland.freedesktop.org/")

- #link("https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)")[https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)]

],[

#align(center, [#image("wayland.png", width: 100%)]) 

])

===  Wayland compositors

- Weston

  - The reference compositor

  - #link("https://gitlab.freedesktop.org/wayland/weston")

- Mutter, used by the GNOME desktop environment 
  #link("https://gitlab.gnome.org/GNOME/mutter")

- wlroots, a Wayland compositor library, used by

  - Cage, a Wayland kiosk-style compositor 
    #link("https://github.com/Hjdskes/cage")

  - swayWM, a tiling Wayland compositor 
    #link("https://swaywm.org/")

- And many more 
  #link("https://wiki.archlinux.org/title/wayland#Compositors")[https://wiki.archlinux.org/title/wayland#Compositors]

===  Concept of graphics toolkits

#table(columns: (70%, 30%), stroke: none, [

- The X11 and Wayland protocols are very low-level protocols

- While possible, developing applications directly using those protocols
  or their corresponding client libraries would be painful

- Existence of _toolkits_

  - Some of them work only on top of a display server: X11 or Wayland

  - Some of them can work directly on top of DRM + input, for single
    full-screen applications

- Widget-oriented toolkits, with APIs to create windows, buttons, text
  fields, drop-down lists, etc.

- Game/multimedia-oriented toolkits, with no pre-defined widget API

],[

#align(center, [#image("toolkit.pdf", height: 90%)])

])

===  Qt

#table(columns: (70%, 30%), stroke: none, [

- Highly popular and well-documented development framework, providing:

  - Core libraries: data structures, event handling, XML, databases,
    networking, etc.

  - Graphics libraries: widgets and more

- Standard API is C++, but bindings to other languages available

- Works as

  - Single application with DRM with OpenGL, or _fbdev_ with no
    acceleration

  - Multiple applications on top of X11 or Wayland

- Multiplatform: Linux, MacOS, Windows.

- Somewhat complex licensing, with a mix of LGPLv3, GPLv2, GPLv3, and an
  (expensive) commercial license

- #link("https://www.qt.io/")

],[

#align(center, [#image("qt-logo.pdf", width: 100%)]) 
])

===  Gtk

#table(columns: (75%, 25%), stroke: none, [

- Toolkit used as the base for the GNOME desktop environment, the most
  popular desktop environment for Linux desktop distributions, but
  loosing traction in embedded projects.

- Composed of _glib_ (core library), _pango_ (text handling),
  _cairo_ (vector graphics), _gtk_ (widget library)

- Standard API in C, but bindings exist for many languages

- Requires a display server: X11 or Wayland

- License: LGPLv2

- Version 3.x the most deployed currently, 4.x is a new major release

- Multiplatform: Linux, MacOS, Windows.

- #link("https://www.gtk.org")

],[

#align(center, [#image("gtk-logo.png", width: 100%)])

])

===  Flutter

#table(columns: (75%, 25%), stroke: none, [

- Cross-platform UI application development: Linux, Android, iOS,
  Windows, MacOS

- Developed and maintained by Google

- Applications must be developed using the _Dart_ programming
  language

- Applications can run in the Dart virtual machine, or be natively
  compiled for better performance.

- License: BSD-3-Clause

- #link("https://flutter.dev")

Read our blog post:
#link("https://bootlin.com/blog/flutter-nvidia-jetson-openembedded-yocto/")

],[

#align(center, [#image("Google-flutter-logo.pdf", width: 90%)])
#align(center, [#image("flutter-app.png", width: 70%)]) 
])

===  SDL

#table(columns: (70%, 20%), stroke: none, [

- _Cross-platform development library designed to provide low level
  access to audio, keyboard, mouse, joystick, and graphics hardware_

- Implemented in C, lightweight

- Does not provide a widget library

- Games, media players, custom UIs

- License: zlib license (simple permissive license)

],[
   
#align(center, [#image("sdl-logo.png", width: 100%)])

])

===  Other graphical toolkits

- Enlightenment Foundation Libraries (EFL) / Elementary

  - Lightweight and very powerful, but a lot less popular

  - Work on top of X or Wayland.

  - License: LGPLv2.1

  - #link("https://www.enlightenment.org/about-efl.md")

- LVGL

  - Very lightweight, mostly targeted at micro-controllers, but also
    runs on Linux

  - License: MIT

  - #link("https://lvgl.io/")

- See
  #link("https://en.wikipedia.org/wiki/List_of_widget_toolkits")[https://en.wikipedia.org/wiki/List_of_widget_toolkits]

===  Linux multimedia stack overview

#align(center, [#image("multimedia-stack.pdf", height: 90%)])

===  Audio stack

- Kernel-side: the ALSA subsystem, _Advanced Linux Sound
  Architecture_

  - Includes drivers for audio interfaces and audio codecs

  - Exposes audio devices in `/dev/snd/`

  - #link("https://alsa-project.org")

- Companion user-space library: _alsa-lib_

- Audio servers

  - Needed when multiple applications share audio devices: mix audio
    stream, route audio stream from specific applications to specific
    devices

  - _JACK_: mainly for professional audio

  - _pulseaudio_: mainly for regular desktop Linux audio

  - _pipewire_: modern replacement for both pulseaudio and JACK,
    already adopted by some Linux distributions

  - #link("https://pipewire.org/")

===  Video stack

- Kernel-side: Video4Linux subsystem, or V4L in short

  - Supports camera devices: webcams as well as camera interfaces of
    SoCs and camera sensors (parallel, CSI, etc.)

  - Also used to support video encoding/decoding HW accelerators: H264,
    H265, etc.

  - Exposes video devices as `/dev/videoX`

  - #link("https://www.linuxtv.org/")

- Traditional user-space library: _libv4l_

- New user-space library, more modern, with many more features, under
  adoption: _libcamera_

- Supported in lots of multimedia stacks/software: GStreamer, ffmpeg,
  VLC, etc.

===  GStreamer

- _Library for constructing graphs of media-handling components_

- Allows to create _pipelines_ to transform, convert, stream,
  display, capture multimedia streams, both audio and video

- Composed of a vast amounts of plugins: video capture/display, audio
  capture/playback, encoding/decoding, scaling, filtering, and more.

- #link("https://gstreamer.freedesktop.org/")

- An interesting alternative is _ffmpeg_

#align(center, [#image("gstreamer-pipeline.png", width: 60%)])

===  Further details on Linux graphics and multimedia stacks

#table(columns: (60%, 40%), stroke: none, [

- Bootlin's
  #link("https://bootlin.com/doc/training/graphics")[ _Understanding the Linux graphics stack_]
  training

- Bootlin's
  #link("https://bootlin.com/doc/training/audio")[ _Embedded Linux Audio_]
  training

- Complete courses focused exclusively on those topics

- Freely available training materials

],[

#align(center, [#image("linux-graphics-course-slide.jpg", width: 110%)])
#align(center, [#image("linux-audio-course-slide.jpg", width: 110%)])

])

===  Linux networking stack

#align(center, [#image("networking-stack.pdf", height: 95%)])

===  Web accessible UI

- Very common in embedded systems to use a Web interface for device
  configuration/monitoring

- Needs a web server: _Busybox httpd_ for very simple needs,
  _lighttpd_, _nginx_, _apache_ for more complex needs

- Can use PHP, NodeJS or other interpreted languages, or simple CGI
  shell scripts

===  Web browsers: rendering engines

To add HTML rendering capability to your device

- WebKit

  - Started by Apple, used in iOS, Safari

  - Open source project: LGPLv2.1 and BSD-2-Clause

  - #link("https://webkit.org/")

  - Integrated with Gtk: #link("https://webkitgtk.org/")[WebKitGTK]

  - Integrated with Qt: #link("https://wiki.qt.io/Qt_WebKit")[QtWebKit]

  - Port optimized for embedded devices:
    #link("https://wpewebkit.org/")[WPE WebKit]

- Blink

  - Forked from WebKit

  - Developed by Google, used in Chrome

  - #link("https://en.wikipedia.org/wiki/Blink_(browser_engine)")[https://en.wikipedia.org/wiki/Blink_(browser_engine)]

  - Integrated with Qt:
    #link("https://wiki.qt.io/QtWebEngine")[QtWebEngine]

  - Used by #link("https://www.electronjs.org/")[Electron]

===  Web-based UIs

- An alternative to native GUI applications is to create a GUI based on
  Web technologies

- Run a Web browser full-screen, and use popular Web technologies to
  develop the application

- Some possible options

  - _#link("https://github.com/Igalia/cog")[Cog]_, a simple
    launcher for the WPE Webkit port

  - _#link("https://www.electronjs.org/")[Electron]_, a way to
    package a NodeJS application with a web rendering engine, into a
    self-contained application

- Beware of the footprint and performance impact: a web rendering engine
  is a massive and resource-consuming piece of software

===  Programming languages

- Wide range of languages and frameworks available, not just C/C++

- Beware of footprint and performance implications

- Natively compiled languages

  - Rust

  - Go

  - Ada

  - Fortran

- Interpreted languages

  - Python

  - Javascript, NodeJS

  - Lua

  - Shell scripts

  - Perl, Ruby, PHP

#setuplabframe([Integration of additional software stacks],[

- Integration of _systemd_ as an init system

- Use _udev_ built in _systemd_ for automatic module loading

])
