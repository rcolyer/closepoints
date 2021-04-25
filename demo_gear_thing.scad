// Created in 2021 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/


use <closepoints.scad>

// Used to rotate the points in a complete circle around the z-axis.
function GearRotXY(t) = RotZ(360*t);
// This spirals the protruding ridges around the donut-shaped ring.
// Note that this rotation around the y-axis is the first operation below.
function GearRotXZ(t) = RotY(8*360*t);
// Establishes the dimensions of the ellipse, setting the distance away
// from the origin.
function Ellipse(t) = Translate([50*cos(360*t), 40*sin(360*t), 0]);

// Combine all of the above operations, with the rightmost applied first.
function PathMatrix(t) = AffMerge([Ellipse(t), GearRotXY(t), GearRotXZ(t)]);

// Defines the cross section of the "gear thing".  The ternary operator
// is used to increase the radius of the cross-section for two sets of
// angle values around the cross-section to establish the protruding
// ridges.
function ThePolygon(t) =
  [for (a=[0:2:359.99])
    ((a < 6 || (a >= 180 && a < 186)) ? 7 : 5)*[cos(a), 0, -sin(a)]
  ];

pointarrays =
  [for (t=[0:0.002:0.99999])
    [for (p=ThePolygon(t))
      Affine(PathMatrix(t), p)
    ]
  ];

CloseLoop(pointarrays);

