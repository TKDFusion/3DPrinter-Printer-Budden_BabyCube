include <../config/global_defs.scad>

include <../printed/PrintheadAssembliesAll.scad>

use <../printed/BackFaceAssemblies.scad>
use <../printed/Base.scad>
use <../printed/SpoolHolderExtras.scad>
use <../printed/FrontFace.scad>
use <../printed/LeftAndRightFaceAssembliesCF.scad>
use <../printed/TopFaceAssemblies.scad>
use <../printed/XY_IdlerBracket.scad>

include <../utils/StagedAssemblyMain.scad>
use <../vitamins/extruder.scad> // for extruderBowdenOffset()

use <../config/Parameters_Positions.scad>
include <../config/Parameters_CoreXY.scad>
include <../utils/CoreXYBelts.scad>

hotendDescriptor = "DropEffectXG";


//! Bolt the **Back_Face_CF_assembly** to the **Base_CF_assembly**.
//
module Stage_1_CF_assembly() pose(a=[55+10, 0, 25 + 80])
main_staged_assembly("Stage_1_CF", big=true, ngb=true) {

    assert(holePositionsYRailShiftX==yRailShiftX());

    translate_z(-eps)
        staged_explode()
            Base_CF_assembly();

    explode([0, 100, 0], true) {
        Back_Face_CF_assembly();
        translate([0, eY + 2*eSizeY, 0])
            rotate([90, 0, 0]) {
                backFaceLeftAndRightSideHolePositions(-_backPlateCFThickness, cf=true)
                    vflip()
                        explode(50)
                            boltM3Buttonhead(10);
                backFaceBracketHolePositions(-_backPlateCFThickness, reversedBelts=true) // bolt back face to base bracket
                    vflip()
                        explode(50)
                            boltM3Buttonhead(10);
            }
    }
    baseBackHolePositions(-_backPlateCFThickness) // bolt back face to base
        vflip()
            explode([0, 0, 60], true)
                boltM3Buttonhead(10);
}

//!1. Bolt the **Right_Face_CF_assembly** to the **Base_CF_assembly** and the **Back_Face_CF_assembly**.
//!2. Connect the wires from the **IEC** to the **PSU**.
//!3. Connect the stepper motor cable from the extruder motor to the mainboard.
module Stage_2_CF_assembly()
main_staged_assembly("Stage_2_CF", big=true, ngb=true) {

    Stage_1_CF_assembly();

    explode([100, 50, 0], true, show_line=false) {
        Right_Face_CF_assembly();

        translate([eX + 2 * eSizeX + eps, 0, 0])
            rotate([90, 0, 90]) {
                lowerSideJoinerHolePositions(left=false) // bolt right face to base
                    explode(10, true)
                        boltM3Buttonhead(8);
                        //boltM3Buttonhead(screw_shorter_than(topBoltHolderSize().z + _sidePlateThickness));
                frontSideJoinerHolePositions(bolts=true) // bolt right face to base front extension
                    explode(10, true)
                        boltM3Buttonhead(10);
                backSideJoinerHolePositions() // bolt right face to back
                    explode(10, true)
                        boltM3Buttonhead(10);
            }
    }
}

//!1. Connect the printhead cables to the mainboard.
//!2. Attach the **Top_Face_CF_assembly** to the back and right faces.
//!3. Attach the **Printhead Assembly** to the X_Carriage.
//
module Stage_3_CF_assembly()
main_staged_assembly("Stage_3_CF", big=true, ngb=true) {

    Stage_2_CF_assembly();

    explode([-50, -50, 150], show_line=false)
        Top_Face_CF_assembly();
    topFaceBackHolePositions(eZ) // bolt top face to back
        explode(175, true)
            boltM3Buttonhead(8);

    explode([-50, -50, 150], true, show_line=false)
        printheadHotendSide(hotendDescriptor, explode=[0, 50, 100]);
    if (!exploded())
        printheadWiring(hotendDescriptor, carriagePosition() + [yRailOffset(_xyNEMA_width).x, 0], backFaceZipTiePositions());

    translate([eX + 2*eSizeX + eps, 0, 0]) {
        rotate([90, 0, 90]) {
            upperSideJoinerHolePositions(reversedBelts=_useReversedBelts) // bolt right face to top
                explode(50, true)
                    boltM3Buttonhead(8);
            xyMotorMountSideHolePositions()
                explode(50, true)
                    boltM3Buttonhead(10);
            xyIdlerBracketHolePositions(_xyNEMA_width)
                explode(50, true)
                    boltM3Buttonhead(10);
        }
    }
    rotate([90, 0, 0])
        for (left = [true, false])
            xyMotorMountBackHolePositions(left=left, z= -eY - 2*eSizeY - _backPlateCFThickness) // bolt back face to motor mounts
                vflip()
                    explode(50, true)
                        boltM3Buttonhead(10);
}


