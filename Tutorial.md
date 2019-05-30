
# Getting started with Che 7 workspaces

This tutorial will walk you through your first "Hello, world!" project
using Eclipse Che 7 and devfile to create a developer workspace from 
scratch.

## Step 0: The project

To begin with, let's create a project we want to use to test.

To keep things as simple as possible, I turned to my trusty 
"Hello, World!" in C.

```C
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
	printf("Hello, world!\n");
	return EXIT_SUCCESS;
}
```

To build the project, let's use `make`. Here's a Makefile:
```make
hello: hello.o
	gcc -o hello hello.o

hello.o:
	gcc -c hello.c
```

And we can now test out our project locally:
```
[dneary@dhcp-49-229.bos.redhat.com]$ make
gcc -c hello.c
gcc -o hello hello.o
Thu 30 May 2019 12:28:27 EDT ~/src/hello-world
[dneary@dhcp-49-229.bos.redhat.com]$ ./hello 
Hello, world!
```

Looking good!

## Step 1: creating a Devfile

Now that we have our project, we will want a few things in our developer
workspace:
* A base image - I chose centos:latest - as the runtime environment for
  our project
* A build and run command which should, respectively, run `make` and run
  `hello` in the appropriate directory to display the expected output in
  a terminal

Here is my first attempt at a Devfile, followed by a description of its
contents:

```yaml
specVersion: 0.0.1
name: hello-world
projects:
  - name: hello-world
    source:
      type: git
      location: https://github.com/dneary/hello-world.git
components:
  - alias: c-dev
    type: dockerimage
    image: centos:latest
    command: ['/bin/sh', '-c']
    args: ['tail -f /dev/null']
    env:
      - name: TERM
        value: xterm
    mountSources: true
    memoryLimit: 500M
commands:
  - name: build
    actions:
      - type: exec
        component: c-dev
        command: make
        workdir: /projects/hello-world
  - name: run
    attributes:
      runType: sequential
    actions:
      - type: exec
        component: c-dev
        command: ./hello
        workdir: /projects/hello-world
```

A [devfile](https://redhat-developer.github.io/devfile/) has two required
characteristics at the top level: 
* `specVersion` matches the desired version of the devfile spec, and 
  initially will always be `0.0.1`
* `name` is a descriptive string for the workspace definition

Underneath this, you will have zero or more `projects` and one 
`components` element. A project corresponds to a checked-out source code
repository, and both the project `name` and `source` elements are required,
if there is a project specified.

`components` refer to the container images which will form the workspace.
You will need at least one container, your developer run-time image, to
start a workspace. The `alias` field will be a unique name inside the
workspace for that container, `type` is one of `cheEditor`, `chePlugin`,
`dockerimage`, or `kubernetes`. The `cheEditor` field defaults to using
Theia, but it is possible to specify another front end for the workspace.
`chePlugin` containers run the various developer tools and plugins
specified for inclusion alongside the workspace.

In our example, we will simply pull the latest CentOS image from DockerHub
by using `type: dockerimage` and `image: centos:latest`. We run the command
`/bin/sh -c tail -f /dev/null` simply to keep the container running after
it has been started on the container management platform.

We will start with two commands: `build` will execute the command `make`
in the `c-dev` container references in `components`, inside the project
directory, while `run` will run the command `./hello` in the same directory.

We can validate the the Devfile is compliant with the schema by (insert validation step here).

## Trying out the devfile

Once you have an instance of Che running, there are a few ways to start a
workspace. You can use the `chectl` tool, which enables you to manage the
lifecycle both of Che instances and of workspaces that it manage. Or you
can pass the devfile directly to Che through the url 
https://${CHE_URL}/f?url=${DEVFILE_URL} - in my case, I used the hosted
Eclipse Che instance at https://che.openshift.io - you can try it yourself
by [clicking on this link to create a new workspace](https://che.openshift.io/f?url=https://raw.githubusercontent.com/dneary/hello-world/4a0ae943c2b8226c981c6a4b3808c18ca7d5952d/devfile.yaml)

In our initial Devfile example, I quickly hit a snag - it turns out that
GNU make and gcc are not pre-installed in the `centos:latest` base image.
No sweat, let's break out a Dockerfile.

## Creating a custom image

To get a suitable base image, we will need to install updates on the base
CentOS image, and install make and gcc.

```dockerfile
FROM centos:latest

RUN yum -y update && yum -y install make gcc
```

If you have never done it before, creating a custom Docker image is easy:
1. Ensure that Docker is installed and running locally - check with 
   `docker run hello-world`
2. Create an account on Dockerhub so that you can tag and push custom
   images
3. In the directory with the Dockerfile above, run `docker build --tag gcc-dev .`
4. Log in to Dockerhub with `docker login`
5. Push your updated image with `docker tag gcc-dev ${USERNAME}/gcc-dev:1 && docker push ${USERNAME}/gcc-dev:1`
   where USERNAME is your Dockerhub username

I pushed [the updated CentOS image](https://cloud.docker.com/u/dneary/repository/docker/dneary/gcc-dev) to `dneary/gcc-dev:1`
and replaced `centos:latest` with `dneary/gcc-dev:1` in my devfile above, 
pushed the updates (plus my `Dockerfile` above) to github, and [started a new workspace](https://che.openshift.io/f?url=https://raw.githubusercontent.com/dneary/hello-world/master/devfile.yaml).

Success! I now have a workspace which works with both `build` and `run`
commands.

## Adding developer tools

One thing which is missing, which would be really nice, is a C language
server to help with syntax highlighting, code completion, and other useful
development features. It would also be nice to be able to access debugging
features for GDB from the user interface. When I open up `hello.c`, I get
an error that the Clangd language server is not started.

Future articles will talk more about what is involved in running developer
tools alongside the workspace, using VS Code plug-ins, and how to commit changes to github, or create a github PR.


