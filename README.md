
<!-- vim: set et spell -->

![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)
[![Build Status](https://travis-ci.org/lindig/md2jr.svg?branch=master)](https://travis-ci.org/lindig/md2jr)

# MD2JR - Markdown to Jira Conversion

This is a crude tool to convert [Markdown] to [Jira] syntax:

    $ md2jr  README.md

I'm using it only as a first approximation for putting notes that I have
kept in Markdown syntax into [Jira].

## Installation

This tool is written in [OCaml] and compiles to a single binary with no
dependencies. Installation is easiest with [OCaml]'s package manager
Opam:

    $ opam pin add md2jr https://github.com/lindig/md2jr.git

I am planning an Opam release. After that, it becomes:

    $ opam install md2jr

You can also install from source code:

    $ ./configure
    $ make

## Usage

    $ md2jr [files]
    $ md2jr --help

## Status

This is an early release with quite some problems left. Code
contributions are welcome.


[OCaml]:    http://ocaml.org
[Jira]:     https://www.atlassian.com/software/jira
[Markdown]: https://daringfireball.net/projects/markdown/
