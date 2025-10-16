include <BOSL2/std.scad>

d = 68.95; //mm or 2.75 inches
w = 127; //mm or 5 inches

b5(d,w);


module b5(d,w)
{
    w = w*1.05; //offset for bezier curve (figure out math for this)
    bez = [[0,d],[d,d], [w/2*0.9+(0.26)*d/2,0+(0.97)*d/2],[w/2*0.88,0]];
//    debug_bezier(bez, N=len(bez)-1);
    difference(){
        hull(){
                rotate_extrude($fn=200){
                    intersection(){
                    move_copies(bezier_curve(bez, 1000)) circle(1,$fn=1);
                    square(1000);
                    }
                }
        }
        #translate([0,0,-7]) union()
        {
            for (i=[1,-1])
            {
                translate([0,w/4*i,d]) rotate([180,0,0]) screw10();
                translate([w/4*i,0,d]) rotate([180,0,0]) screw10();
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