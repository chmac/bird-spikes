// Main part file. Open this in OpenSCAD and press F5 (preview) / F6 (render).
use <lib/spike.scad>

$fn = 48; // smoothness of curves

base_w = 100;   // mm
base_d = 20;    // mm
base_t = 3;     // mm
spacing = 15;   // mm between spikes

union() {
    cube([base_w, base_d, base_t]);
    for (x = [spacing / 2 : spacing : base_w - spacing / 2])
        translate([x, base_d / 2, base_t])
            spike();
}
