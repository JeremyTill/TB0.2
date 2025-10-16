include <BOSL2/std.scad>

depth = 50.8; //mm or 2 inches
width = 101.6; //mm or 4 inches

b4(depth,width);


module b4(d,w)
{
    difference()
    {
        ball();
        
        translate([0,0,-3]) union()
        {
            for (i=[1,-1])
            {
                translate([0,w/4*i,d]) rotate([180,0,0]) screw10();
                translate([w/4*i,0,d]) rotate([180,0,0]) screw10();
            }
        }
    }
    
    
    module ball()
    {
        w = w*0.95; //offset for bezier curve (figure out math for this)
        bez = [[0,d],
            [d,d], 
            [w/2*0.9+(0.5)*d/2,d*0.8],
            [w/2*0.8,0]];
//!     union(){debug_bezier(bez, N=len(bez)-1); translate([0,32,0]) square([w/2,1]);}
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