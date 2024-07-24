include <../global_defs.scad>

include <../vitamins/bolts.scad>

include <NopSCADlib/vitamins/pulleys.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
use <NopSCADlib/utils/fillet.scad>

include <../utils/carriageTypes.scad>
include <../utils/HolePositions.scad>

include <../vitamins/inserts.scad>

include <../Parameters_CoreXY.scad>


function yRailSupportSize(NEMA_width = _xyNEMA_width)
    = [ eY + 2*eSizeY, yRailSupportThickness(), yRailOffset(NEMA_width).x + rail_width(railType(_yCarriageDescriptor))/2 + 1 ];

function idlerBracketSize(coreXYPosBL=[0, 0, 0]) = [coreXYPosBL.y + 6, 6, floor(coreXYPosBL.x/2)*2 + 10];
function idlerBracketTopSizeY() = 11;
function idlerBracketTopSizeZ() = 25;

function faceConnectorOverlap() = 10;
function faceConnectorOverlapHeight() = 4;
function frontUpperChordSize() = [eX + 2*eSizeX - 2*idlerBracketTopSizeZ(), 21, eSizeY + 1];
function frontLowerChordSize() = [eX + 2*eSizeX - 2*idlerBracketSize(coreXYPosBL(_xyNEMA_width)).z, 50, eSizeY];

module XY_Idler_Bracket_Left_SB_stl() {
    NEMA_width = NEMA_width(NEMA14_36);

    stl("XY_Idler_Bracket_Left_SB")
        color(pp1_colour)
            XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness, reversedBelts=false, left=true, cnc=true);
}

module XY_Idler_Bracket_Left_stl() {
    NEMA_width = NEMA_width(NEMA14_36);

    stl("XY_Idler_Bracket_Left")
        color(pp1_colour)
            XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness, reversedBelts=true, left=true, cnc=true);
}

module XY_Idler_Bracket_Right_SB_stl() {
    NEMA_width = NEMA_width(NEMA14_36);

    stl("XY_Idler_Bracket_Right_SB")
        color(pp1_colour)
            mirror([0, 1, 0])
                XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness,  reversedBelts=false, left=false, cnc=true);
}

module XY_Idler_Bracket_Right_stl() {
    NEMA_width = NEMA_width(NEMA14_36);

    stl("XY_Idler_Bracket_Right")
        color(pp1_colour)
            mirror([0, 1, 0])
                XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness,  reversedBelts=true, left=false, cnc=true);
}

module XY_Idler_Bracket_Left_NEMA_17_SB_stl() {
    NEMA_width = NEMA_width(NEMA17_40);

    stl("XY_Idler_Bracket_Left_NEMA_17_SB")
        color(pp1_colour)
            XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness, reversedBelts=false, left=true, cnc=true);
}

module XY_Idler_Bracket_Right_NEMA_17_SB_stl() {
    NEMA_width = NEMA_width(NEMA17_40);

    stl("XY_Idler_Bracket_Right_NEMA_17_SB")
        color(pp1_colour)
            mirror([0, 1, 0])
                XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, _sidePlateThickness, reversedBelts=false, left=false, cnc=true);
}

//!Bolt the two front idler pulleys with washers into the **XY_Idler_Bracket_Left**.
//
module XY_Idler_Bracket_Left_SB_assembly()
assembly("XY_Idler_Bracket_Left_SB", ngb=true) {

    yCarriageType = carriageType(_yCarriageDescriptor);
    translate_z(coreXYPosBL(_xyNEMA_width, yCarriageType).z + coreXYSeparation().z)
        rotate([90, 0, 90])
            stl_colour(pp1_colour)
                if (_xyMotorDescriptor == "NEMA14")
                    XY_Idler_Bracket_Left_stl();
                else
                    XY_Idler_Bracket_Left_NEMA_17_stl();
    rotate([90, 0, 90])
        XY_IdlerBracketHardware(coreXYPosBL(_xyNEMA_width, yCarriageType), reversedBelts=false, left=true);
}

