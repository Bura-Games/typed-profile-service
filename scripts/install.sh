#!/bin/bash

# Remove old packages folder
if [ -d "Packages" ]; then
    rm -rf ./Packages
fi

# Install packages
wally install

# Sourcemap generation
rojo sourcemap --output sourcemap.json place.project.json

# Fix the types (why is this not native???)
wally-package-types --sourcemap sourcemap.json Packages/
