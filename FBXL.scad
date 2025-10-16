include <BOSL2/std.scad>

depth = 1.75; //inches
width = 5.5; //inches
height = 3.5; //inches

FB(in2mm(depth),in2mm(width),in2mm(height));

module bez_extrude_3d(height, bez, slices) {
  dh = height/slices;
  for(i = [0:slices - 2]) {
//    hull() for (j = [i,i+1]) { //This loop makes it nice but hits computation
    hull() {
        scale_z = bezier_points(bez,i/slices)[0];
        scale_xy = bezier_points(bez,i/slices)[1];
        dy = (1-scale_xy)*0.1+0.9;
        dz = (scale_z)*(height);
        dx = pow(dy,0.2);
        translate([0, 0, dz]) {
          scale([dx, dy, 1]){  // Note1
            children([0:$children-1]);
          }
        }
      
        scale_z1 = bezier_points(bez,(i+1)/slices)[0];
        scale_xy1 = bezier_points(bez,(i+1)/slices)[1];
        dy1 = (1-scale_xy1)*0.1+0.9;
        dz1 = (scale_z1)*(height);
        dx1 = pow(dy1,0.2);
        translate([0, 0, dz1]) {
          scale([dx1, dy1, 1]){  // Note1
            children([0:$children-1]);
          }
        }
    }
  }
}

module func_extrude_3d(height, f, slices) { //Poorly named, this is func scaling linear extrude
  f_x=f[0];
  f_y=f[1];
  f_z=f[2];
  dh = height/slices;
  for(i = [0:slices-1]) {
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

module path_bend(path,hull=1,dim=[1,0,0],lim=1000) {
    slices = len(path);
    tangents = path_tangents(path);

    if (hull==1) for (i = [0:slices-2])
    {
        hull()
        {
            step(i){
                children([0:$children-1]);
            }
            
            step(i+1){
                children([0:$children-1]);
            }
        }
    }
    
    if (hull==2) for (i = [0:slices-1])
    {
        step(i){
            children([0:$children-1]);
        }
    }
    
    module step(i) {
        translate(dim*path[i][0]) intersection()
            {
                translate([0,path[i][1],0]) cube([lim,1,lim],center=true);
                children([0:$children-1]);
            }
    }
}

module cutZ(z=0){
    intersection()
    {
        translate([0,0,500+z]) cube([1000,1000,1000],center=true);
        children([0:$children-1]);
    }
}

module cutXZ(x=0,z=0){
    intersection()
    {
        translate([500+x,0,500+z]) cube([1000,1000,1000],center=true);
        children([0:$children-1]);
    }
}

module cutYrange(y=[0,100]){
    intersection()
    {
        ysize = abs(y[1]-y[0]);
        translate([0,ysize/2+y[0],0]) cube([1000,ysize,1000],center=true);
        children([0:$children-1]);
    }
}

module FB(d,w,h)
{
    c = -5;
    a = 0;
    %translate([-w/2,-w/2,0]) cube([h,w,d]); //reference for hold
    peak=18;//in2mm(5/8);
    
    difference()
    {
        union()
        {
            crimp_edge();
            difference(){ball(); cut();}
        }
        union()
        {
            translate([0,0,0]) union()
            {
                for (i=[1,-1])
                {
                    translate([-w/12,w/4*i,d]) rotate([180,0,0]) screw10();
                }
                translate([-w/4,0,d]) rotate([180,0,0]) screw10();
            }
        }
    }
    
    
    module crimp_edge()
    {
//        bez_edge = [[0,0],[0,peak],[d/4,peak*0.0],[d/3,0],[d,0]];
//        bez_edge = [[0,0],[peak,0],[peak*0.0,d/4],[0,d/3],[0,d]];
//        bez_edge = [[peak,0],[peak,d/4],[peak,d/3],[0,d/3],[0,d]];
        offset = 25;//in2mm(5/8);
        pf = 1.2;
//        bez_edge = [[peak,0],[peak,offset*2],[0,d-offset*3],[0,d]];
        bez_edge = [[0,0],[peak/4*pf,0],[peak*pf,0],[peak*pf,offset/2],[peak*pf,offset],[peak/4*pf,offset],[0,offset]];
//        !union() {debug_bezier(bez_edge, N=len(bez_edge)-1); #square([18,25]);}
        path1 = bezpath_curve(bez_edge,N=len(bez_edge)-1,splinesteps=25);
        path = concat(path1,[[0,d]]);
        echo(path);
        
        cutXZ(x=min(c,0))
        rotate([-90,0,0]) translate([0,-d,0]) path_bend(path,hull=1)
        {
            translate([0,d,0]) rotate([90,0,0])
            hull()
            {
            edge_rounded();
            translate([-peak-abs(c),0,0]) rotate([90,0,90]) edge();
            }
        }
    }
    
    module edge_rounded()
    {
//        bez = [[0,0],[0.5,0.25],[1,0.5],[1,1]];
//        bez = [[0,0],[1,0.1],[1,1]];
        bez = [[0,0],[0.2,0],[1,0.2],[1,2]];
//        !debug_bezier(bez*50, N=len(bez)-1);
        translate([c,0,0]) rotate([90-a,0,-90]) mirror([0,0,1])
        {
            bez_extrude_3d(abs(c),bez,15)
            {
            edge();
            }
        }
    }
    
    module edge()
    {
        translate([-w/2,0,0]) rotate([-90,0,0]) rotate([0,-a,-90]) translate([-c,w/2,0])
        {
            intersection()
            {
                translate([c,-w/2,0]) rotate([0,a,0]) cube([1,w,w]);
                ball();
            }
        }
    }
    
    module cut()
    {
        translate([c,-w/2,0]) rotate([0,a,0]) cube(w);
    }
    
    module ball()
    {
        bez = [[-0.1,0],[-0.01,0.25],[0.05,1.1],[0.2,1.1],[1,1.3]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) min(1-bezier_points(bez,x)[0],1);
        f_z = function (x) min(bezier_points(bez,x)[1],1-1/d);
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
    union()
    {
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