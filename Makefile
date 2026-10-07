# `make` exports every top-level .scad file to stl/ (needs the openscad CLI).
STLS := $(patsubst %.scad,stl/%.stl,$(wildcard *.scad))

all: $(STLS)

stl/%.stl: %.scad $(wildcard lib/*.scad)
	openscad -o $@ $<
