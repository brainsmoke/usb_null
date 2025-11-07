e=.0001;
b=1; // Big value which can be used in difference operations instead of e
     // to prevent render glitches.
$fn=48;
padding=5;

use <graft.scad>
use <usb.scad>
use <grid.scad>
use <button.scad>

has_buttons=true;
has_dfu_button=true;
has_leds=true;

hole_dist_x = 30;
hole_dist_y = 20;

inner_radius = 4;
pcb_radius = 3.5;
pcb_thickness = .8;
pcb_screw_hole_diameter = 3.2;
silkscreen_thickness = .1;
wall_thickness = 1;
bottom_thickness = .6;
top_thickness = .6;
total_height = 7;
button_height=2;
led_height = 1.2;

top_edge_height = 1.4;
top_edge_thickness = 1.;
top_edge_margin = 0.;

leg_height = 1.;
leg_thickness = 1.2;

funnel_top_radius = 3.2;
funnel_top_height = 3;

usb_c_board_offset=2.5 ;

/* (countersunk) screw specs */
thread = 3;

head_diameter = 5.54;
head_thickness = 1.86;
screw_clearance = .2;

button_pitch=4*2.54;
button_w=5;
button_d=5;
n_buttons=3;

outer_radius = inner_radius+wall_thickness;
screw_grab_radius = (thread*0.9)/2;
screw_loose_radius = (thread/0.9)/2;
funnel_top_inner_radius = funnel_top_radius-leg_thickness;
component_z = bottom_thickness+leg_height+pcb_thickness;

button_depth = total_height-component_z-button_height;

dfu_button_pos = [ 17, 0 ];
dfu_button_angle = 180;

grid_x_off = 0;
grid_y_off = 0;
grid_rows = 4;
grid_cols = 7;
grid_pitch = 10;
grid_width = .8;
grid_height_bottom = .6;
grid_height_top = 1.4;

light_pipe_diameter = 2.2;
light_pipe_border = 1.2;
light_pipe_base_border = 3.2;
light_pipe_depth = total_height-component_z-led_height;
light_pipe_base_height = light_pipe_depth/3;


module preview()
{
	if ($preview) children();
}

module on_pcb()
{
	translate([0,0,component_z]) children();
}

module on_top()
{
	translate([0,0,total_height]) children();
}

module usb_c(margin=0)
{
	translate([0,-usb_c_board_offset,0]) 
	usb_c_type_c31_m12(margin) usb_c_plug(margin);
}

module usb_c_keepout()
{
	graft()
	graft_remove()
	usb_c(margin=.5);
}

module at_front()
{
	translate([-pcb_radius,hole_dist_y/2,0]) rotate([0,0,90])  children();
}

module at_back()
{
	translate([hole_dist_x+pcb_radius,hole_dist_y/2,0]) rotate([0,0,-90])  children();
}

module at_holes()
{
	for (x = [0, hole_dist_x])
		for (y = [0, hole_dist_y])
			translate([x,y,0])
				children();
}

module case_shape(height, radius)
{
	hull()
		at_holes()
			cylinder(height, r=radius);
}

module screw_shape(padding=0, bottom_epsilon=0, top_epsilon=0)
{
	x = head_diameter/2 - screw_loose_radius;
	y = head_thickness;
	dz = (sqrt(x*x+y*y)/x - y/x)*padding;

	x2 = funnel_top_inner_radius - screw_grab_radius;
	y2 = funnel_top_height;
	dz2 = (sqrt(x*x+y*y)/x - y/x)*padding;

	path = [
		[0, -bottom_epsilon],
		[padding+head_diameter/2, -bottom_epsilon],
		[padding+head_diameter/2, screw_clearance+dz],
		[padding+screw_loose_radius, screw_clearance+head_thickness+dz],
		[padding+screw_loose_radius, bottom_thickness+leg_height+pcb_thickness/2],
		[padding+screw_grab_radius, bottom_thickness+leg_height+pcb_thickness/2],
		[padding+screw_grab_radius, total_height-top_thickness-funnel_top_height-dz2],
		[padding+funnel_top_inner_radius, total_height-top_thickness+top_epsilon],
		[0, total_height-top_thickness+top_epsilon],

 ];

