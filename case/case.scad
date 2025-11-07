
include <case_base.scad>

preview()
{
	pcb();
	on_pcb()
	{
		at_front() usb_c();
		at_back() usb_c();
	}
}

module features()
{
	on_pcb() at_front() usb_c_keepout();
	on_pcb() at_back() usb_c_keepout();
}

case()
{
	features();
}

next() flip() top()
{
	features();

	translate([9,0,0])
	on_top()
	rotate([0,0,180])
	case_button();

	translate([21,20,0])
	on_top()
	case_button();


};
