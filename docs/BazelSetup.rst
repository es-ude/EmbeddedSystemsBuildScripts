************
Bazel Setup
************

This article explains how to setup Bazel, in order 
to work properly with the EmbeddedSystemsBuildScripts.

Install Bazelisk
----------------

Bazelisk is a bazel wrapper, which provides an easy way to 
switch between different bazel versions, without uninstalling 
your local bazel installation. In order to build with a specific
bazel version, you need to supply a ``.bazelversion`` file, where
the desired version is specified, in your project root.
For more information take a look
at the Github repository_

.. _repository: https://github.com/bazelbuild/bazelisk

Linux
~~~~~

The following manual explains how to install bazelisk on a ubuntu host. 
This should be the same on any other Debian based systems. Some things 
may differ if you're using a different Linux distribution. In that case 
please look up your errors and add them to the troubleshooting section.

**1. Step: Install Go**

The installation slightly differs between Ubuntu versions. Please take a 
look here_. The first paragraph on Ubuntu 19.04(LTS) should be fine.

.. _here: https://github.com/golang/go/wiki/Ubuntu 

**2. Step: Install Bazelisk**

This chapter explains how to get and install bazelisk. However, you are
also able to fetch a suited binary from the Github releases.

* run ``go get github.com/bazelbuild/bazelisk`` in your command line
* add to your PATH variable: ``export PATH=$PATH:$(go env GOPATH)/bin``
* you may also want to simlink ``bazelisk`` to ``bazel``, but that's not really necessary


MacOS
~~~~~

* install the homebrew_ package manager
* run ``brew install bazelisk`` 

.. _homebrew: https://brew.sh/ 