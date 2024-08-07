//! Display the XY motor mounts

include <../scad/global_defs.scad>

include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>

include <../scad/printed/XY_Motors.scad>
include <../scad/printed/XY_MotorMountCF.scad>
use <../scad/printed/BackFaceAssemblies.scad>
use <../scad/printed/LeftAndRightFaceAssembliesCF.scad>
use <../scad/printed/TopFaceAssemblies.scad>

include <../scad/utils/CoreXYBelts.scad>

include <../scad/Parameters_Main.scad>
use <../scad/Parameters_Positions.scad>




//$explode = 1;
//$pose = 1;
module XY_MotorMount_test() {
    //echo(coreXY_drive_pulley_x_alignment=coreXY_drive_pulley_x_alignment(coreXY_type()));
    //echo(leftDrivePulleyOffset=leftDrivePulleyOffset());
    //echo(rightDrivePulleyOffset=rightDrivePulleyOffset());

    CoreXYBelts(carriagePosition(), show_pulleys=[1, 0, 0]);

    //XY_MotorUpright(xyMotorType(), left);
    //XY_MotorMount(xyMotorType(), left, basePlateThickness = 5, offset = basePlateThickness + eZ-coreXYPosBL(NEMA_width(xyMotorType())).z+(left?0:coreXYSeparation().z));
    //XY_MotorMountHardware(NEMA_type);

    //Left_Face_CF_assembly();
    //translate([-eps, 0, 0]) rotate([90, 0, 90]) Left_Face_CF();

    //Back_Face_CF_assembly();
    Back_Face_CF_Stage_1_assembly();
    //translate([0, eY + 2*eSizeY, 0]) rotate([90, 0, 0]) Back_Face_CF();

    //translate_z(eZ - _topPlateThickness + eps) Top_Face_CF();

    XY_Motor_Mount_Left_CF_assembly();
    XY_Motor_Mount_Right_CF_assembly();
    //topFaceMotors(xyMotorType());
}

module topFaceMotors(NEMA_type) {
    NEMA_width = NEMA_width(NEMA_type);
    translate([0, 0, -13]) {
        translate(coreXYPosTR(NEMA_width) + [rightDrivePulleyOffset().x, rightDrivePulleyOffset().y, 0]) {
            rotate(90)
                NEMA(NEMA_type, jst_connector=true);
            translate_z(8)
                #pulley(GT2x20ob_pulley);
        }
        translate([coreXYPosBL(NEMA_width).x, coreXYPosTR(_xyNEMA_width).y, coreXYPosTR(NEMA_width).z] + [leftDrivePulleyOffset().x, leftDrivePulleyOffset().y, 0]) {
            rotate(-90)
                NEMA(NEMA_type, jst_connector=true);
            translate_z(18)
                vflip()
                    #pulley(GT2x20ob_pulley);
        }
    }
}

translate([0, -eY -2*eSizeY, -eZ])
if ($preview)
    XY_MotorMount_test();
