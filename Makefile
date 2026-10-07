# `make` exports every top-level .scad file to stl/ (needs the openscad CLI).
# `make dist` bundles each top-level .scad file and its lib/ dependencies into
# a single self-contained file in dist/, for sites that take one .scad file
# (needs uv: https://docs.astral.sh/uv/).
SCADS := $(wildcard *.scad)
STLS := $(patsubst %.scad,stl/%.stl,$(SCADS))
DISTS := $(patsubst %.scad,dist/%.scad,$(SCADS))

all: $(STLS)

dist: $(DISTS)

stl/%.stl: %.scad $(wildcard lib/*.scad)
	openscad -o $@ $<

dist/%.scad: %.scad $(wildcard lib/*.scad)
	mkdir -p dist
	uvx openscad-packer pack $< -o $@
