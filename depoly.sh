#!/bin/bash

echo "Depoly to Github Pages..."

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
hugo

# 进入生成的文件夹
cd public

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:fuyi-atlas/fuyi-atlas.github.io.git main:gh-pages

cd -
rm -rf public/*
