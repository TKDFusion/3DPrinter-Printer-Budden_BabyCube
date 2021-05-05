//! Display the print head

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/rails.scad>

use <../scad/printed/Base.scad>
use <../scad/printed/Extras.scad>
use <../scad/printed/PrintheadAssemblies.scad>
use <../scad/printed/X_Carriage.scad>
use <../scad/printed/X_CarriageAssemblies.scad>

use <../scad/utils/carriageTypes.scad>
use <../scad/utils/CoreXYBelts.scad>
use <../scad/utils/printParameters.scad>
use <../scad/utils/X_rail.scad>

use <../scad/Parameters_CoreXY.scad>
include <../scad/Parameters_Main.scad>


NEMA_width = _xyNEMA_width;


//$explode = 1;
//$pose = 1;
module Printhead_test() {
    echoPrintSize();
    xCarriageType = xCarriageType();

    //let($hide_bolts=true)
    translate(-[ eSizeX + eX/2, carriagePosition().y, eZ - yRailOffset(NEMA_width).x - carriage_clearance(xCarriageType) ]) {
        fullPrinthead();
        CoreXYBelts(NEMA_width, carriagePosition(), x_gap=2, show_pulleys=false);
        xRail(xCarriageType(), _xRailLength);
        bowdenTube();
        //Back_Face_assembly();
        //printheadWiring();
    }
    //X_Carriage_assembly();
    //Fan_Duct_stl();
    //X_Carriage_stl();
    //Print_head_assembly();
    //Hotend_Clamp_stl();
    //Hotend_Clamp_hardware();
    //grooveMountClamp(xCarriageType);
    //grooveMountClampHardware();
    //hotEndHolder(xCarriageType());
    //Hotend_Strain_Relief_Clamp_stl();
}

if ($preview)
    Printhead_test();
