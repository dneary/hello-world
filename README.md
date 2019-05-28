# Hello World in C - Eclipse Che DevFile starter

This is intended to be the simplest possible Eclipse Che project to allow a developer to compile
and run a Hello, World in C.

## Why C?

Because the C compiler and GNU Make are available everywhere, their syntax is essentially
unchanged since the 1970s, and so I could in theory concentrate on the part I cared about -
creating a minimal devfile.

## What is a devfile?

A devfile is a metadata file for describing a developer workspace. A developer workspace is
a set of containers which will run on Kubernetes, which allow a developer to make changes to
a project and run them using Eclipse Che.

## What is Eclipse Che?

Eclipse Che is an IDE as a Service and developer workspace management tool, primarily for
the development of container applications, which runs on Kubernetes. A developer workspace
is made up of a number of containers, including the base images and application runtimes for
your application, any developer tools you need (compilers, debuggers, static analysis tools,
etc), and source code. Developers can edit the source code through a Typescript IDE which
runs as a web application inside the workspace.

It enables developers to create container environments for application development with a
single click, reducing time to on-board a new developer to zero. It runs natively on
Kubernetes, making it easier for developers to move from a development to
test/pre-prod/prod environments running on Kubernetes. It can also centralize the software
supply chain, allowing IT operations teams in companies who want to limit the application
runtimes and developer tools available to their developers to run the development cloud
"air-gapped" from the internet.
