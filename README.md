# bird-spikes

OpenSCAD models for bird spikes.

## Layout

- `*.scad` (root) – one file per printable part; open these in OpenSCAD
- `lib/` – reusable modules, pulled in with `use <lib/name.scad>`
- `stl/` – exported meshes for slicing (`make`)

## Usage

Install OpenSCAD (`brew install --cask openscad`), open `bird_spikes.scad`,
F5 to preview, F6 to render, then export STL. Or run `make` to export from the CLI.
