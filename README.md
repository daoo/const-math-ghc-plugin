[![Build Status](https://secure.travis-ci.org/kfish/const-math-ghc-plugin.png?branch=master)](http://travis-ci.org/kfish/const-math-ghc-plugin)

GHC plugin for Constant Math
============================

This plugin eliminates constant math expressions from Haskell source.

Using this plugin adds a compiler pass which replaces mathematical
expressions on constant numeric values with the result of that
expression. Supported expressions include:

* unary RealFloat functions (exp, log, sqrt, sin, cos, tan,
  asin, acos, atan, sinh, cosh, tanh, asinh, acosh, atanh)
* unary Num functions (negate, abs, signum).
* fromRational
* (**)

Basic arithmetic expressions (addition, subtraction, multiplication,
division) are already eliminated by existing GHC passes. This plugin
is run multiple times during compilation, so the results of intermediate
arithmetic eliminations are exposed to the const-math plugin, allowing
chains of mathematical expressions to be completely eliminated.

Installation
------------

Install the latest released version of the plugin from Hackage
(requires GHC >= 7.4.1):

    $ cabal install const-math-ghc-plugin

Alternatively, git clone this repo and:

    $ cabal install

Use
---

To use this plugin when building a Haskell source file, pass the following
argument to GHC:

    $ ghc -fplugin ConstMath.Plugin foo.hs

To build a cabal package _packagename_:

    $ cabal install --ghc-options="-package const-math-ghc-plugin -fplugin ConstMath.Plugin" packagename

Note that you need to expose the const-math-ghc-plugin package to ghc
(using the -package argument) as cabal will otherwise hide all packages
not specified in packagename.cabal.

Options
-------

Option arguments can be passed to the plugin with -fplugin-opt:

    $ ghc -fplugin ConstMath.Plugin -fplugin-opt=ConstMath.Plugin:ARG foo.hs

Currently available arguments are:

    --dry, --dry-run
        Don't make any substitutions, just report on matches

    -v,--verbose
        verbose output (default)

    --trace
        very verbose output (useful for seeing the AST used for matching)

    -q, --quiet
        no output

  Phase control

    --enable-default
        run a ConstMath pass after early simplifier passes

    --enable-post-simpl
        run a ConstMath pass after every simplifier pass

    --enable-always
        run a ConstMath pass after every compiler pass (expensive)


Inspecting the result
---------------------

To see the resulting changes, compare the core produced. An excellent way to
view core is to `cabal install ghc-core`, a tool which runs ghc with options
to dump the core and the disassembled output in a pager with syntax
highlighting:

    $ ghc-core -- -O2 -fplugin ConstMath.Plugin foo.hs

Alternatively, just run ghc directly and ask it to show you the core:

    $ ghc -fforce-recomp -ddump-simpl -O2 -fplugin ConstMath.Plugin foo.hs

For example, we generate a short file with a single math expression:

    $ echo "module Main where main = print (1.0 / sqrt (2 * pi))" > foo.hs

Dumping the core produced by a normal optimized GHC build shows the
sqrt will be evaluated at run-time:

    $ ghc -ddump-simpl -O2 foo.hs | grep sqrt
      case GHC.Prim./## 1.0 (GHC.Prim.sqrtDouble# 6.283185307179586)

Note that GHC has already calculated the result of (2 * pi).

However, dumping the core produced by GHC with the additional const math
pass shows that the call to sqrt has been removed:

    $ ghc -ddump-simpl -O2 -fplugin ConstMath.Plugin foo.hs | grep -c sqrt
      0

Inspecting the core further show that the division has also been removed,
and the result of the entire math expression will be directly written into
the executable:

    GHC.Float.$w$sformatRealFloat
      GHC.Float.FFGeneric
      (Data.Maybe.Nothing @ GHC.Types.Int)
      0.3989422804014327

Tests
-----

The source tree contains a set of tests, including the full numeric test
suite imported from the GHC sources. To run the test suite:

    $ cd tests
    $ make

Alternatively, you can use the `cabal test` framework:

    $ cabal install --enable-tests

Join in
-------

File bugs in the GitHub [issue tracker][].

Master [git repository][gh]:

* `git clone https://github.com/kfish/const-math-ghc-plugin.git`

# License

BSD3. See `LICENSE` for terms of copyright and redistribution.

[issue tracker]: http://github.com/kfish/const-math-ghc-plugin/issues
[gh]: http://github.com/kfish/const-math-ghc-plugin
