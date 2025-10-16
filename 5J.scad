include <BOSL2/std.scad>

depth = 68.95; //mm or 2.75 inches
width = 127; //mm or 5 inches
cut = 10; //mm
angle = 30; //degrees

b5J(depth,width,cut,angle);


// like linear extrude, but instead of linearly
// applying the scaling from 0 to 1, apply it exponentially.
module exp_extrude(height, scaling, slices) {
  dh = height/slices;
  for(i = [1:slices - 1]) {
    dt = 1-pow(2,-20*((slices-i)/slices));
    step = i*dh;
    translate([0, 0, step]) {
      scale([dt, dt, 1]){  // Note1
        linear_extrude(height=dh,slices=1){
          children([0:$children-1]);
        }
      }
    }
  }
}

module bez_extrude_3d(height, bez, slices) {
  dh = height/slices;
  for(i = [0:slices - 2]) {
    hull(){
        scale_z = bezier_points(bez,i/slices)[0];
        scale_xy = bezier_points(bez,i/slices)[1];
        dy = (1-scale_xy)*0.1+0.9;
        dz = (scale_z)*(height);
        dx = pow(dy,4);
        translate([0, 0, dz]) {
          scale([dx, dy, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        scale_z1 = bezier_points(bez,(i+1)/slices)[0];
        scale_xy1 = bezier_points(bez,(i+1)/slices)[1];
        dy1 = (1-scale_xy1)*0.1+0.9;
        dz1 = (scale_z1)*(height);
        dx1 = pow(dy1,4);
        translate([0, 0, dz1]) {
          scale([dx1, dy1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module b5J(d,w,c,a)
{
    
    difference()
    {
        union()
        {
            difference(){b5I(d,w); b5J_cut(w,c,a);}
    
            difference() {b5J_edge_rounded(d,w,c,a); translate([0,0,-max(w,d)]) cube(max(w,d)*2,center=true);}
        }
        translate([0,0,-6]) union()
        {
            for (i=[1,-1])
            {
                translate([0,w/4*i,d]) rotate([180,0,0]) screw10();
            }
            translate([-w/4,0,d]) rotate([180,0,0]) screw10();
        }
    }

    
    module b5J_cut(w,c,a)
    {
        translate([c,-w/2,0]) rotate([0,a,0]) cube(w);
    }
    
    
    module b5J_edge_rounded(d,w,c,a)
    {
//        bez = [[0,0],[0.5,0.25],[1,0.5],[1,1]];
        bez = [[0,0],[1,0.2],[1,1]];
//        !debug_bezier(bez*50, N=len(bez)-1);
        translate([c,0,0]) rotate([90-a,0,-90]) mirror([0,0,1])
        {
            bez_extrude_3d(10,bez,15)
            {
            b5J_edge(d,w,c,a);
            }
        }
    }
    
    module b5J_edge(d,w,c,a)
    {
        translate([-w/2,0,0]) rotate([-90,0,0]) rotate([0,-a,-90]) translate([-c,w/2,0])
        {
            intersection()
            {
                translate([c,-w/2,0]) rotate([0,a,0]) cube([1,w,w]);
                b5I(d,w);
            }
        }
    }

    module b5I(d,w)
    {
        w = w*0.95; //offset for bezier curve (figure out math for this)
        bez = [[0,d],[d,d], [w/2*0.9+(0.5)*d/2,0+(0.87)*d/2],[w/2*0.9,0]];
    //    debug_bezier(bez, N=len(bez)-1);
        hull(){
                rotate_extrude($fn=200){
                    intersection(){
                        stroke(bezpath_curve(bez,splinesteps=50));
                        square(1000);
                    }
                }
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

module screw10()
{
    length = in2mm(4);
    gran = 100;
    screw_sink = 500;
    union()
    {
        translate([0,0,-screw_sink])
        color("magenta")
        cylinder(d1=13, d2=13, h=screw_sink, $fn=gran);  //sink  
        color("red")
        cylinder(d1=13, d2=6, h=4.15, $fn=gran);  //head
  
        cylinder(d1=6 , d2=6 , h=length, $fn=gran); //thread
 
    }
}