// Spike placement, kept separate from the plate shape and the spike itself.
// Everything is centred on the origin. The plate is `width` along X and
// `length` along Y. shape is "rect" or "ellipse" (an ellipse with
// width == length is a circle).
//
// radius = spike base radius
// margin = gap between the plate edge and the edge of the outermost spike bases

// Centres along one axis of a rectangle of size `extent`. The outer spikes sit
// exactly `margin` from the ends; spacing is stretched slightly so the row
// fills the span, so `pitch` is a minimum.
function axis_centres(extent, pitch, radius, margin) =
    let(
        span = extent - 2 * (radius + margin),
        n = span < 0 ? 0 : floor(span / pitch + 1e-9) + 1
    )
    n == 0 ? [] :
    n == 1 ? [0] :
    [for (i = [0 : n - 1]) -span / 2 + i * span / (n - 1)];

// Midpoints between consecutive entries (the half-offset rows when staggering).
function midpoints(xs) = [for (i = [0 : len(xs) - 2]) (xs[i] + xs[i + 1]) / 2];

// Does a spike of the given radius centred at (x, y) fit on an elliptical
// plate, keeping `margin` clear of the edge?
function fits_ellipse(x, y, width, length, radius, margin) =
    let(a = width / 2 - radius - margin, b = length / 2 - radius - margin)
    a > 0 && b > 0 && pow(x / a, 2) + pow(y / b, 2) <= 1 + 1e-9;

// All [x, y] spike positions for the plate.
// stagger = true offsets every other row by half a spacing (denser, hex-like).
function spike_points(shape, width, length, pitch, radius, margin, stagger = false) =
    shape == "rect"
        ? let(xs = axis_centres(width, pitch, radius, margin),
              ys = axis_centres(length, pitch, radius, margin))
          [for (j = [0 : len(ys) - 1])
              for (x = stagger && j % 2 == 1 && len(xs) > 1 ? midpoints(xs) : xs)
                  [x, ys[j]]]
        : let(
              cols = floor(width / pitch + 1e-9),
              rows = floor(length / pitch + 1e-9),
              ox = cols % 2 == 0 ? 0.5 : 0,   // centre the grid on the plate
              oy = rows % 2 == 0 ? 0.5 : 0,
              n = max(cols, rows)
          )
          [for (j = [-n : n]) for (i = [-n : n])
              let(
                  x = (i + ox + (stagger && j % 2 != 0 ? 0.5 : 0)) * pitch,
                  y = (j + oy) * pitch
              )
              if (fits_ellipse(x, y, width, length, radius, margin)) [x, y]];

// Unit vector pointing outwards for a spike whose centre is within `band` mm
// of the plate edge, or [0, 0] for spikes further in.
// Ellipse: every edge spike leans out, perpendicular to the curve.
// Rectangle: lean_edges picks which edges count:
//   "all"    every edge
//   "width"  the two edges that are `width` long (front and back, at y = +-length/2)
//   "length" the two edges that are `length` long (left and right, at x = +-width/2)
// A spike near a corner only leans away from the edges that count.
function edge_dir(shape, x, y, width, length, band, lean_edges = "all") =
    shape == "rect"
        ? let(
            x_ok = lean_edges == "all" || lean_edges == "length",
            y_ok = lean_edges == "all" || lean_edges == "width",
            ex = x_ok && width / 2 - abs(x) <= band ? sign(x) : 0,
            ey = y_ok && length / 2 - abs(y) <= band ? sign(y) : 0,
            n = norm([ex, ey])
          ) n == 0 ? [0, 0] : [ex, ey] / n
        : let(
            a = width / 2, b = length / 2,
            rho = sqrt(pow(x / a, 2) + pow(y / b, 2)),
            g = [x / (a * a), y / (b * b)],
            ng = norm(g)
          ) // first-order estimate of the distance to the edge
            ng == 0 || (1 - rho) * rho / ng > band ? [0, 0] : g / ng;
