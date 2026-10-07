// A single spike standing on the XY plane, centred on the origin.
// top_diameter = 0 makes it a cone.
// lean_angle tilts the spike away from vertical, towards the unit vector
// lean_dir ([x, y]). The base stays flat on the plate (the spike is sheared,
// not rotated), so `height` is still the vertical rise.
module spike(bottom_diameter = 8, top_diameter = 0, height = 40, lean_angle = 0, lean_dir = [0, 0]) {
    t = tan(lean_angle);
    multmatrix([[1, 0, lean_dir[0] * t, 0],
                [0, 1, lean_dir[1] * t, 0],
                [0, 0, 1,               0]])
        cylinder(d1 = bottom_diameter, d2 = top_diameter, h = height);
}