	rotate_extrude() polygon(path);
}

module leg()
{
	graft()
	{
		graft_add()
		intersection()
		{
			screw_shape(leg_thickness, bottom_epsilon=b, top_epsilon=b);
			translate([0,0,e]) cylinder(leg_height+bottom_thickness-e, r=leg_thickness+head_diameter/2+1); 
		}

		graft_remove()
		screw_shape(0, bottom_epsilon=b);
	}
}

module screw_guide()
{
	graft()
	{
		graft_add()
		intersection()
		{
			screw_shape(leg_thickness);
			translate([0,0,component_z])
			cylinder(total_height-component_z-e, r=max(screw_loose_radius,funnel_top_inner_radius)+leg_thickness+1);
		}
		graft_remove()
		screw_shape(0, bottom_epsilon=b);
	}
}


module pcb()
{
	difference()
	{
		union()
		{
			color("green")
			translate([0,0,component_z-pcb_thickness])
			case_shape(pcb_thickness, pcb_radius);
		}

		union()
		{
			translate([0,0,component_z-pcb_thickness-b])
			at_holes()
			cylinder(pcb_thickness+2*b, r=pcb_screw_hole_diameter/2);
		}
	}
}

module case()
{
	graft()
	{
		at_holes() leg();

		graft_base()
		{
			difference()
			{
				case_shape(total_height-top_thickness, outer_radius);
				translate([0,0,bottom_thickness])
				case_shape(total_height-top_thickness, inner_radius);
			}
			width = max( 2*outer_radius + hole_dist_x, grid_cols * grid_pitch + grid_x_off*2);
			depth = max( 2*outer_radius + hole_dist_y, grid_rows * grid_pitch + grid_y_off*2);

            if (grid_height_bottom > 0)
			intersection()
			{
				translate([0,0,-e])
				case_shape(total_height+2*e, (outer_radius+inner_radius)/2);

				translate([-(width-hole_dist_x)/2+e,-(depth-hole_dist_y)/2+e,bottom_thickness-e])
				grid(width-e*2, depth-e*2, grid_height_bottom+e, grid_rows, grid_cols, grid_pitch, bar_width=grid_width, x_off=grid_x_off, y_off=grid_y_off);
			}
		}
		children();
	}
}

module top()
{
	graft()
	{
		graft_base()
		{
			difference()
			{
				union()
				translate([0,0,total_height-top_thickness])
				{
					case_shape(top_thickness, outer_radius);
					translate([0,0,-top_edge_height])
						case_shape(top_edge_height+top_thickness/2, inner_radius);
				}
				translate([0,0,total_height-top_thickness-top_edge_height-b])
					case_shape(top_edge_height+b, inner_radius-top_edge_thickness+e);
			}

			width = max( 2*outer_radius + hole_dist_x, grid_cols * grid_pitch + grid_x_off*2);
			depth = max( 2*outer_radius + hole_dist_y, grid_rows * grid_pitch + grid_y_off*2);

            if (grid_height_top > 0)
			intersection()
			{
				translate([0,0,-e])
				case_shape(total_height+2*e, inner_radius-top_edge_thickness/2);

				translate([-(width-hole_dist_x)/2+e,-(depth-hole_dist_y)/2+e,total_height-top_thickness-grid_height_top])
				grid(width-e*2, depth-e*2, grid_height_top+e, grid_rows, grid_cols, grid_pitch, bar_width=grid_width, x_off=grid_x_off, y_off=grid_y_off);
			}
		}

		at_holes() screw_guide();
		children();
	}
}

module case_button()
{
	button(button_w, button_d, top_thickness, button_depth);
}

module flip()
{
	translate([ 0, hole_dist_y, total_height]) rotate([180,0,0]) children();
}

module next()
{
	translate([ 0, hole_dist_y+2*outer_radius+padding, 0 ]) children();
}
