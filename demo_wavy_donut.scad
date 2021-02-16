// Created in 2021 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/

use <closepoints.scad>


// [Scale X]	        [Shear X along Y]	[Shear X along Z]	[Translate X]
// [Shear Y along X]	[Scale Y]	        [Shear Y along Z]	[Translate Y]
// [Shear Z along X]	[Shear Z along Y]	[Scale Z]	        [Translate Z]
// or rotation matrix [[cos,-sin],[sin,cos]] in the 2 axes for a plane.
function PathMatrix(t) =
  [[cos(t*360), -sin(t*360), 0, 50*cos(t*360)],
   [sin(t*360),  cos(t*360), 0, 40*sin(t*360)],
   [         0,           0, 1,             0]];

function ThePolygon(t) =
  [for (a=[0:2:359.99])
    (5+5*(1+cos(8*t*360))/2)*[cos(a), 0, -sin(a)]
  ];


pointarrays =
  [for (t=[0:0.002:0.99999])
    [for (p=ThePolygon(t))
      Affine(PathMatrix(t), p)
    ]
  ];

CloseLoop(pointarrays);