module XY_Idler_Bracket_Left_assembly()
assembly("XY_Idler_Bracket_Left", ngb=true) {

    yCarriageType = carriageType(_yCarriageDescriptor);
    translate_z(coreXYPosBL(_xyNEMA_width, yCarriageType).z + coreXYSeparation().z)
        rotate([90, 0, 90])
            stl_colour(pp1_colour)
                if (_xyMotorDescriptor == "NEMA14")
                    XY_Idler_Bracket_Left_stl();
                else
                    XY_Idler_Bracket_Left_NEMA_17_stl();
    rotate([90, 0, 90])
        XY_IdlerBracketHardware(coreXYPosBL(_xyNEMA_width, yCarriageType), reversedBelts=true, left=true);
}

//!Bolt the two front idler pulleys with washers into the **XY_Idler_Bracket_Right**.
//
module XY_Idler_Bracket_Right_SB_assembly()
assembly("XY_Idler_Bracket_Right", ngb=true) {

    coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
    translate([eX + 2*eSizeX, 0, coreXYPosBL.z + coreXYSeparation().z])
        rotate([-90, 0, 90])
            stl_colour(pp1_colour)
                if (_xyMotorDescriptor == "NEMA14")
                    XY_Idler_Bracket_Right_SB_stl();
                else
                    XY_Idler_Bracket_Right_NEMA_17_SB_stl();
    translate([eX + 2*eSizeX, 0, 0])
        rotate([90, 0, 90])
            vflip()
                mirror([0, 1, 0])
                    XY_IdlerBracketHardware(coreXYPosBL, reversedBelts=false, left=false);
}

module XY_Idler_Bracket_Right_assembly()
assembly("XY_Idler_Bracket_Right", ngb=true) {

    coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
    translate([eX + 2*eSizeX, 0, coreXYPosBL.z + coreXYSeparation().z])
        rotate([-90, 0, 90])
            stl_colour(pp1_colour)
                if (_xyMotorDescriptor == "NEMA14")
                    XY_Idler_Bracket_Right_stl();
                else
                    XY_Idler_Bracket_Right_NEMA_17_stl();
    translate([eX + 2*eSizeX, 0, 0])
        rotate([90, 0, 90])
            vflip()
                mirror([0, 1, 0])
                    XY_IdlerBracketHardware(coreXYPosBL, reversedBelts=true, left=false);
}

module XY_IdlerBracketCutouts(coreXYPosBL) {
    sizeY = idlerBracketSize(coreXYPosBL).y;
    separation = coreXYSeparation().z();

    translate([coreXYPosBL.y, coreXYPosBL.z, coreXYPosBL.x])
        translate([0, separation, 0])
            rotate([-90, 180, 0])
                boltHoleM3TapOrInsert(sizeY, horizontal=true);
}

module idlerBracketHolePositions(coreXYPosBL, offset) {
    size = idlerBracketSize(coreXYPosBL) - [offset, 0, 0];
    separation = coreXYSeparation().z;
    if (offset) {
        translate([0, -2*separation + yCarriageBraceThickness() - size.y])
            translate([size.x/2, size.y/2, 0])
                children();
        translate([size.x/2, idlerBracketTopSizeY()/2, 0])
            children();
    }
}

module xyIdlerBracketHolePositions(NEMA_width) {
    coreXYPosBL = coreXYPosBL(NEMA_width);
    translate([3, coreXYPosBL.z + 10, 0])
        idlerBracketHolePositions(coreXYPosBL, _sidePlateThickness)
            children();
}

module idlerBracket(coreXYPosBL, NEMA_width, offset=0, reversedBelts=false, left=true) {
    fillet = 1;
    size = idlerBracketSize(coreXYPosBL) - [offset, 0, reversedBelts ? 2 : 0];
    separation = coreXYSeparation().z;

