************
Unit Testing
************

Basic Setup
-----------

In order to make unit testing work, the |WORKSPACE| file must contain the external dependency |Unity|::

    http_archive(
        name = "Unity",
        build_file = "@EmbeddedSystemsBuildScripts//:BUILD.Unity",
        strip_prefix = "Unity-master",
        urls = ["https://github.com/ThrowTheSwitch/Unity/archive/master.tar.gz"],
    )

We would advise to use the |BazelCProjectCreator| for creating a project. 
This python script creates the complete project, including a unit test. However, if you want to include unit tests in your current project,
we would advise you to create a folder called |test|. This folder should contain *.c files with unit tests and a |BUILD| file.

Content of a .c test file

.. code-block:: C 

    #include "unity.h"

    void test_shouldFail(void)
    {
        TEST_FAIL();
    }

Content of the |BUILD| file::

    load("@EmbeddedSystemsBuildScripts//Unity:unity.bzl", "unity_test")

Each file that contains unit tests can be compiled and executed by using the |unity_test| macro, i.e.::

    unity_test(
        cexception = False,
        file_name = "first_Test.c",
        deps = [
            "//:Library",
            "//My_Project:HdrOnlyLib",
        ]
    )

The tests can be be run by executing ``bazel test test:first_Test`` from the project root in the command line. Alternatively, all available tests can be run with ``bazel test test:all``.


CException
----------

In the example unit test listed above, |cexception| is set to False. If you want to include CException as an external dependency in your project, you need to add the following to your |WORKSPACE| file::

    http_archive(
        name = "CException",
        build_file = "@EmbeddedSystemsBuildScripts//:BUILD.CException",
        strip_prefix = "CException-master",
        urls = ["https://github.com/ThrowTheSwitch/CException/archive/master.tar.gz"],
    )

Additionally, you may set the |cexception| attribute to True (default value is True).


Mocking
-------

We currently make use of |CMock| for creating mocks. CMock can be included as an external dependency by adding the following to the |WORKSPACE| file::

    http_archive(
        name = "CMock",
        build_file = "@EmbeddedSystemsBuildScripts//:BUILD.CMock",
        strip_prefix = "CMock-master",
        urls = ["https://github.com/ThrowTheSwitch/CMock/archive/   master.tar.gz"],
    )

Mocks are created in the |BUILD| file of the test folder. In order to do that, load the macro ``mock()``, by adding it to the load statement, i.e.::

    mock(
        name = "mock_MyHeader",
        srcs = ["//MyProject:MyHeader.h"],
        deps = ["//MyProject:MyHeaderLibrary"],
    )

In order to use the mock in a unit test, the mock has to be in the dependencies of the unit test at the first position, i.e.::

    unity_test(
        cexception = False,
        file_name = "my_Test.c",
        deps = [
            "mock_MyHeader",
            "//MyProject:MyHeaderLibrary",
        ],
    )

.. |WORKSPACE| replace:: ``WORKSPACE``
.. |Unity| replace:: ``Unity``
.. |BazelCProjectCreator| replace:: ``BazelCProjectCreator``
.. _BazelCProjectCreator: https://github.com/es-ude/BazelCProjectCreator
.. |test| replace:: ``test``
.. |BUILD| replace:: ``BUILD``
.. |unity_test| replace:: ``unity_test``
.. |cexception| replace:: ``cexception``
.. |CMock| replace:: ``CMock``