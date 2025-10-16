include <BOSL2/std.scad>

depth = 0.75; //inches
width = 5.5; //inches

FLT(in2mm(depth),in2mm(width));

module bez_extrude_3d(height, bez, slices) {
  dh = height/slices;
  for(i = [0:slices - 2]) {
//    hull() for (j = [i,i+1]) { //This loop makes it nice but hits computation
    hull() {
        scale_z = bezier_points(bez,i/slices)[0];
        scale_xy = bezier_points(bez,i/slices)[1];
        dy = (1-scale_xy)*0.1+0.9;
        dz = (scale_z)*(height);
        dx = pow(dy,1.2);
        translate([0, 0, dz]) {
          scale([dx, dy, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        scale_z1 = bezier_points(bez,(i+1)/slices)[0];
        scale_xy1 = bezier_points(bez,(i+1)/slices)[1];
        dy1 = (1-scale_xy1)*0.1+0.9;
        dz1 = (scale_z1)*(height);
        dx1 = pow(dy1,1.2);
        translate([0, 0, dz1]) {
          scale([dx1, dy1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module func_extrude_3d(height, f, slices) {
  f_x=f[0];
  f_y=f[1];
  f_z=f[2];
  dh = height/slices;
  for(i = [0:slices-2]) {
    hull() {
        dx = f_x(i/slices);
        dy = f_y(i/slices);
//        dz = dh*(slices-i);
        dz = f_z(i/slices);
        translate([0, 0, dz*height]) {
          scale([dx, dy, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        dx1 = f_x((i+1)/slices);
        dy1 = f_y((i+1)/slices);
//        dz1 = dh*(slices-(i+1));
        dz1 = f_z((i+1)/slices);
        translate([0, 0, dz1*height]) {
          scale([dx1, dy1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module FLT(d,w)
{
    c = -2.5;
    a = 0;

//    ball(d,w);
    %translate([-w/2,-w/2,0]) cube([w/2,w,d]); //reference for hold width to adjust cut for edge rounding and angle
    difference()
    {
        intersection() 
        {
            union()
            {
                difference(){ball(d,w); cut(w*2,c,a);}
                edge_rounded(d,w,c,a);
            }
            translate([0,0,max(w,d)]) cube(max(w,d)*2,center=true);
        }
        
        #translate([-w/12,0,-1]) union()
        {
            for (i=[1,-1])
            {
                translate([0,w/4*i,d]) rotate([180,0,0]) screw8();
            }
            translate([-w/4,0,d-4]) rotate([180,0,0]) screw8();
        }
    }
    
    module cut(w,c,a)
    {
        translate([c,-w/2,0]) rotate([0,a,0]) cube(w);
    }
    
    module edge_rounded(d,w,c,a)
    {
//        bez = [[0,0],[0.5,0.25],[1,0.5],[1,1]];
        bez = [[0,0],[1,0.1],[1,1]];
//        !debug_bezier(bez*50, N=len(bez)-1);
        translate([c,0,0]) rotate([90-a,0,-90]) mirror([0,0,1])
        {
            bez_extrude_3d(abs(c),bez,15)
            {
            edge(d,w,c,a);
            }
        }
    }
    
    module edge(d,w,c,a)
    {
        translate([-w/2,0,0]) rotate([-90,0,0]) rotate([0,-a,-90]) translate([-c,w/2,0])
        {
            intersection()
            {
                translate([c,-w/2,0]) rotate([0,a,0]) cube([1,w,w]);
                ball(d,w);
            }
        }
    }
    
    module ball_old(d,w)
    {
        bez = [[0,d],[w/2*0.9,d],[w/2,0]];
    //    !debug_bezier(bez, N=len(bez)-1);
        hull(){
                rotate_extrude($fn=200){
                    intersection(){
                        stroke(bezpath_curve(bez,N=2,splinesteps=50));
                        square(1000);
                    }
                }
        }
    }
    
    module ball(d,w)
    {
//        e = [1/2,1/2,1];
//        f_x = function (x) 1-pow(e[0],pow(1/e[0],3)*x);
        bez = [[0,0],[0.01,0.25],[0.2,1],[0.2,1],[1,1]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) 1-bezier_points(bez,x)[0];
        f_z = function (x) bezier_points(bez,x)[1];
        func_extrude_3d(d,[f_x,f_x,f_z],30)
        {
            cylinder(1,w/2,w/2,$fn=100);
        }
    }
}

function in2mm(inch)= inch*25.4;

module screw8()
{
    length = 141.275;
    gran = 100;
    screw_sink = 500;
    union(){
    translate([0,0,-screw_sink])
    color("magenta")
cylinder(d1=13, d2=13, h=screw_sink, $fn=gran);  //sink  
    color("red")
cylinder(d1=13, d2=5, h=4.15, $fn=gran);  //head
  
cylinder(d1=5 , d2=5 , h=length, $fn=gran); //thread
 
}
}