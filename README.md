# OpenSCAD ClosePoints Library

<p align="center"><img alt="Demo image" src="./images/demo_images.gif"></p>

This is a general purpose OpenSCAD library for easily creating diverse shapes
by simply creating lists of points which trace out layers in an outline of the
desired shape.  The library consists of modules for creating polyhedrons from
these lists of points, as well as functions to assist in specifying the points
using transformations.

The file names starting with "demo" provide various examples of usage.

# closepoints.scad API

ClosePoints and CloseLoop are the two modules for creating a polyhedron.
ClosePoints is for creating a polyhedron with no holes (e.g., a ball, or a
cup), while CloseLoop is for creating a polyhedron which topologically contains
one hole (e.g., a donut).  To achieve this difference, ClosePoints auto-closes
the top and bottom of the provided layer loops, while CloseLoop connects the
last layer loop to the first layer loop to close the polyhedron.

Following these are a number of functions for working with affine
transformations, which can help significantly in tracing out the surface layers
of a desired polyhedron.

The API is as follows:


```
// This generates a closed polyhedron from an array of arrays of points,
// with each inner array tracing out one loop outlining the polyhedron.
// pointarrays should contain an array of N arrays each of size P outlining
// a closed manifold.  The points must obey the right-hand rule.  Point your
// right-hand thumb in the direction the N point arrays travel, and then the
// P points in the inner arrays must loop in the direction the fingers curl.
// For example, looking down, the P points in the inner arrays are
// counter-clockwise in a loop, while the N point arrays increase in height.
// Points in each inner array do not need to be equal height, but they
// usually should not meet or cross the line segments from the adjacent
// points in the other arrays.
// (N>=2, P>=3)
// Core triangles:
//   [j][i], [j+1][i], [j+1][(i+1)%P]
//   [j][i], [j+1][(i+1)%P], [j][(i+1)%P]
//   Then triangles are formed in a loop with the middle point of the first
//   and last array.  To override this middle closure point, specify a
//   coordinate position for close_top_pt and/or close_bot_pt.
module ClosePoints(pointarrays, close_top_pt=undef, close_bot_pt=undef)

// This generates a looped polyhedron from an array of arrays of points, with
// each inner array tracing out one layer loop outlining the polyhedron.
// pointarrays should contain an array of N arrays each of size P outlining a
// closed manifold.  The points must obey the right-hand rule.  For example,
// looking down, the P points in the inner arrays are counter-clockwise in a
// loop, while the N point arrays increase in height.  Points in each inner
// array do not need to be equal height, but they usually should not meet or
// cross the line segments from the adjacent points in the other arrays.  The
// last layer loop should geometrically lead into the first when it is closed.
// (N>=2, P>=3)
// Core triangles:
//   [j][i], [j+1][i], [j+1][(i+1)%P]
//   [j][i], [j+1][(i+1)%P], [j][(i+1)%P]
module CloseLoop(pointarrays)

// Perform an affine transformation of matrix M on coordinate v.
//
// [Scale X]          [Shear X along Y] [Shear X along Z] [Translate X]
// [Shear Y along X]  [Scale Y]         [Shear Y along Z] [Translate Y]
// [Shear Z along X]  [Shear Z along Y] [Scale Z]         [Translate Z]
// or rotation matrix [[cos,-sin],[sin,cos]] in the 2 axes for a plane.
function Affine(M, v)

// Combine a list of affine transformation matrices into one.
function AffMerge(Mlist)

// Prepare a matrix to rotate around the x-axis.
function RotX(a)

// Prepare a matrix to rotate around the y-axis.
function RotY(a)

// Prepare a matrix to rotate around the z-axis.
function RotZ(a)

// Prepare a matrix to rotate around x, then y, then z.
function Rotate(rotvec)

// Prepare a matrix to translate by vector v.
function Translate(v)

// Prepare a matrix to scale by vector v.
function Scale(v)

// Find the bounding box of pointarrays.
// Returns [[min_x, min_y, min_z], [max_x, max_y, max_z]]
function BBox(pointarrays)
```

