// Spike placement, kept separate from the plate shape and the spike itself.
// Everything is centred on the origin, viewed from above with X to the right
// and Y away from you. The plate is `width` along X and `length` along Y.
// The front and back edges run along the width (at y = +-length/2); the left
// and right edges run along the length (at x = +-width/2).
// elliptical = true makes the plate an ellipse (a circle if width == length).
//
// radius = spike base radius
// margin_front_back / margin_left_right = gap between those plate edges and
//   the edge of the outermost spike bases

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
// plate, keeping the margins clear of the edge?
function fits_ellipse(x, y, width, length, radius, margin_left_right, margin_front_back) =
    let(
        a = width / 2 - radius - margin_left_right,
        b = length / 2 - radius - margin_front_back
    )
    a > 0 && b > 0 && pow(x / a, 2) + pow(y / b, 2) <= 1 + 1e-9;

// All [x, y] spike positions for the plate.
// stagger = true offsets every other row by half a spacing (denser, hex-like).
function spike_points(elliptical, width, length, pitch, radius,
                      margin_front_back, margin_left_right, stagger = false) =
    !elliptical
        ? let(xs = axis_centres(width, pitch, radius, margin_left_right),
              ys = axis_centres(length, pitch, radius, margin_front_back))
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
              if (fits_ellipse(x, y, width, length, radius,
                               margin_left_right, margin_front_back)) [x, y]];

// Unit vector pointing outwards for a spike whose centre is within `band` mm
// of the plate edge, or [0, 0] for spikes further in.
// Ellipse: every edge spike leans out, perpendicular to the curve.
// Rectangle: only edges whose lean flag is true count, and a spike near a
// corner only leans away from those edges.
function edge_dir(elliptical, x, y, width, length, band,
                  lean_front_back = true, lean_left_right = true) =
    !elliptical
        ? let(
            ex = lean_left_right && width / 2 - abs(x) <= band ? sign(x) : 0,
            ey = lean_front_back && length / 2 - abs(y) <= band ? sign(y) : 0,
            n = norm([ex, ey])
          ) n == 0 ? [0, 0] : [ex, ey] / n
        : let(
            a = width / 2, b = length / 2,
            rho = sqrt(pow(x / a, 2) + pow(y / b, 2)),
            g = [x / (a * a), y / (b * b)],
            ng = norm(g)
          ) // first-order estimate of the distance to the edge
            ng == 0 || (1 - rho) * rho / ng > band ? [0, 0] : g / ng;