//!1. Bolt the **Base_Cover** to the base, ensuring all cables are routed correctly.
//!2. Bolt the **Left_Face_CF** to the base and the back and top faces.
//
module Stage_4_CF_assembly() pose(a=[55, 0, 25 - 50])
main_staged_assembly("Stage_4_CF", big=true, ngb=true) {

    Stage_3_CF_assembly();

    explode([-250, 0, 50], true, show_line=false)
        baseCoverAssembly();

    explode([-300, 0, 25], true) {
        translate([-eps, 0, 0])
            rotate([90, 0, 90]) {
                Left_Face_CF();
                upperSideJoinerHolePositions(reversedBelts=_useReversedBelts) // bolt left face to top
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(8);
                lowerSideJoinerHolePositions(left=true) // bolt left face to base
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(8);
                frontSideJoinerHolePositions(bolts=true) // bolt left face to base front extension
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(10);
                backSideJoinerHolePositions() // bolt left face to back
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(10);
                xyMotorMountSideHolePositions()
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(10);
                xyIdlerBracketHolePositions(_xyNEMA_width)
                    vflip()
                        explode(10, true)
                            boltM3Buttonhead(10);
            }
    }
}

//! Bolt the **Nameplate** and the **Front_Face_CF** to the base and the top, left, and right faces.
//
module Stage_5_CF_assembly()
main_staged_assembly("Stage_5_CF", big=true, ngb=true) {

    Stage_4_CF_assembly();

    rotate([90, 0, 0]) {
        explode(75, true, show_line=false) {
            Front_Face_CF();
            frontFaceSideHolePositions()
                boltM3Buttonhead(10);
            frontFaceLowerHolePositions()
                boltM3Buttonhead(10);
        }
        explode(150, true, show_line=false) {
            stl_colour(grey(30))
                Nameplate_stl();
            explode(-20, true, show_line=false)
                stl_colour(grey(90))
                    Nameplate_Back_stl();
            frontFaceUpperHolePositions(3)
                boltM3Buttonhead(12);
        }
    }
}

module CF_FinalAssembly(test=false) {
    assert(_useReversedBelts==true || test==true);
    assert(_useCNC==true || test==true);
    assert(holePositionsYRailShiftX==yRailShiftX());

    translate([-(eX + 2*eSizeX)/2, - (eY + 2*eSizeY)/2, -eZ/2]) {
        Stage_5_CF_assembly();

        explode(1, true)
            faceRightSpoolHolder(cf=true);
        explode(150)
            bowdenTube(hotendDescriptor, carriagePosition() + [yRailOffset(_xyNEMA_width).x, 0], extruderPosition(_xyNEMA_width) + extruderBowdenOffset());
        if (!exploded())
            faceRightSpool(cf=true);
    }
}


module CF_DebugAssembly() {
    assert(_useReversedBelts==true);
    assert(_useCNC==true);
    assert(holePositionsYRailShiftX==yRailShiftX());

    translate([-(eX + 2*eSizeX)/2, - (eY + 2*eSizeY)/2, -eZ/2]) {
        explode = 100;
        explode(explode + 25) {
            Top_Face_CF_assembly();
            printheadHotendSide(hotendDescriptor);
        }
        explode([0, explode, 0])
            Back_Face_CF_assembly();
        explode([0, -explode, 0])
            rotate([90, 0, 0])
                Front_Face_CF();
        explode([-explode, 0, 0])
            translate([-eps, 0, 0])
                rotate([90, 0, 90])
                    Left_Face_CF();
        explode([explode, 0, 0])
            Right_Face_CF_assembly();
        explode(-eps)
            translate_z(-eps)
                Base_CF_assembly();
        if (!exploded()) {
            printheadWiring(hotendDescriptor, carriagePosition() + [yRailOffset(_xyNEMA_width).x, 0], backFaceZipTiePositions());
            explode(150)
                bowdenTube(hotendDescriptor, carriagePosition() + [yRailOffset(_xyNEMA_width).x, 0], extruderPosition(_xyNEMA_width) + extruderBowdenOffset());
        }
    }
}

