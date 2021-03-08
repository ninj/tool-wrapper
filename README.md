# tool-wrapper

## Introduction

This is a simulation of providing a wrapper called `toolw` for a tool called `tool`.


## Components

- `https://example.repo/tool-wrapper/toolw-up.sh` - script to install `toolw` into the  current directory. 
- `project_dir/toolw` - project-level wrapper script.
- `project_dir/.tool/wrapper/tool-wrapper.properties` - project-level tool wrapper configuration.
    - `distributionUrl=https://example.repo/location/0.0.1/tool.zip`
- `tool_user_home/wrapper/dists/tmp-*/` - temporary location for local tool installation.
- `tool_user_home/wrapper/dists/tool-*/` - location of local tool installations.


## Environment Variables

These variables are for the made-up tool, rather than the wrapper.



## Building

- `./build.sh`
    - creates `toolw` via a template and content from `toolw` and `.tool/wrapper/tool-wrapper.properties`. 
    - copies wrapper to `target/toolw-repo`.
    - creates dummy tool archive in `target/tool-repo`.
    - from `target/project`:
        - creates `toolw` and config dir by calling `toolw-up` script in `target/toolw-repo`.
        - sets `TOOL_USER_HOME` to `target/tool_user_home` and re-writes `distributionUrl` to `target/tool-repo`.
        - calls `./toolw` to trigger install of `tool`. 
    - execute tests.
    - (todo) upload new version to distribution repo.
    

## Dummy Tool Behaviour

The dummy tool used to demonstrate wrapper has the following behaviour:

- tool installation directory has executables under `/bin`
- user-level configuration expected to reside in `tool_user_home`
- project-level configuration expected to reside in `project_dir/.tool/`
- distributions are in `zip` format, containing a single subdirectory, e.g. `tool-0.0.1/`.
- tool repo has layout like: `https://example.repo/location/0.0.1/tool.zip`
- environment variables:
    - `TOOL_USER_HOME` - where to install tool locally, defaults to `$HOME/.tool`
    - `TOOL_DEBUG` - enables trace debugging if non-blank.

Note that the locally installed versions of the tool will go into `$TOOL_USER_HOME/wrapper`

Some of these behaviours will be encoded into `build.sh` and `toolw`

## Copying As A Base For Custom Tools 

TODO: provide an init script to allow developers customise for their own tool.
