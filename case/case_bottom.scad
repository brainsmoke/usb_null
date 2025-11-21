
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

