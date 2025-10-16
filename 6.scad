include <BOSL2/std.scad>

depth = 63.5; //mm or 2.5 inches
width = 152.4; //mm or 6 inches

b6(depth,width);


module b6(d,w)
{

    difference()
    {
        ball();
        
        translate([0,0,-12]) union()
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