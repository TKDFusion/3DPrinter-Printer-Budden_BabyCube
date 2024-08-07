//! Displays a reduced implementation to focus on the coreXY part.

include <../scad/global_defs.scad>

include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>
use <NopSCADlib/utils/core_xy.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>

include <../scad/utils/carriageTypes.scad>
include <../scad/utils/CoreXYBelts.scad>
use <../scad/utils/printParameters.scad>

use <../scad/printed/BackFaceAssemblies.scad>
use <../scad/printed/LeftAndRightFaceAssemblies.scad>
use <../scad/printed/PrintheadAssemblies.scad>
use <../scad/printed/PrintheadAssembliesE3DV6.scad>
use <../scad/printed/TopFaceAssemblies.scad>
use <../scad/printed/XY_IdlerBracket.scad>
include <../scad/printed/XY_Motors.scad>
include <../scad/printed/XY_MotorMountCF.scad>
use <../scad/printed/X_Carriage.scad>
use <../scad/printed/X_CarriageAssemblies.scad>
use <../scad/printed/Y_CarriageAssemblies.scad>

use <../scad/Parameters_Positions.scad>


t=2;

module CoreXY() {

    echoPrintSize();
    echo(coreXY_drive_pulley_x_offset=coreXY_drive_pulley_x_alignment(coreXY_type()));
    echo(coreXYSeparation=coreXYSeparation());

    CoreXYBelts(carriagePosition(), show_pulleys=[1, 0, 0]);
    translate([0, carriagePosition(t).y - carriagePosition().y, 0])
        yCarriageLeftAssembly(_xyNEMA_width);
    translate([0, carriagePosition(t).y - carriagePosition().y, 0])
        yCarriageRightAssembly(_xyNEMA_width);
    if (_useCNC) {
        XY_Idler_Bracket_Left_assembly();
        XY_Idler_Bracket_Right_assembly();
        XY_Motor_Mount_Left_CF_assembly();
        XY_Motor_Mount_Right_CF_assembly();
    } else {
        XY_Idler_Left_assembly();
        XY_Idler_Right_assembly();
        //Left_Face_assembly();
        //Right_Face_assembly();
        //Back_Face_Stage_1_assembly();
    }
    xRail(carriagePosition(t), carriageType(_xCarriageDescriptor), _xRailLength, carriageType(_yCarriageDescriptor));
    //let($hide_bolts=true)
    printheadBeltSide(t=t);
    printheadHotendSide(t=t);
    *xRailCarriagePosition(carriagePosition(), rotate=0) {// rotate 180 to make it easier to see belts
        *rotate([0, 90, 0])
            X_Carriage_stl();
        X_Carriage_assembly();
        //xCarriageBeltFragments(carriageType(_xCarriageDescriptor), coreXY_belt(coreXY_type()), beltOffsetZ(), coreXYSeparation().z, coreXY_upper_belt_colour(coreXY_type()), coreXY_lower_belt_colour(coreXY_type()));
    }
}

if ($preview)
    rotate($vpr.z == 315 ? -90 + 30 : 0)
        translate([-eX/2, -eY/2, -coreXYPosBL(_xyNEMA_width).z])
            CoreXY();


/*
module XY_Motor_Mount_Left_assembly()
assembly("XY_Motor_Mount_Left") {

    rotate([90, 0, 90]) {
        XY_MotorUpright(NEMA_type, left=true);
        XY_MotorUprightHardware(NEMA_type, left=true);
    }
}

module XY_Motor_Mount_Right_assembly()
assembly("XY_Motor_Mount_Right") {

    translate([eX + 2*eSizeX, 0, 0]) {
        rotate([90, 0, 90])
            mirror([0, 0, 1]) {
                XY_MotorUpright(NEMA_type, left=false);
                XY_MotorUprightHardware(NEMA_type, left=false);
        }
    }
}
*/

module XY_Idler_Left_assembly()
assembly("XY_Idler_Left") {

    rotate([90, 0, 90]) {
        coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
        translate([0, coreXYPosBL.z + coreXYSeparation().z, 0])
            stl_colour(pp1_colour)
                XY_IdlerBracket(coreXYPosBL, _xyNEMA_width);
        XY_IdlerBracketHardware(coreXYPosBL);
    }
}

module XY_Idler_Right_assembly()
assembly("XY_Idler_Right") {

    translate([eX + 2*eSizeX, 0, 0])
        rotate([90, 0, 90])
            mirror([0, 0, 1]) {
                coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
                translate([0, coreXYPosBL.z + coreXYSeparation().z, 0])
                    stl_colour(pp1_colour)
                        XY_IdlerBracket(coreXYPosBL, _xyNEMA_width);
                XY_IdlerBracketHardware(coreXYPosBL);
            }
}
