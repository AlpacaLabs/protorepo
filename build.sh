#!/usr/bin/env bash
# This script is meant to build and compile every protocolbuffer for each
# service declared in this repository (as defined by sub-directories).
# It compiles using docker containers based on Namely's protoc image
# seen here: https://github.com/namely/docker-protoc

set -e

ORGNAME=AlpacaLabs
REPOPATH=${REPOPATH-$(pwd)/repos}
CURRENT_BRANCH=${BUILDKITE_BRANCH-$(git branch | grep \* | cut -d ' ' -f2)}

# Helper for adding a directory to the stack and echoing the result
function enterDir {
  echo "Entering $1"
  pushd $1 > /dev/null
}

# Helper for popping a directory off the stack and echoing the result
function leaveDir {
  echo "Leaving `pwd`"
  popd > /dev/null
}

# Enters the directory and starts the build / compile process for the services
# protobufs
function buildDir {
  currentDir="$1"
  echo "Building directory \"$currentDir\""

  echo "Now in directory: $(pwd)"
  echo "Target will be: $(basename $currentDir)"
  buildProtoForTypes "$(basename $currentDir)"
}

# Iterates through all of the languages listed in the services .protolangs file
# and compiles them individually
function buildProtoForTypes {
  target=${1%/}

  local protolangsFile=./alpacalabs/$target/.protolangs

  if [ -f $protolangsFile ]; then
    while read lang; do

      local repoRoot="$(pwd)"
      local outDir=pb-$lang-$target

      echo "REPOPATH = $REPOPATH"
      reponame="protorepo-$target-$lang"
      rm -rf $REPOPATH/$reponame
      # Clone the repository down and set the branch to the automated one
      echo "Cloning repo: git@github.com:$ORGNAME/$reponame.git"
      git clone git@github.com:$ORGNAME/$reponame.git $REPOPATH/$reponame
      setupBranch $REPOPATH/$reponame

      echo "Running Docker container to build protobufs..."
      docker run \
        -v $repoRoot:/defs \
        namely/protoc-all \
        -l $lang \
        -i . \
          -d ./alpacalabs/$target/v1 \
          -o $outDir \
          --go-source-relative

      # Copy the generated files out of the pb-* path into the repository
      # that we care about
      echo "Rsyncing..."
      rsync -r --delete $outDir/* $REPOPATH/$reponame/

      echo "Pushing code to remote..."
      commitAndPush $REPOPATH/$reponame
    done < $protolangsFile
  fi
}

# Finds all directories in the repository and iterates through them calling the
# compile process for each one
function buildAll {
  echo "Building service's protocol buffers"
  mkdir -p $REPOPATH
  for d in ./alpacalabs/*/; do
    buildDir $d
  done
}

function setupBranch {
  enterDir $1

  echo "Creating branch"

  if ! git show-branch $CURRENT_BRANCH; then
    echo git branch $CURRENT_BRANCH
    git branch $CURRENT_BRANCH
  fi

  echo git checkout $CURRENT_BRANCH
  git checkout $CURRENT_BRANCH

  if git ls-remote --heads --exit-code origin $CURRENT_BRANCH; then
    echo "Branch exists on remote, pulling latest changes"
    git pull origin $CURRENT_BRANCH
  fi

  leaveDir
}

function commitAndPush {
  enterDir $1

  git add -N .

  if ! git diff --exit-code > /dev/null; then
    git add .
    git commit -m "Auto Creation of Proto"
    git push origin HEAD
  else
    echo "No changes detected for $1"
  fi

  leaveDir
}

main() {
  buildAll
}


main