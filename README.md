# bird-spikes

OpenSCAD models for bird spikes.

## Layout

- `*.scad` (root) – one file per printable part; open these in OpenSCAD
- `lib/` – reusable modules, pulled in with `use <lib/name.scad>`
  - `spike.scad` – one spike (bottom/top diameter, height)
  - `layout.scad` – where spikes go on a given plate shape
- `stl/` – exported meshes for slicing (`make`)
- `dist/` – single-file bundles for uploading to sites that take one `.scad` (`make dist`)

## Dependencies

- [OpenSCAD](https://openscad.org) – `brew install --cask openscad`
- [uv](https://docs.astral.sh/uv/) – `brew install uv`. Used to run
  [openscad-packer](https://pypi.org/project/openscad-packer/) via `uvx`, which
  bundles the `lib/` files into one `.scad` for publishing. Nothing else to install.

## Usage

Open `bird_spikes.scad` in OpenSCAD, F5 to preview, F6 to render, then export STL.
Or run `make` to export from the CLI.

To publish, run `make dist` and upload `dist/bird_spikes.scad`.

## License

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) – see `LICENSE`.
