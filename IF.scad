include <BOSL2/std.scad>

d = 19.05; //mm or 0.75 inches
w = 31.75; //mm or 1.25 inches

IF(d,w);


module IF(d,w)
{
    w = w*1.1; //offset for bezier curve (figure out math for this)
    bez = [[0,d],
            [w/2,d], 
            [w/2*1.15,d*0.5],
            [w/2*0.6,0]];
//    !union() {debug_bezier(bez, N=len(bez)-1); translate([0,10,0]) square([33/2,1]);}
    difference(){
        hull(){
                rotate_extrude($fn=200){
                    intersection(){
                    stroke(bezpath_curve(bez,splinesteps=50));
                    square(1000);
                    }
                }
        }
        rotate([180,0,0]) translate([0,0,-(d+1)])screw8();
    }
}



function in2mm(inch)= inch*25.4;

module screw8()
{
    length = 41.275;
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