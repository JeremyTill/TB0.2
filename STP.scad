include <BOSL2/std.scad>

depth = 1; //inches
width = 3.5; //inches
height = 6; //inches

STP(in2mm(depth),in2mm(width),in2mm(height));

module func_extrude_3d(height, f, slices) {
  f_x=f[0];
  f_y=f[1];
  f_z=f[2];
  dh = height/slices;
  for(i = [0:slices-2]) {
    hull() {
        dx = f_x(i/slices);
        dy = f_y(i/slices);
        dz = f_z(i/slices);
        translate([0, 0, dz*height]) {
          scale([dx, dy, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        dx1 = f_x((i+1)/slices);
        dy1 = f_y((i+1)/slices);
        dz1 = f_z((i+1)/slices);
        translate([0, 0, dz1*height]) {
          scale([dx1, dy1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module func_sweep_xy(f, slices) {
  f_x=f[0];
  f_y=f[1];
  f_z=f[2];
  for(i = [0:slices-1]) {
    hull() {
        dx = f_x(i/slices);
        dy = f_y(i/slices);
        dz = f_z(i/slices);
        translate([dx, dy, 0]) {
          scale([1, 1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        dx1 = f_x((i+1)/slices);
        dy1 = f_y((i+1)/slices);
        dz1 = f_z((i+1)/slices);
        translate([dx1, dy1, 0]) {
          scale([1, 1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module STP(d,w,h) {
    
    //log();
    %translate([-in2mm(3.5/2),-h/2,0]) cube([in2mm(3.5),1,d],center=false);
    %translate([-in2mm(2/2),h/2,0]) cube([in2mm(2),1,d],center=false); //reference for hold width to adjust cut for edge rounding and angle
    difference()
    {
        hull() borders();
        
        #translate([0,0,0]) union()
        {
            for (x=[w/6,-w/6])
            translate([x,h/4,d]) rotate([180,0,0]) screw8();
            
            for (x=[w/4,-w/4])
            translate([x,-h/4,d]) rotate([180,0,0]) screw8();
        }
    }
    
    module borders()
    {
        intersection()
        {
            union()
            {
                translate([-50,h/2-in2mm(0.5)*1.8,0])
                rotate([90,0,90])
                linear_extrude(100) tip();
                
                translate([50,-h/2+in2mm(0.5)*1.8,0])
                rotate([90,0,-90])
                linear_extrude(100) tip();
            }
            
            union()
            {
                translate([-w/2+in2mm(0.5),-h/2,0])
                rotate([90,0,180-6])
                linear_extrude(200) edge();
                
                translate([w/2-in2mm(0.5),-h/2,0])
                rotate([90,0,6])
                translate([0,0,-200])
                linear_extrude(200) edge();
            }
        }
    }
    
    module edge()
    {
        intersection()
        {
            bez = [[in2mm(0.5)/4,d],[in2mm(0.5)*1.8,d*0.65],[0,0]];
            stroke(bezpath_curve(bez,N=2,splinesteps=50));
            //square([in2mm(0.5),1]);
            square(100,center=false);
        }
    }
    
    module tip()
    {
        intersection()
        {
            bez = [[0,d],[in2mm(0.5)*1.2,d],[in2mm(0.5)*1.8,0]];
            stroke(bezpath_curve(bez,N=2,splinesteps=50));
            //square([in2mm(0.5),1]);
            square(100,center=false);
        }
    }
    
    module log()
    {
        
//        !debug_bezier(bez, N=len(bez)-1);
        hull() for(y=[-1,1])
        {
            intersection()
            {
                translate([-w/2,((h/2-1)-w/2)*y,0])
                rotate([90,0,90])
                linear_extrude(w)
                log2d();
                
                hull()
                {
                    translate([0,-(h/2-1),0])
                    rotate([90,0,0]) 
                    linear_extrude(1) 
                    log2d();
                    
                    translate([0,h/2,0]) 
                    scale([2/3.5,1,1]) 
                    rotate([90,0,0]) 
                    linear_extrude(1) 
                    log2d();
                }
            }
        }
    }
    
    module log2d() //change to side and tip
    {
        bez = [[0,d*1.1],[w/2*1.2,d],[w/2/1.2,0]];
        intersection(){
            hull() for (x=[0,1])
            {
                mirror([x,0,0])
                stroke(bezpath_curve(bez,N=2,splinesteps=50));
            }
            translate([-500,0,0]) square([1000,d]);
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