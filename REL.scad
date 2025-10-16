include <BOSL2/std.scad>

depth = 1; //inches
width = 4.5; //inches
height = 3; //inches

RE(in2mm(depth),in2mm(width),in2mm(height));

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

module func_path_extrude(path,foo) {
    slices = len(path);
    tangents = path_tangents(path);
    echo(path);
    echo(tangents);
    for (i = [0:slices-2]) {
        hull()
        {
            translate([path[i][0],path[i][1],0])
                rotate([0,0,atan2(tangents[i][1],tangents[i][0])-90])
                    rotate([90,0,0])
                        linear_extrude(1) 
                            children([0:$children-1]);
            translate([path[i+1][0],path[i+1][1],0])
                rotate([0,0,atan2(tangents[i+1][1],tangents[i+1][0])-90])
                    rotate([90,0,0])
                        linear_extrude(1) 
                            children([0:$children-1]);
        }
    }
}

module func_path_sweep(path,foo) {
    slices = len(path);
    tangents = path_tangents(path);
    echo(path);
    echo(tangents);
    for (i = [0:slices-2]) {
        hull()
        {
            translate([path[i][0],path[i][1],0])
                rotate([0,0,atan2(tangents[i][1],tangents[i][0])-90])
                    rotate([90,0,0])
                        children([0:$children-1]);
            translate([path[i+1][0],path[i+1][1],0])
                rotate([0,0,atan2(tangents[i+1][1],tangents[i+1][0])-90])
                    rotate([90,0,0])
                        children([0:$children-1]);
        }
    }
}

module path_bend(path) {
    slices = len(path);
    tangents = path_tangents(path);

    for (i = [0:slices-2])
    {
        hull()
        {
            translate([path[i][0],0,0]) intersection()
            {
                translate([0,path[i][1],0]) cube([1000,1,1000],center=true);
                children([0:$children-1]);
            }
            
            translate([path[i+1][0],0,0]) intersection()
            {
                translate([0,path[i+1][1],0]) cube([1000,1,1000],center=true);
                children([0:$children-1]);
            }
        }
    }
}

module RE(d,w,h)
{
    c = 2;
    h_e = 2.5;
    a = 0;

    %translate([-h+19,-w/2,0]) cube([h,w,d]); //reference for hold
    d_c = 10;
    bez2 = [[0,-w/2],[d_c,-w/2]*0.8,[d_c,0]*0.8,[d_c,w/2]*0.8,[0,w/2]];
//    !debug_bezier(bez2, N=len(bez2)-1);
    path = bezpath_curve(bez2,N=2,splinesteps=15);
    difference()
    {
        hull()
        {
            path_bend(path)
            {
                RE_straight();
            }
            RE_straight();
        }
        translate([-w/12,0,-1]) union()
        {
            for (i=[1,-1])
            {
                translate([0,w/4*i,d]) rotate([180,0,0]) screw8();
            }
            translate([-w/4,0,d-3.5]) rotate([180,0,0]) screw8();
        }
    }
    
    
    module RE_edge()
    {
        bez = [[0,0],[0.01,0.25],[0.2,1],[0.2,1],[1,1]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) 1-bezier_points(bez,x)[0];
        f_z = function (x) min(bezier_points(bez,x)[1],1-1/d);
        func_extrude_3d(d,[f_x,f_x,f_z],30)
        {
            cylinder(1,w/2,w/2,$fn=100);
        }
    }
    
    module RE_straight()
    {
        bez = [[0,0],[0,4],[1,4]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) 1-bezier_points(bez,x)[0];
        f_y = function (x) 1;
        f_z = function (x) bezier_points(bez,x)[1];
        
        intersection()
        {
            translate([0,0,d/2+1/0.5]) rotate([0,90,0]) 
            translate([-d/8,0,0]) func_extrude_3d(h_e,[f_x,f_y,f_z],30)
            {
                translate([d/8,0,0]) cube([d,w,1],center=true,$fn=100);
            }
            
            ball(d,w);
        }
        difference(){ball(d,w); cut(w*2,0,0);}
    }
    
    module flat()
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
    }
    
    module cut(w,c,a)
    {
        translate([c,-w/2,0]) rotate([0,a,0]) cube(w);
    }
    
    
    
    
    
    module ball(d,w)
    {
        bez = [[0,0],[0.01,0.25],[0.2,1],[0.2,1],[1,1]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) 1-bezier_points(bez,x)[0];
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
    union(){
    translate([0,0,-screw_sink])
    color("magenta")
cylinder(d1=13, d2=13, h=screw_sink, $fn=gran);  //sink  
    color("red")
cylinder(d1=13, d2=5, h=4.15, $fn=gran);  //head
  
cylinder(d1=5 , d2=5 , h=length, $fn=gran); //thread
 
}
}