// Created in 2018 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/

use <closepoints.scad>

layer_step = 0.2;

pedestal_top = 60;
pedestal_ripple = 1;
pedestal_ripple_rad = 4;
pedestal_base_rad = 20;
pedestal_base_thickness = 10;
pedestal_connect_rad = 1.5;

art_top = 30;
art_radial_ripple = 1;
art_height_ripple = 0.2;
art_ztilt_freq = 3;
art_ztilt_fact = 1;
art_radtilt_freq = 1;
art_radtilt_fact = 1;

function OneLayer(rad, ztilt, h_off) =
  [
    for (a=[0:360])
      [ rad*cos(a),
        rad*sin(a),
        art_radtilt_fact*rad*sin(art_radtilt_freq*a) 
        + art_ztilt_fact*ztilt*(cos(art_ztilt_freq*a)+1) + h_off
      ]
  ];

artpointarrays =
  [for (h=[0:layer_step:art_top])
    OneLayer(
      h*abs(sin(art_radial_ripple*360/art_top)+1.1) + pedestal_connect_rad,
      h,
      pedestal_top+pedestal_connect_rad
    )
  ];


function Pedestal(h) =
  let(
    r = pedestal_base_rad*exp(-h*h/pedestal_base_thickness) +
        pedestal_ripple_rad*pow(sin(h*pedestal_ripple*180/pedestal_top),2) +
        pedestal_connect_rad
  )
  [ for (a=[0:360])
      [ r*cos(a), r*sin(a), h ]
  ];

basepointarrays = [for (h=[0:layer_step:pedestal_top]) Pedestal(h)];

ClosePoints(concat(basepointarrays, artpointarrays));

