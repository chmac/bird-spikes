// Reusable modules. Import from a part file with: use <lib/spike.scad>

// A single conical spike standing on the XY plane.
module spike(base_d = 8, height = 40, tip_d = 0.5) {
    cylinder(d1 = base_d, d2 = tip_d, h = height);
}
