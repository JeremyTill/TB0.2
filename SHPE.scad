include <BOSL2/std.scad>

depth = 0.75; //inches
width = 2.25; //inches
height = 4.75; //inches

SHPE(in2mm(depth),in2mm(width),in2mm(height));

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

module func_extrude_3d(height, f, slices) {
  f_x=f[0];
  f_y=f[1];
  f_z=f[2];
  dh = height/slices;
  for(i = [0:slices-2]) {
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

module path_scale_extrude(path) {
    slices = len(path);
    tangents = path_tangents(path);

    for (i = [0:slices-2])
    {
        step(i){
            children([0:$children-1]);
        }
    }
    
    module step(i) {
        z = path[i][0];
        dz = path[i+1][0]-path[i][0];
        scale([path[i][1],1,1]) translate([0,0,z])
        {
            linear_extrude(dz+1)
            children([0:$children-1]);
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

module SHPE(d,w,h)
{
//    ball(d,w);
//    incut();
    w = w*1.1;
    
    
    difference()
    {
        difference(){ ball(d,w); incut();}
        
        #translate([0,0,-2]) union()
        {
            for (y=[h/4,-h/4])
            translate([0,y,d]) rotate([180,0,0]) screw8();
        }
    }
    
    %cube([30,1,30]);
    %cube([100,1,10]);
    
    
    module incut()
    {
        rt_m = 0.75;
        scale = 0.3;
        w_i = w/2+scale*d*1.8;
        
        //INCUT RISE
        bez1 = [[0,0.95],[d*0.5,1.2],[d*0.5,1.2],[d,0.75]];
//        !rotate([90,0,0]) debug_bezier(bez1*50, N=len(bez1)-1);
        path = bezpath_curve(bez1,N=len(bez1)-1,splinesteps=100);
        
        // INCUT SWEEP
        L = function (x) min(max(x,1-rt_m),rt_m);
        bez = [[-1,0],[0,1.6],[1,0]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        f_x = function (x) bezier_points(bez,L(x))[1]*w_i;
        f_y = function (x) bezier_points(bez,L(x))[0]*h/2*w_i/(w/2);
        f_z = function (x) 1;
        
        for(x=[0,1]) {
            mirror([x,0,0])
            path_scale_extrude(path) func_sweep_xy([f_x,f_y,f_z],100)
            {
                rotate([0,10,0])
                scale([scale,scale,1])
                circle(d,$fn=100);
            }
        }
    }
    
    module incut_old()
    {
        rt_m = 0.75;
        scale = 0.3;
        w_i = w/2+scale*d*1.8;
        
        L = function (x) min(max(x,1-rt_m),rt_m);
        
        bez = [[-1,0],[0,1.6],[1,0]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        f_x = function (x) bezier_points(bez,L(x))[1]*w_i;
        f_y = function (x) bezier_points(bez,L(x))[0]*h/2*w_i/(w/2);
        f_z = function (x) 1;
        
        for(x=[0,1])
        {
        mirror([x,0,0])
            func_sweep_xy([f_x,f_y,f_z],50)
            {
                rotate([0,10,0])
                scale([scale,scale,1])
                sphere(d,$fn=100);
            }
        }
    }
    
    module ball(d,w)
    {
//        bez = [[0,0],[0,0.25],[0,1],[0.4,1],[0.75,1],[1,1]];
        bez = [[0,0],[-0.5,0.2],[0.8,1.5],[1,1]];
//        !rotate([90,0,0]) debug_bezier(bez*50, N=len(bez)-1);
        
        f_x = function (x) min(1-bezier_points(bez,x)[0],1);
        f_y = function (x) min((1-bezier_points(bez,x)[0]),1)*h/w;
        f_z = function (x) min((bezier_points(bez,x)[1]),1);
        func_extrude_3d(d,[f_x,f_y,f_z],50)
        {
            cylinder(1,w/2,w/2,$fn=200);
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