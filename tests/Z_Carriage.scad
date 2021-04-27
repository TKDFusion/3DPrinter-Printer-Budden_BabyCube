//! Display the Z carriage

use <../scad/printed/Z_Carriage.scad>

include <../scad/Parameters_Main.scad>


//$explode = 1;
//$pose = 1;
module Z_Carriage_test() {
    //Z_Carriage_stl();
    //zCarriage_hardware();
    //Z_Carriage_cable_ties(_printBedSize);
    Z_Carriage_assembly();
    //zCarriage(testing=true);
}

//let($preview=false)
if ($preview)
    Z_Carriage_test();
else
    Z_Carriage_stl();
