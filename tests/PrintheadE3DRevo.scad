//! Display the print head

include <../scad/global_defs.scad>

include <NopSCADlib/utils/core/core.scad>
//include <NopSCADlib/vitamins/screws.scad>
include <../scad/utils/carriageTypes.scad>

include <../scad/printed/Extras.scad>
use <../scad/printed/BackFace.scad> // for printheadWiring
use <../scad/printed/PrintheadAssemblies.scad>
use <../scad/printed/PrintheadAssembliesE3DRevo.scad>
use <../scad/printed/PrintheadAssembliesE3DV6.scad>
use <../scad/printed/X_Carriage.scad>
use <../scad/printed/X_CarriageE3DRevo.scad>
use <../scad/printed/X_CarriageAssemblies.scad>

include <../scad/utils/CoreXYBelts.scad>
include <../scad/utils/printParameters.scad>
include <../scad/utils/X_Rail.scad>



//$explode = 1;
//$pose = 1;
module Printhead_test() {
    echoPrintSize();
    xCarriageType = carriageType(_xCarriageDescriptor);

    //let($hide_bolts=true)
    translate(-[ eSizeX + eX/2, carriagePosition().y, eZ - yRailOffset(_xyNEMA_width).x - carriage_clearance(xCarriageType) ]) {
        printheadBeltSide(halfCarriage=false);
        printheadHotendSideE3DRevo();
        //printheadHotendSideE3DV6(halfCarriage=false, noPrinthead=true);
        //CoreXYBelts(carriagePosition(), x_gap=2);
        //xRail(carriagePosition(), xCarriageType, _xRailLength, carriageType(_yCarriageDescriptor));
        //bowdenTube(carriagePosition());
        //printheadWiring(carriagePosition());
    }
    //X_Carriage_assembly();
    //let($hide_bolts=true) Printhead_assembly();
}

//let($hide_bolts=true)
if ($preview)
    Printhead_test();