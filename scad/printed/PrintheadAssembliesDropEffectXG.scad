include <PrintheadAssemblies.scad>
use <PrintheadExtras.scad>

include <X_CarriageDropEffectXG.scad>

//!1.
//
module Printhead_DropEffect_XG_assembly() pose(a=[55, 0, 25 + 180])
assembly("Printhead_DropEffect_XG", big=true) {

    stl_colour(pp4_colour)
        rotate([-90, 0, 0])
            X_Carriage_DropEffect_XG_stl();
    X_Carriage_DropEffect_XG_hardware();
    if (!exploded())
        printheadWiring("DropEffectXG");
}

module printheadHotendSideDropEffectXG(rotate=0, explode=0, t=undef, accelerometer=false, boltLength=25) {
    screwType = hs_cap;
    boreDepth = xCarriageBoreDepth();

    printheadHotendSide(rotate=rotate, explode=explode, t=t, accelerometer=accelerometer, screwType=screwType, boltLength=boltLength, boreDepth=boreDepth)
        Printhead_DropEffect_XG_assembly();
}