    boltPos = [-coreXYPosBL.y + offset, coreXYPosBL.x - _sidePlateThickness, 0];
    cutout = offset ? false : true;

    translate([0, -2*separation + yCarriageBraceThickness() - size.y, 0])
        difference() {
            translate([0, reversedBelts && !left ? separation : 0, 0])
                rounded_cube_xy(size - [0, 0, _sidePlateThickness], fillet);
            translate([0, reversedBelts && !left ? separation : 0, 0])
                rotate([-90, 180, 0])
                    translate(boltPos)
                        boltHoleM3(size.y, horizontal=true, chamfer=1);
        }
    overlap = faceConnectorOverlap();
    topSize = [size.x, idlerBracketTopSizeY(), overlap + idlerBracketTopSizeZ() - _sidePlateThickness];
    difference() {
        cutoutDepth = cutout ? faceConnectorOverlapHeight() : 0;
        if (cutout) {
            union() {
                rounded_cube_xy([topSize.x, topSize.y, topSize.z - overlap], fillet);
                translate([cutoutDepth, 0, 0])
                    rounded_cube_xy([topSize.x - cutoutDepth, topSize.y, topSize.z], fillet);
            }
        } else {
            rounded_cube_xy(topSize, fillet);
            if (reversedBelts) {
                if (!_fullLengthYRail) {
                    rounded_cube_xy([eSizeY - 1, topSize.y + 7, topSize.z], fillet);
                    translate([eSizeY - 1, topSize.y, 0])
                        fillet(fillet, topSize.z);
                }
                if (left)
                    translate([0, -separation, 0])
                        rounded_cube_xy([topSize.x, topSize.y + separation, size.z - _sidePlateThickness], fillet);
            }
        }

        translate([cutoutDepth, topSize.y/2, topSize.z - overlap/2])
            rotate([0, 90, 0])
                boltHoleM3Tap(topSize.x - cutoutDepth, horizontal=true, rotate=90, chamfer_both_ends=true);
        translate([0, reversedBelts && left ? -separation : 0, 0])
            rotate([-90, 180, 0])
                translate(boltPos)
                    boltHoleM3TapOrInsert(topSize.y + 2, horizontal=true, chamfer_both_ends=false);
    }
    // base
    translate([0, -2*separation - size.y + 2*fillet, 0])
        cube([size.x, 2*(separation + size.y), 5]);
}

module XY_IdlerBracket(coreXYPosBL, NEMA_width, offset=0, reversedBelts=false, left=true, cnc=false) {
    //size = idlerBracketSize(coreXYPosBL) - [offset, 0, 0];

