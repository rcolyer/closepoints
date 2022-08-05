// Created 2021-2022 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/


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
module ClosePoints(pointarrays, close_top_pt=undef, close_bot_pt=undef) {
  function recurse_avg(arr, n=0, p=[0,0,0]) = (n>=len(arr)) ? p :
    recurse_avg(arr, n+1, p+(arr[n]-p)/(n+1));

  N = len(pointarrays);
  P = len(pointarrays[0]);
  NP = N*P;
  midbot = is_undef(close_bot_pt) ?
    recurse_avg(pointarrays[0]) :
    close_bot_pt;
  midtop = is_undef(close_top_pt) ?
    recurse_avg(pointarrays[N-1]) :
    close_top_pt;

  faces_bot = [
    for (i=[0:P-1])
      [0,i+1,1+(i+1)%len(pointarrays[0])]
  ];

  loop_offset = 1;

  faces_loop = [
    for (j=[0:N-2], i=[0:P-1], t=[0:1])
      [loop_offset, loop_offset, loop_offset] + (t==0 ?
      [j*P+i, (j+1)*P+i, (j+1)*P+(i+1)%P] :
      [j*P+i, (j+1)*P+(i+1)%P, j*P+(i+1)%P])
  ];

  top_offset = loop_offset + NP - P;
  midtop_offset = top_offset + P;

  faces_top = [
    for (i=[0:P-1])
      [midtop_offset,top_offset+(i+1)%P,top_offset+i]
  ];

  points = [
    for (i=[-1:NP])
      (i<0) ? midbot :
      ((i==NP) ? midtop :
      pointarrays[floor(i/P)][i%P])
  ];
  faces = concat(faces_bot, faces_loop, faces_top);

  polyhedron(points=points, faces=faces, convexity=8);
}


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
module CloseLoop(pointarrays) {
  function recurse_avg(arr, n=0, p=[0,0,0]) = (n>=len(arr)) ? p :
    recurse_avg(arr, n+1, p+(arr[n]-p)/(n+1));

  N = len(pointarrays);
  P = len(pointarrays[0]);
  NP = N*P;

  faces_loop = [
    for (j=[0:N-1], i=[0:P-1], t=[0:1])
      t==0 ?
        [j*P+i, ((j+1)%N)*P+i, ((j+1)%N)*P+(i+1)%P] :
        [j*P+i, ((j+1)%N)*P+(i+1)%P, j*P+(i+1)%P]
  ];

  points = [
    for (i=[0:NP-1])
      pointarrays[floor(i/P)][i%P]
  ];

  polyhedron(points=points, faces=faces_loop, convexity=8);
}


// Perform an affine transformation of matrix M on coordinate v.
//
// [Scale X]          [Shear X along Y] [Shear X along Z] [Translate X]
// [Shear Y along X]  [Scale Y]         [Shear Y along Z] [Translate Y]
// [Shear Z along X]  [Shear Z along Y] [Scale Z]         [Translate Z]
// or rotation matrix [[cos,-sin],[sin,cos]] in the 2 axes for a plane.
function Affine(M, v) = M * [v[0], v[1], v[2], 1];


// Combine a list of affine transformation matrices into one.
function AffMerge(Mlist, i=0) = i >= len(Mlist) ?
  [[1,0,0,0],[0,1,0,0],[0,0,1,0]] :
  let (
    rest = AffMerge(Mlist, i+1),
    prod = Mlist[i] * [rest[0], rest[1], rest[2], [0,0,0,1]]
  )
  [prod[0], prod[1], prod[2]];


// Prepare a matrix to rotate around the x-axis.
function RotX(a) =
  [[     1,      0,       0, 0],
   [     0, cos(a), -sin(a), 0],
   [     0, sin(a),  cos(a), 0]];

// Prepare a matrix to rotate around the y-axis.
function RotY(a) =
  [[ cos(a), 0, sin(a), 0],
   [     0,  1,      0, 0],
   [-sin(a), 0, cos(a), 0]];

// Prepare a matrix to rotate around the z-axis.
function RotZ(a) =
  [[cos(a), -sin(a), 0, 0],
   [sin(a),  cos(a), 0, 0],
   [     0,       0, 1, 0]];

// Prepare a matrix to rotate around x, then y, then z.
function Rotate(rotvec) =
  AffMerge([RotZ(rotvec[0]), RotY(rotvec[1]), RotX(rotvec[2])]);

// Prepare a matrix to translate by vector v.
function Translate(v) =
  [[1, 0, 0, v[0]],
   [0, 1, 0, v[1]],
   [0, 0, 1, v[2]]];

// Prepare a matrix to scale by vector v.
function Scale(v) =
  [[v[0],    0,    0, 0],
   [   0, v[1],    0, 0],
   [   0,    0, v[2], 0]];

// Find the bounding box of pointarrays.
// Returns [[min_x, min_y, min_z], [max_x, max_y, max_z]]
function BBox(pointarrays) = let(
    inf = 1e300*1e300,
    minmax = function(p, a=0, b=0, res=[[inf, inf, inf], [-inf, -inf, -inf]])
      a >= len(p) ? res :
      minmax(p, b >= len(p[a])-1 ? a+1 : a, (b+1) % len(p[a]),
        [[min(res[0][0], p[a][b][0]), min(res[0][1], p[a][b][1]),
          min(res[0][2], p[a][b][2])],
         [max(res[1][0], p[a][b][0]), max(res[1][1], p[a][b][1]),
          max(res[1][2], p[a][b][2])]])
  )
  minmax(pointarrays);

