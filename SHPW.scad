include <BOSL2/std.scad>

depth = 19.05; //mm or 0.75 inches
width = 82.55; //mm or 3.25 inches
height = 114.3; //mm or 4.5 inches

SHP(depth,width,height);


module SHP(d,w,h)
{
    r = d/2;
    c = d/5; //mm
    
    difference()
    {
        difference(){ base(); incut();}
        
        #translate([0,0,0]) union()
        {
            for (x=[w/4,w*3/4]) for (y=[h/4,h*3/4])
            translate([x,y,d]) rotate([180,0,0]) screw8();
        }
    }
    
    module incut()
    {
        rt_m = 0.9;
        scale = 0.4;
//        translate([0,h*(1-rt_m)/2,0])
//        rotate([-90,0,0])
        scale([1,1,0.9])
        #for (x=[-scale*d*0.5,w+scale*d*0.5])
        {
            translate([x,0,0])
            rotate([-90,0,0])
            scale([scale,1,1])union()
            {
                translate([0,0,h*(1-rt_m)/2+d]) cylinder(h*rt_m-d*2,d,d,$fn=200);
                translate([0,0,h*(1-rt_m)/2+d]) sphere(d,$fn=200);
                translate([0,0,h*(rt_m)/2+2*d]) sphere(d,$fn=200);
            }
        }
    }
    
    module base()
    {
        intersection()
        {
            hull()
            for ( x = [0+r-c,w-r+c], y = [0+r,h-r], z = [0,d-r] )
            {
                translate([x,y,z]) sphere(r,$fn=100);
            }
            cube([w,h,d],center=false);
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