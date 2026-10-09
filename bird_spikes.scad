// Main part file. Open in OpenSCAD: F5 preview, F6 render.
// Viewed from above, X is to the right (width) and Y is away from you (length).
// The front and back edges run along the width; the left and right edges run
// along the length.
//
// Notes:
// - Keep edge_band below the edge margin + bottom_diameter / 2 + pitch, or a
//   second row of spikes leans too.
// - An elliptical plate always leans all the way round; the lean_*_edges
//   options only apply to rectangles.
// - Keep comments on parameters to a single line: the single-file build
//   (make dist) drops comments that continue over several lines.
use <lib/spike.scad>
use <lib/layout.scad>

/* [Plate] */
elliptical_plate = true;  // oval (or circle, if width = length) instead of a rectangle
plate_width      = 205;    // mm, along X
plate_length     = 205;    // mm, along Y
plate_thickness  = 1;      // mm

/* [Spikes] */
bottom_diameter = 10;       // mm
top_diameter    = 5;       // mm, 0 = cone
height          = 60;      // mm
pitch           = 30;      // mm, minimum centre-to-centre spacing (>= bottom_diameter)
stagger         = false;   // offset alternate rows

/* [Edge distance] */
edge_margin_front_back = 1; // mm, gap from the front and back edges to the outermost spike bases
edge_margin_left_right = 1; // mm, gap from the left and right edges to the outermost spike bases

/* [Edge lean] */
lean_angle            = 25;    // degrees from vertical, 0 = no lean
edge_band             = 30;    // mm, spikes with their centre this close to the edge lean outwards
lean_front_back_edges = true;  // rectangle only, lean spikes along the front and back edges
lean_left_right_edges = true;  // rectangle only, lean spikes along the left and right edges

/* [Hidden] */
$fn = 48;

module plate_2d() {
    if (elliptical_plate) scale([plate_width / 2, plate_length / 2]) circle(r = 1);
    else square([plate_width, plate_length], center = true);
}

linear_extrude(plate_thickness) plate_2d();

for (p = spike_points(elliptical_plate, plate_width, plate_length, pitch, bottom_diameter / 2,
                      edge_margin_front_back, edge_margin_left_right, stagger))
    translate([p[0], p[1], plate_thickness - 0.01])  // tiny overlap so the union is solid
        spike(bottom_diameter, top_diameter, height + 0.01, lean_angle,
              edge_dir(elliptical_plate, p[0], p[1], plate_width, plate_length, edge_band,
                       lean_front_back_edges, lean_left_right_edges));
