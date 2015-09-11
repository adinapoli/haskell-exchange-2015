#!/usr/bin/env bash

find slides -type f | grep slides.md | entr sh -c "./go.sh"
