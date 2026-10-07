// Spike placement, kept separate from the plate shape and the spike itself.
// Everything is centred on the origin. shape is "rect" or "ellipse"
// (an ellipse with w == d is a circle).

// Does a spike of radius r centred at (x, y) fit entirely inside the plate?
function fits(shape, x, y, w, d, r) =
    shape == "rect"
        ? abs(x) <= w / 2 - r + 1e-9 && abs(y) <= d / 2 - r + 1e-9
        : pow(x / (w / 2 - r), 2) + pow(y / (d / 2 - r), 2) <= 1 + 1e-9;

// All [x, y] spike positions on a pitch-spaced grid that fit on the plate.
// stagger = true offsets every other row by half a pitch (denser, hex-like).
function spike_points(shape, w, d, pitch, r, stagger = false) =
    let(
        cols = floor(w / pitch + 1e-9),
        rows = floor(d / pitch + 1e-9),
        ox = cols % 2 == 0 ? 0.5 : 0,   // centre the grid on the plate
        oy = rows % 2 == 0 ? 0.5 : 0,
        n = max(cols, rows)
    )
    [for (j = [-n : n]) for (i = [-n : n])
        let(
            x = (i + ox + (stagger && j % 2 != 0 ? 0.5 : 0)) * pitch,
            y = (j + oy) * pitch
        )
        if (fits(shape, x, y, w, d, r)) [x, y]];

// Unit vector pointing outwards for a spike within `band` mm of the plate
// edge, or [0, 0] for spikes further in. On a rectangle, spikes near a corner
// get a diagonal direction.
function edge_dir(shape, x, y, w, d, band) =
    shape == "rect"
        ? let(
            ex = w / 2 - abs(x) < band ? sign(x) : 0,
            ey = d / 2 - abs(y) < band ? sign(y) : 0,
            n = norm([ex, ey])
          ) n == 0 ? [0, 0] : [ex, ey] / n
        : let(
            a = w / 2, b = d / 2,
            rho = sqrt(pow(x / a, 2) + pow(y / b, 2)),
            g = [x / (a * a), y / (b * b)],
            ng = norm(g)
          ) // first-order estimate of the distance to the edge
            ng == 0 || (1 - rho) * rho / ng >= band ? [0, 0] : g / ng;
