#!/bin/bash
platform=$1


version=$2
qa_svn_dir=/data/svn/qa/$platform/$version

#chekc qa_svn_dir svn status
svn up $qa_svn_dir
svn log $qa_svn_dir
