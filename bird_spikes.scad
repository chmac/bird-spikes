// Main part file. Open in OpenSCAD: F5 preview, F6 render.
use <lib/spike.scad>
use <lib/layout.scad>

$fn = 48;

// Plate
shape   = "rect";   // "rect" or "ellipse" (use w == d for a circle)
plate_w = 100;      // mm
plate_d = 40;       // mm
plate_t = 3;        // mm

// Spikes
bottom_d = 8;       // mm
top_d    = 0;       // mm, 0 = cone
height   = 40;      // mm
pitch    = 10;      // mm, floor space per spike (>= bottom_d)
stagger  = false;   // offset alternate rows

// Edge lean
lean_angle = 15;    // degrees from vertical, 0 = no lean
edge_band  = 10;    // mm: spikes whose centre is this close to the edge lean outwards

module plate_2d() {
    if (shape == "rect") square([plate_w, plate_d], center = true);
    else scale([plate_w / 2, plate_d / 2]) circle(r = 1);
}

linear_extrude(plate_t) plate_2d();

for (p = spike_points(shape, plate_w, plate_d, pitch, bottom_d / 2, stagger))
    translate([p[0], p[1], plate_t - 0.01])  // tiny overlap so the union is solid
        spike(bottom_d, top_d, height + 0.01, lean_angle,
              edge_dir(shape, p[0], p[1], plate_w, plate_d, edge_band));