    //boltPos = [coreXYPosBL.y - offset, 0, coreXYPosBL.x - _sidePlateThickness];
    //baseLength = eZ - coreXYPosBL.z + separation + size.y - yRailSupportSize(NEMA_width).y;
    offsetY = 9.5;
    translate([offset, -yCarriageBraceThickness()/2, _sidePlateThickness])
        difference() {
            idlerBracket(coreXYPosBL, NEMA_width, offset, reversedBelts, left);
            translate([-offset, yCarriageBraceThickness()/2 + offsetY + topBoltHolderSize().y, eX + 2*eSizeX - _sidePlateThickness])
                rotate([90, 90, 0])
                    topFaceFrontHolePositions(cf=true)
                        boltHoleM3Tap(8, horizontal=true, rotate=90, chamfer_both_ends=false);
            idlerBracketHolePositions(coreXYPosBL, offset)
                boltHoleM3Tap(12);
    }
    if (cnc) {
        size = [eY == 180 ? 45 : 55, topBoltHolderSize().y, topBoltHolderSize().z];
        fillet = 1;
        difference() {
            translate([_frontPlateCFThickness, offsetY, _sidePlateThickness])
                union() {
                    rounded_cube_xy(size, _fillet);
                    size2 = [eSizeY, 4*fillet, size.z];
                    translate([0, -size2.y + 2*fillet, 0])
                        cube(size2);
                    size3 = [eSizeY, eZ == 200 ? 25 : 40, reversedBelts ? 8.5: eSizeZ];
                    translate([0, -size3.y - 30, 0])
                        rounded_cube_xy(size3, 1.5);
                    if (!left && reversedBelts) {
                        size4 = [size3.x, coreXYSeparation().z + 2*1.5, size3.z];
                        translate([0, -30 - 2*1.5, 0])
                            rounded_cube_xy(size4, 1.5);
                    }
                }
            translate([_sidePlateThickness, -eZ + 160.5, (eSizeX + _sidePlateThickness)/2])
                rotate([0, 90, 0])
                    boltHoleM3Tap(eSizeZ, horizontal=true, rotate=90, chamfer_both_ends=true);
            translate([0, size.y + offsetY, eX + 2*eSizeX])
                rotate([90, 90, 0])
                    topFaceSideHolePositions()
                        boltHoleM3Tap(8, horizontal=true, rotate=90, chamfer_both_ends=true);
            translate([0, 30 - eZ - offsetY, 0])
                upperSideJoinerHolePositions(_sidePlateThickness)
                    boltHoleM3Tap(size.z);
            translate([_sidePlateThickness, 30 - eZ - offsetY, eX + 2*eSizeX])
                rotate([0, 90, 0])
                    frontFaceSideHolePositions()
                        boltHoleM3Tap(8, horizontal=true, rotate=90, chamfer_both_ends=false);
        }
    }
}

module XY_IdlerBracketHardware(coreXYPosBL, reversedBelts=false, left=true) {
    size = idlerBracketSize(coreXYPosBL);
    boltPos = [coreXYPosBL.y, coreXYPosBL.x, 1];
    separation = coreXYSeparation().z;

    translate([0, coreXYPosBL.z, 0])
        rotate([-90, 0, 0]) {
            if (reversedBelts) {
                bearingType = coreXYBearing();
                translate([boltPos.x, -boltPos.y, yCarriageBraceThickness()/2 - (left ? separation : 0)]) {
                    bearingStack(bearingType);
                    translate_z(-size.y)
                        vflip()
                            //boltM3Caphead(screw_shorter_than(separation + size.y + 10));
                            boltM3Caphead(25);
                }
            } else {
                translate([boltPos.x, -boltPos.y, -separation - size.y - 1])
                    vflip()
                        boltM3Countersunk(screw_shorter_than(separation + idlerBracketTopSizeY() + size.y));
                for (z = [0, -separation])
                    translate([boltPos.x, -boltPos.y, z + yCarriageBraceThickness()/2])
                        explode([-40, 0, 0], true)
                            washer(M3_washer)
                                explode([20, 0, 0], true)
                                    pulley(coreXY_toothed_idler(coreXY_type()))
                                        explode([-20, 0, 0])
                                            washer(M3_washer);
                if (yCarriageBraceThickness())
                    translate([boltPos.x, -boltPos.y, -washer_thickness(M3_washer)])
                        explode([-40, 5, 0], true)
                            washer(M3_washer)
                                explode([0, -10, 0])
                                    washer(M3_washer);
            }
        }
}

module idlerBracketThreadedInsert(size, boltPos) {
    separation = pulley_height(GT2x16_toothed_idler) + 2*washer_thickness(M3_washer);
    if (_useInsertsForFaces)
        translate([boltPos.x, separation, boltPos.z])
            rotate([90, 0, 0])
                explode(10)
                    _threadedInsertM3();
}

module XY_IdlerBracketThreadedInsert(coreXYPosBL) {
    size = idlerBracketSize(coreXYPosBL);

    boltPos = [coreXYPosBL.y, 0, coreXYPosBL.x];

    translate([0, coreXYPosBL.z, 0])
        idlerBracketThreadedInsert(size, boltPos);
}
