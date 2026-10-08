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

// ---- Rectangular plates: a grid ----

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

function grid_points(width, length, pitch, radius,
                     margin_front_back, margin_left_right, stagger) =
    let(xs = axis_centres(width, pitch, radius, margin_left_right),
        ys = axis_centres(length, pitch, radius, margin_front_back))
    [for (j = [0 : len(ys) - 1])
        for (x = stagger && j % 2 == 1 && len(xs) > 1 ? midpoints(xs) : xs)
            [x, ys[j]]];

// ---- Elliptical plates: concentric rings that follow the rim ----
//
// The outermost ring is an ellipse that keeps the margins clear of the rim.
// Each ring inside it is a scaled copy, stepped in by `pitch` along the
// narrow direction, with spikes spaced evenly along its length. The innermost
// ring is replaced by a short row along the long axis when it is too small to
// hold a ring (a single centre spike on a circle).

function ellipse_point(a, b, degrees) = [a * cos(degrees), b * sin(degrees)];

// Cumulative length along an ellipse, sampled at `steps` angles (tail recursive).
function arc_lengths(a, b, steps = 360, i = 1, acc = [0]) =
    i > steps ? acc :
    arc_lengths(a, b, steps, i + 1,
        concat(acc, [acc[i - 1] + norm(ellipse_point(a, b, i * 360 / steps)
                                       - ellipse_point(a, b, (i - 1) * 360 / steps))]));

// The angle at which a fraction f (0..1) of the way round has been covered.
function angle_at_fraction(lengths, f) =
    let(
        steps = len(lengths) - 1,
        target = f * lengths[steps],
        i = min(len([for (l = lengths) if (l <= target) 1]) - 1, steps - 1)
    )
    (i + (target - lengths[i]) / (lengths[i + 1] - lengths[i])) * 360 / steps;

// n spikes spread evenly along the ellipse of semi-axes (s * a, s * b).
// phase (0 to 0.5) shifts them round by that fraction of a spacing.
function ring_points(lengths, a, b, s, n, phase) =
    [for (j = [0 : n - 1])
        ellipse_point(s * a, s * b, angle_at_fraction(lengths, (j + phase) / n))];

function min_chord(points) =
    min([for (j = [0 : len(points) - 1])
            norm(points[j] - points[(j + 1) % len(points)])]);

// Largest count up to n whose neighbouring spikes are at least `pitch` apart
// in a straight line (the chord is slightly shorter than the arc).
function ring_count(lengths, a, b, s, phase, pitch, n) =
    n <= 1 ? max(n, 0) :
    min_chord(ring_points(lengths, a, b, s, n, phase)) >= pitch - 1e-6 ? n :
    ring_count(lengths, a, b, s, phase, pitch, n - 1);

// A centred row of spikes along the long axis, `pitch` apart.
function axis_row(a, b, s, pitch) =
    let(
        half_length = s * max(a, b),
        n = floor(2 * half_length / pitch + 1e-9) + 1
    )
    [for (i = [0 : n - 1])
        let(offset = (i - (n - 1) / 2) * pitch) a >= b ? [offset, 0] : [0, offset]];

function elliptical_points(width, length, pitch, radius,
                           margin_front_back, margin_left_right, stagger) =
    let(
        a = width / 2 - radius - margin_left_right,    // semi-axes of the outer ring
        b = length / 2 - radius - margin_front_back
    )
    a < 0 || b < 0 ? [] :
    let(
        m = min(a, b),
        lengths = arc_lengths(a, b),
        perimeter = lengths[len(lengths) - 1]
    )
    [for (k = [0 : floor(m / pitch + 1e-9)])
        let(
            narrow = m - k * pitch,           // narrow semi-axis of this ring
            s = m > 0 ? narrow / m : 1,       // scale relative to the outer ring
            phase = stagger && k % 2 == 1 ? 0.5 : 0
        )
        each narrow < pitch / 2 - 1e-9
            ? axis_row(a, b, s, pitch)
            : ring_points(lengths, a, b, s,
                  ring_count(lengths, a, b, s, phase, pitch, floor(s * perimeter / pitch + 1e-9)),
                  phase)];

// All [x, y] spike positions for the plate.
// stagger = true offsets every other row (rectangle) or ring (ellipse) by
// half a spacing.
function spike_points(elliptical, width, length, pitch, radius,
                      margin_front_back, margin_left_right, stagger = false) =
    elliptical
        ? elliptical_points(width, length, pitch, radius,
                            margin_front_back, margin_left_right, stagger)
        : grid_points(width, length, pitch, radius,
                      margin_front_back, margin_left_right, stagger);

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
