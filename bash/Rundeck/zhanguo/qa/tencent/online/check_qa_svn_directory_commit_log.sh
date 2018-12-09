#!/bin/bash
platform=tencent
version=1.7.0
qa_svn_dir=/data/svn/$platform/$version

#chekc qa_svn_dir svn status
svn log $qa_svn_dir
