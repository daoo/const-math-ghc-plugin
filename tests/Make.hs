module Main where

import System.Directory
import System.Process

import Paths_const_math_ghc_plugin

main = do
    testdir <- getDataFileName "tests"
    setCurrentDirectory testdir
    system "make && make clean"
