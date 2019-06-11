************
AvrToolchain
************

Usage
-----

To depend on the ``EmbeddedSystemsBuildScripts`` add this to your ``WORKSPACE`` file::

  load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
  
  http_archive(
    name = "EmbeddedSystemsBuildScripts",
    strip-prefix = "EmbeddedSystemsBuildScripts-{version}",
    urls = ["https://github.com/es-ude/EmbeddedSystemsBuildScripts/archive/{version}.tar.gz"]
  )

replace ``{version}`` with the actual version you want to use.
Or use::

  http_archive(
    name = "EmbeddedSystemsBuildScripts",
    strip-prefix = "EmbeddedSystemsBuildScripts-master",
    urls = ["https://github.com/es-ude/EmbeddedSystemsBuildScripts/archive/master.tar.gz"]
  )

to depend on the current master branch.
Now you can call the repository rule, that will create the necessary avr toolchains
and platforms. Add::

  load("@EmbeddedSystemsBuildScripts//AvrToolchain:avr.bzl", "create_avr")
  
  create_avr()

to the ``WORKSPACE`` file. The ``http_archive`` rule has to be called before loading
the ``create_avr()`` function.
