// Created in 2021 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/

use <closepoints.scad>


function RotZt(t) = RotZ(360*t);

function hillf(t) = sin(-2*t*360-115)+sin(-3*t*360-57)+2;
function Hills(t) = Translate([0, 0, 20*hillf(t)]);

function RotXZ(t) = let(a = -45*(4 - hillf(t))/4) RotY(a);

function ShiftX(t) = Translate([60, 0, 0]);

function PathMatrix(t) = AffMerge([RotZt(t), Hills(t), ShiftX(t), RotXZ(t)]);

function ThePolygon(t) =
  [[-5,0,0], [-5,0,3], [-3,0,3], [-3,0,1], [3,0,1], [3,0,3], [5,0,3], [5,0,0]];

pointarrays =
  [for (t=[0:0.002:0.99999])
    [for (p=ThePolygon(t))
      Affine(PathMatrix(t), p)
    ]
  ];

CloseLoop(pointarrays);

