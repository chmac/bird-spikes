// Main part file. Open in OpenSCAD: F5 preview, F6 render.
use <lib/spike.scad>
use <lib/layout.scad>

$fn = 48;

// Plate
shape        = "rect";  // "rect" or "ellipse" (equal width and length = circle)
plate_width  = 200;     // mm, along X
plate_length = 150;     // mm, along Y
plate_thickness = 1;    // mm

// Spikes
bottom_diameter = 5;    // mm
top_diameter    = 3;    // mm, 0 = cone
height          = 40;   // mm
pitch           = 30;   // mm, minimum centre-to-centre spacing (>= bottom_diameter)
edge_margin     = 1;    // mm, gap from the plate edge to the outermost spike bases
stagger         = false; // offset alternate rows

// Edge lean
lean_angle = 30;    // degrees from vertical, 0 = no lean
edge_band  = 30;    // mm: spikes whose centre is this close to the edge lean outwards
                    // (keep it below edge_margin + bottom_diameter/2 + pitch, or a second row leans too)
lean_edges = "all"; // rect only: "all", "width" (the two edges plate_width long)
                    // or "length" (the two edges plate_length long). Ellipses always lean all round.

module plate_2d() {
    if (shape == "rect") square([plate_width, plate_length], center = true);
    else scale([plate_width / 2, plate_length / 2]) circle(r = 1);
}

linear_extrude(plate_thickness) plate_2d();

for (p = spike_points(shape, plate_width, plate_length, pitch, bottom_diameter / 2, edge_margin, stagger))
    translate([p[0], p[1], plate_thickness - 0.01])  // tiny overlap so the union is solid
        spike(bottom_diameter, top_diameter, height + 0.01, lean_angle,
              edge_dir(shape, p[0], p[1], plate_width, plate_length, edge_band, lean_edges));
