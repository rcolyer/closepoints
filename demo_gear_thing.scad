// Created in 2021 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/


use <closepoints.scad>


function GearRotXY(t) = RotZ(360*t);
function GearRotXZ(t) = RotY(8*360*t);
function Ellipse(t) = Translate([50*cos(360*t), 40*sin(360*t), 0]);

function PathMatrix(t) = AffMerge([Ellipse(t), GearRotXY(t), GearRotXZ(t)]);

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

