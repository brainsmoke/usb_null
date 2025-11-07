
include <case_base.scad>

module ffc_slot()
{
	graft()
	graft_remove()
	on_pcb()
	cube([13,20,1], center=true);
}

case() {
	at_back() ffc_slot();
};

