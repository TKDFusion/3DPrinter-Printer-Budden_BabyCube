//! Display the top face

include <../scad/config/global_defs.scad>

include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>

//use <../scad/printed/BackFace.scad>
use <../scad/printed/BackFaceAssemblies.scad>
//use <../scad/printed/Base.scad>
//include <../scad/printed/SpoolHolderExtras.scad>
use <../scad/printed/FrontFace.scad>
use <../scad/printed/LeftAndRightFaces.scad>
use <../scad/printed/LeftAndRightFaceAssemblies.scad>
use <../scad/printed/LeftAndRightFaceAssembliesCF.scad>
use <../scad/printed/PrintheadAssemblies.scad>
use <../scad/printed/PrintheadAssembliesE3DV6.scad>
use <../scad/printed/PrintheadAssembliesE3DRevo.scad>
use <../scad/printed/TopFace.scad>
use <../scad/printed/TopFaceAssemblies.scad>
//use <../scad/printed/X_CarriageAssemblies.scad>
//use <../scad/printed/XY_Motors.scad>

//include <../scad/config/Parameters_CoreXY.scad>
//include <../scad/utils/CoreXYBelts.scad>
//include <../scad/utils/cutouts.scad>
include <../scad/utils/printParameters.scad>
///include <../scad/utils/X_Rail.scad>


//$explode = 1;
//$pose = 1;
module Top_Face_test() {
    echoPrintSize();

    //topFace(NEMA14_36, useReversedBelts=true);
    //topFaceCover(NEMA14_36, useReversedBelts=true);
    //topFaceInterlock(NEMA14_36, useReversedBelts=true);


    //printheadHotendSideE3DV6();
    //printheadHotendSideE3DRevo();
    //printheadBeltSide();
    //CoreXYBelts(carriagePosition() + [yRailOffset(_xyNEMA_width).x, 0]);
    *translate_z(eZ) {
        //vflip() Top_Face_stl();
        translate_z(-4) Top_Face_CF();
    }
    //Top_Face();
    //rotate(-90) topFaceSideDogbones();
    //translate([0, -eX, 0]) sideFaceTopDogbones(cnc=false, plateThickness=_topPlateThickness);
    //topFaceSideCutouts();
    //topFaceBackCutouts(toolType=CNC);
    *translate_z(eZ)
        topFaceCover(xyMotorType());
    *translate_z(eZ + eps)
        topFaceInterlock(xyMotorType());

    //let($hide_bolts=true)
    if (_xyMotorDescriptor == "NEMA14") {
        if (_useCNC) {
            //topFaceFrontAndBackDogbones(true, plateThickness=_backPlateCFThickness, yRailOffset=20);
            //topFaceFrontCutouts(toolType=CNC);
            //Top_Face_CF();
            Top_Face_CF_assembly();
            //Top_Face_CF_Stage_1_assembly();
            //Top_Face_CF_Stage_2_assembly();
            //Top_Face_CF_Stage_3_assembly();
            //Top_Face_CF_Stage_4_assembly();
            //Front_Face_CF_assembly();
            //Back_Face_CF_Stage_1_assembly();
            //Right_Face_CF_assembly();
        } else {
            //translate_z(eZ - _topPlateThickness) Top_Face_CF();
            //rotate([90, 0, 90]) Left_Face_stl();
            Top_Face_assembly();
            //Top_Face_Stage_1_assembly();
            //Top_Face_Stage_2_assembly();
        }
    } else {
        if (_useCNC) {
            Top_Face_CF_Stage_1_assembly();
        } else {
            Top_Face_NEMA_17_assembly();
            //Top_Face_NEMA_17_Stage_1_assembly();
            //Top_Face_NEMA_17_Stage_2_assembly();
        }
    }
    /*rotate([90, 0, 0])
        for (left = [true, false])
            xyMotorMountBackHolePositions(left=left, z= -eY - 2*eSizeY - _backPlateCFThickness) // bolt back face to motor mounts
                vflip()
                    boltM3Buttonhead(10+50);
    for (left = [true])
        translate([left ? _sidePlateThickness : eX + 2*eSizeX - _sidePlateThickness, 0, 0])
            rotate([90, 0, 90])
                xyMotorMountSideHolePositions()
                    vflip(left)
                        boltM3Buttonhead(10+50);*/


    *if (_useCNC)
        Left_Face_CF_assembly();
    else
        Left_Face_assembly();
    //Right_Face_assembly();

    //Back_Face_CF_assembly();
    //Back_Face_CF_Stage_1_assembly();
    //Back_Face_assembly();
    //Back_Face();

    *translate([0, -eps, eZ])
        rotate([90, 0, 180]) {
            Front_Upper_Chord_stl();
            //color(grey(20)) frontUpperChordMessage();
        }

}

module Top_Face_CF_map() {
    color(pp2_colour)
        Top_Face_CF(render=false);
    translate([0, -eZ - 2, 3]) Front_Face_CF(render=false);
    translate([-eZ - 2, 0, 0]) rotate([0, 180, -90]) Left_Face_CF(render=false);
    translate([eX + 2*eSizeX + eZ, 0, 3]) rotate(90) Right_Face_CF(render=false);
    translate([eX + 2*eSizeX, eY + 2*eSizeY + eZ + 3, 3])rotate([0, 0, 180]) Back_Face_CF(render=false);

}

//Top_Face_CF(render=false);
//Top_Face_CF_map()
if ($preview)
    translate_z(-eZ)
        Top_Face_test();
/*else
    vflip()
        scale([0.5, 0.5, 0.5])
            Top_Face_stl();*/
