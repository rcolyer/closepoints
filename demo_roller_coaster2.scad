// Created in 2021 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/

use <closepoints.scad>

// Used to form the track in a complete circle around the z-axis.
function RotZt(t) = RotZ(360*t);

// Provides the variation in height of the roller coaster track.
function hillf(t) = sin(-2*t*360-115)+sin(-3*t*360-57)+2;
function Hills(t) = Translate([0, 0, 20*hillf(t)]);

// Used to tilt the track inward when it is lower down.
// This reuses the hill value as an input.
// Note that this is applied below before rotation around the circle, so
// the rotation in y is always toward the middle.
function RotXZ(t) = let(a = -45*(4 - hillf(t))/4) RotY(a);

// Establishes the radius of the circle.
function ShiftX(t) = Translate([60, 0, 0]);

// Combine all of the above operations, with the rightmost applied first.
function PathMatrix(t) = AffMerge([RotZt(t), Hills(t), ShiftX(t), RotXZ(t)]);

// Defines the cross section of the track.
function ThePolygon(t) =
  [[-5,0,0], [-5,0,3], [-3,0,3], [-3,0,1], [3,0,1], [3,0,3], [5,0,3], [5,0,0]];

pointarrays =
  [for (t=[0:0.002:0.99999])
    [for (p=ThePolygon(t))
      Affine(PathMatrix(t), p)
    ]
  ];

CloseLoop(pointarrays);

// Everything below this point places the animated train on the track.
$fa = 4; $fs = 0.4;

module wheel() {
    color("DimGray")
        rotate_extrude()
            translate([15, 0])
                offset(2)
                    square([3, 12], center = true);
    color("Silver")
        for (a = [0:20:179])
            rotate([90, 0, a])
                scale([0.2, 1, 1])
                    cylinder(r = 4, h = 30, center = true);
}

module train() {
    color("Black") linear_extrude(10, center = true) offset(5) square([40, 200], center = true);
    for (x = [-80, -40, 40, 80]) translate([30, x, 0]) rotate([90, 0, 90]) wheel();
    for (x = [-80, -40, 40, 80]) translate([-30, x, 0]) rotate([90, 0, 90]) wheel();
    translate([0, 0, 22]) {
        color("Red") {
            hull() {
                scale([1, 0.3, 1]) sphere(20);
                translate([0, -100, 0]) scale([1, 0.3, 1]) sphere(20);
            }
            translate([0, -50, 0]) cylinder(r = 6, h = 25);
            translate([0, -50, 25]) sphere(6);
            translate([0, -80, 0]) cylinder(r = 6, h = 40);
            translate([0, -80, 50]) difference() {
                sphere(r = 13);
                translate([0, 0, 25]) cube(50, center = true);
            }
            difference() {
                translate([0, 40, 30]) cube([42, 70, 100], center = true);
                translate([0, 40, 50]) cube([44, 40, 40], center = true);
                translate([0, 55, 25]) cube([36, 90, 100], center = true);
            }
            translate([0, 50, 80]) linear_extrude(8, scale = 1.1) square([42, 90], center = true);
        }
        color("Black") for(x = [-92, -62, -32, -2])
            translate([0, x, 0]) rotate([90, 0, 0]) cylinder(r = 20.2, h = 5);
    }
}

// Reuses the same functions that make the track to orient the train on
// top of the track.  This step does a numerical derivative of the height
// of the track at the train's location to find the slope of the track.
ztilt = atan2(20*(hillf($t+0.002)-hillf($t-0.002)), 60*0.004*6.28);
// Note that multmatrix takes the same form of input as the Affine call
// above, so we can apply these to geometries the same way as points.
multmatrix(AffMerge([RotZt($t), Hills($t), ShiftX($t)]))
  translate([0,0,3])
  rotate([ztilt, 0, 0])
  multmatrix(RotXZ($t))
  scale(0.06) mirror([0,1,0]) translate([0,0,18]) train();

// Train written in 2019 by Torsten Paul <Torsten.Paul@gmx.de>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
