include <BOSL2/std.scad>

depth = 69.85; //mm or 2.75 inches
width = 95.25; //mm or 3.75 inches
height = 165.1; //mm or 6.5 inches

BP(depth,width,height);


module BP(d,w,h)
{
    r = in2mm(0.75);
    difference()
    {
        intersection()
        {
            hull() for ( x = [0+r,w-r], y = [0+r,h-r], z = [0,d-r])
            {
                translate([x,y,z]) sphere(r,$fn=100);
            }
            cube([w,h,d],center=false);
        }
        
        #translate([0,0,0]) union()
        {
            for (x=[w/4,w*3/4]) for (y=[h/4,h*3/4])
            translate([x,y,d]) rotate([180,0,0]) screw10();
            translate([w/2,h/2,d]) rotate([180,0,0]) screw10();
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