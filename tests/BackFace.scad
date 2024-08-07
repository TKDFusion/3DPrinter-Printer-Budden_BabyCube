//! Display the back face

include <NopSCADlib/utils/core/core.scad>
//include <NopSCADlib/vitamins/cameras.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>

use <../scad/printed/BackFace.scad>
use <../scad/printed/BackFaceAssemblies.scad>
use <../scad/printed/LeftAndRightFaceAssemblies.scad>
use <../scad/printed/LeftAndRightFaceAssembliesCF.scad>

use <../scad/printed/TopFaceAssemblies.scad>
use <../scad/printed/Printbed.scad>
use <../scad/printed/Printbed3point.scad>
use <../scad/printed/PrintheadAssemblies.scad>
include <../scad/utils/CoreXYBelts.scad>
use <../scad/utils/printParameters.scad>

use <../scad/Parameters_Positions.scad>
include <../scad/Parameters_Main.scad>

//$explode = 1;
//$pose = 1;
module Back_Face_test() {
    t = 2;
    echoPrintSize();
    //CoreXYBelts(carriagePosition(t), show_pulleys=true);

    //topFaceMotors(xyMotorType());
    //translate_z(bedHeight()) Print_bed_3_point_assembly();
    //translate_z(bedHeight()) Print_bed_assembly();
    //translate_z(_zMin) Print_bed_3_point_printed_assembly();

    *if (_useCNC)
        Back_Face_CF_Stage_1_assembly();
    else
        Back_Face_Stage_1_assembly();
    if (_useCNC)
        Back_Face_CF_assembly(bedHeight(t));
    else
        Back_Face_assembly(bedHeight(t));
    *let($preview=false)
        Back_Face_stl();
    //Back_Face_CF();
    //Back_Face_CF_dxf();
    //Left_Face_assembly(switch=false);
    //Left_Face_CF_assembly();
    //Right_Face_CF_assembly();
    //Right_Face_assembly();
    //printheadBeltSide(t=t);
    //printheadHotendSide(t=t);
    //camera(rpi_camera_v2, fov_distance = eY/2);

    *translate_z(3)
    if (_useCNC)
        Top_Face_CF_Stage_1_assembly();
    else
        Top_Face_Stage_1_assembly(t);
    //Top_Face_CF_assembly();


    //let($preview=false)
    //backFaceLowerBrackets(NEMA17P);
    //backFaceUpperBrackets(_xyNEMA_width);
    //backFaceBare(NEMA17P);
    //backFaceAllHolePositions() cylinder(r=2, h=10);
    //backFaceHolePositions(left=false) cylinder(r=2, h=10);
    //backFaceCableTies();
    //printheadWiring(carriagePosition(t));
    /*
    *translate([0, eY + eSizeY, 0])
        rotate([90, 0, 0]) {
            backFaceBare();
            *backFaceTopBrackets();
            *backFaceBottomBrackets(NEMA17Slim);
        }
    *translate([-eX/2 - eSizeX, -eY, 0])
        //let($preview=false)
        {
            Left_Face_assembly();
            *Right_Face_assembly();
        }
    */
    *let($preview=false)
        Printbed_stl();
}

if ($preview)
    translate([0, -eY, 0])
        Back_Face_test();
else
    Back_Face_stl();
