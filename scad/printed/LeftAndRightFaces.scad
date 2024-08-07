include <../global_defs.scad>

include <../vitamins/bolts.scad>

use <NopSCADlib/utils/fillet.scad>
include <NopSCADlib/vitamins/iecs.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
include <NopSCADlib/vitamins/rockers.scad>
use <NopSCADlib/vitamins/wire.scad>

include <../utils/carriageTypes.scad>
include <../utils/cutouts.scad>
include <../utils/diagonal.scad>
include <../utils/HolePositions.scad>
include <../utils/motorTypes.scad>

include <../vitamins/inserts.scad>

use <SwitchShroud.scad>
use <XY_IdlerBracket.scad>
use <XY_Motors.scad>

include <../Parameters_Main.scad>


function extruderMotorType() = NEMA17_40;

function backBoltLength() = 9;

function iecType() = IEC_320_C14_switched_fused_inlet;
function iecPosition() = [eX + 2*eSizeX, eY + 2*eSizeY - eSizeY - 1 - iec_body_h(iecType())/2, eSizeZ/2 + iec_pitch(iecType())/2];


fillet = _fillet;
innerFillet = 5;
upperWebThickness = 3;
antiShearSize = [eY + 2*eSizeY, 20];
switchShroudSizeX = 60;//switchShroudSize().x;
upperFillet = 1.5;


function rocker_type() = small_rocker;
function rockerPosition(rocker_type) = [0, rocker_height(rocker_type)/2 + frontLowerChordSize().y + 3, eSizeX + eps + rocker_slot_w(rocker_type)/2];
function extruderMotorOffsetZ() = upperWebThickness;
//ECHO: extruderPosition14Y = 132
//ECHO: extruderPosition17Y = 117.8
//function extruderPosition(NEMA_width) = [eX + 2*eSizeX, eY - 2*NEMA_width + 2*35.2 - 40 - motorClearance().y, eZ - 73];
function extruderPosition(NEMA_width) = [eX + 2*eSizeX, eY - motorClearance().y - NEMA_width - (NEMA_width < 40 ? 3.8 : 2.7), eZ - 73];
function spoolHolderPosition(cf=false) = [eX + 2*eSizeX + (cf ? 10 : 0), cf ? 25 : 24, cf ? eZ - 70 : eZ - 75];
function frontReinforcementThickness() = 3;
function spoolHolderBracketSize(cf=false) = [cf ? 3 : eSizeX, cf ? 25 : 30, 20];


module leftFace(NEMA_type) {
    assert(isNEMAType(NEMA_type));

    difference() {
        union() {
            frame(NEMA_type, left=true);
            webbingLeft(NEMA_type);
            NEMA_width = NEMA_width(NEMA_type);
            coreXYPosBL = coreXYPosBL(NEMA_width, carriageType(_yCarriageDescriptor));
            translate([0, coreXYPosBL.z + coreXYSeparation().z, 0])
                XY_IdlerBracket(coreXYPosBL(NEMA_width), NEMA_width, 0);
            // add a support for the camera
            translate([0, coreXYPosBL.z - coreXYSeparation().z, 0])
                translate([3, -5, eSizeX])
                    rotate([90, 0, 0])
                        right_triangle(9, 9, 20, center=false);
            XY_MotorUpright(NEMA_type, left=true);
        }
        switchShroudHolePositions()
            boltPolyholeM3Countersunk(eSizeXBase, sink=0.25);
        translate(rockerPosition(rocker_type())) {
            rockerHoleSize = [frontReinforcementThickness() + 2*eps, rocker_slot_h(rocker_type()), rocker_slot_w(rocker_type())];
            translate([-eps, -rockerHoleSize.y/2, -rockerHoleSize.z/2]) {
                cube(rockerHoleSize);
                // add cutout to avoid bridging bug in slic3r/PrusaSlicer/SuperSlicer
                translate([rockerHoleSize.x/2, 0, rockerHoleSize.z - eps]) {
                    //cube([rockerHoleSize.x/2, rockerHoleSize.y, 0.5 + eps]);
                    translate([rockerHoleSize.x/2, 0, 0])
                        rotate([90, 0, 180])
                            right_triangle(rockerHoleSize.x/2, 1 + eps, rockerHoleSize.y, center=false);
                }
            }
        }
        /*translate([0, eZ - _topPlateThickness, eX + 2*eSizeX])
            rotate([90, 90, 0])
                topFaceSideHolePositions()
                    boltHoleM3Tap(topBoltHolderSize().y, horizontal=true, rotate = 90);*/
    }
}

module rightFace(NEMA_type) {
    assert(isNEMAType(NEMA_type));

    // orient the right face for printing
    rotate(180)
        mirror([0, 1, 0])
            difference() {
                union() {
                    frame(NEMA_type, left=false);
                    webbingRight(NEMA_type);
                    NEMA_width = NEMA_width(NEMA_type);
                    coreXYPosBL = coreXYPosBL(NEMA_width, carriageType(_yCarriageDescriptor));
                    translate([0, coreXYPosBL.z + coreXYSeparation().z, 0])
                        XY_IdlerBracket(coreXYPosBL, NEMA_width);
                    XY_MotorUpright(NEMA_type, left=false);
                }
                /*translate([0, eZ - _topPlateThickness, eX + 2*eSizeX])
                    rotate([90, 90, 0])
                        topFaceSideHolePositions()
                            //boltHoleM3Tap(topBoltHolderSize().y, horizontal=true, rotate=90);
                            translate_z(-eps)
                                rotate(30)
                                    poly_cylinder(r=M3_tap_radius, h=topBoltHolderSize().y-2, sides=6);*/
            }
}

module sideFaceMotorCutout(left, NEMA_width, cnc=true, zOffset=0) {
    cutoutHeight = NEMA_width < 40 ? 40 : 50;
    translate([coreXYPosTR(NEMA_width).y, xyMotorPosition(NEMA_width, left).z + zOffset, 0])
        motorCutout([NEMA_width + 3, cutoutHeight, cnc ? 0 : _webThickness], upperFillet);
}

module motorCutout(size, upperFillet) {
    lowerFillet = 3;
    if (size.z == 0)
        translate([-size.x/2, -size.y]) {
            translate([0, lowerFillet*2])
                rounded_square([size.x, size.y - lowerFillet*2], upperFillet, center=false);
            rounded_square([size.x, size.y - lowerFillet*2 - 1], lowerFillet, center=false);
        }
    else
        translate([-size.x/2, -size.y, -2*eps]) {
            translate([0, lowerFillet*2])
                rounded_cube_xy([size.x, size.y - lowerFillet*2, size.z + 4*eps], upperFillet);
            rounded_cube_xy([size.x, size.y - lowerFillet*2 - 1, size.z + 4*eps], lowerFillet);
        }
}


module antiShearBracing(NEMA_width) {
    // add some anti-shear bracing at the top of the frame
    difference() {
        translate([0, eZ - antiShearSize.y])
            rounded_square(antiShearSize, fillet, center=false);
        sideFaceTopDogbones();
    }
}

module webbingLeft(NEMA_type) {
    assert(isNEMAType(NEMA_type));
    NEMA_width = NEMA_width(NEMA_type);
    left = true;
    idlerBracketSize = idlerBracketSize(coreXYPosBL(NEMA_width));

    // not needed as covered by diagonal
    *translate([idlerBracketSize.x, eZ - antiShearSize.y, 0])
        rotate(-90)
            fillet(innerFillet, upperWebThickness);

    // shroud for switch
    translate([eSizeX - fillet, 0, 0])
        cube([switchShroudSizeX - eSizeX + fillet, middleWebOffsetZ(), _webThickness]);
    *translate([switchShroudSizeX, eSizeZ, 0]) // not needed, since covered by diagonal
        fillet(innerFillet, _webThickness);
    translate([switchShroudSizeX, middleWebOffsetZ(), 0])
        rotate(-90)
            fillet(innerFillet, _webThickness);
    // upright by motor
    uprightPos = [coreXYPosTR(NEMA_width).y - 2 - NEMA_width/2 - eSizeY, middleWebOffsetZ(), 0];
    linear_extrude(upperWebThickness)
        difference() {
            union() {
                translate(uprightPos)
                    square([eY + 2*eSizeY - uprightPos.x, eZ - yRailSupportThickness() - middleWebOffsetZ() - cnc_bit_r]);
                antiShearBracing(NEMA_width);
                translate([uprightPos.x, eZ - antiShearSize.y])
                    rotate(180)
                        fillet(innerFillet);
                // idler upright
                rounded_square([eSizeY, eZ - eSizeZ + fillet], 1.5, center=false);
                translate([0, middleWebOffsetZ(), 0])
                    rounded_square([idlerBracketSize.x, eZ - middleWebOffsetZ() - _topPlateThickness], fillet, center=false);
                if (_sideTabs)
                    sideFaceBackTabs();
            }
            sideFaceMotorCutout(left, NEMA_width);
        }
    // diagonal brace by motor
    translate([idlerBracketSize.x, middleWebOffsetZ() + eSizeZ, 0])
        //diagonalDown([uprightPos.x - idlerBracketSize.x, middleWebOffsetZ() - 35 - eSizeZ, _webThickness], min(eSizeY, eSizeZ), 5, extend=true);
        diagonalDown([uprightPos.x - idlerBracketSize.x, eZ - eSizeZ - middleWebOffsetZ()-antiShearSize.y, upperWebThickness], min(eSizeY, eSizeZ), 5);
    // main diagonal brace
    translate([switchShroudSizeX, eSizeZ, 0])
        diagonal([eY + eSizeY - switchShroudSizeX, middleWebOffsetZ() - eSizeZ, _webThickness], min(eSizeY, eSizeZ), 5);
}

module spoolHolderCutout(NEMA_width, cnc=false) {

    width = (extruderPosition(NEMA_width).y - XY_MotorMountSize(NEMA_width).y)/2;
    if (cnc)
        translate([spoolHolderPosition(cnc).y - spoolHolderBracketSize(cnc).z/2, spoolHolderPosition(cnc).z])
            rounded_square([30, eZ - antiShearSize.y - spoolHolderPosition().z], innerFillet, center=false);
    else
        translate([idlerBracketSize(coreXYPosBL(NEMA_width)).x, spoolHolderPosition().z])
            rounded_square([extruderPosition(NEMA_width).y - width/2 - eSizeY-idlerBracketSize(coreXYPosBL(NEMA_width)).x, eZ - antiShearSize.y - spoolHolderPosition().z], innerFillet, center=false);
}

module webbingRight(NEMA_type) {
    assert(isNEMAType(NEMA_type));
    NEMA_width = NEMA_width(NEMA_type);
    left = false;
    idlerBracketSize = idlerBracketSize(coreXYPosBL(NEMA_width));

    // main diagonal brace
    translate([eSizeY + eps, eSizeZ - eps, 0]) // eps displacement probably not necessary
        diagonalDown([eY + 2*eps, middleWebOffsetZ() - eSizeZ + 2*eps, _webThickness], min(eSizeY, eSizeZ), 5);

    extruderPosition = extruderPosition(NEMA_width);
    width = (extruderPosition.y - XY_MotorMountSize(NEMA_width).y)/2;
    // plate to hold extruder
    linear_extrude(upperWebThickness)
        difference() {
            union() {
                translate([0, middleWebOffsetZ()])
                    //square([eY + eSizeY - XY_MotorMountSize(NEMA_width).y + eps, eZ - middleWebOffsetZ() - _topPlateThickness]);
                    square([eY + 2*eSizeY, eZ - middleWebOffsetZ() - _topPlateThickness - cnc_bit_r]);
                antiShearBracing(NEMA_width);
                // idler upright
                rounded_square([eSizeY, eZ - eSizeZ + fillet], 3, center=false);
                translate([0, middleWebOffsetZ(), 0])
                    rounded_square([idlerBracketSize.x, eZ - middleWebOffsetZ() - _topPlateThickness], fillet, center=false);
                if (_sideTabs)
                    sideFaceBackTabs();
            }
            translate([extruderPosition.y, extruderPosition.z]) {
                poly_circle(r=NEMA_boss_radius(extruderMotorType()) + 0.25);
                // extruder motor bolt holes
                NEMA_screw_positions(extruderMotorType())
                    poly_circle(r=M3_clearance_radius);
            }
            spoolHolderCutout(NEMA_width);
            sideFaceMotorCutout(left, NEMA_width);
        }

    // support for the spoolholder
    offset = 22.5;
    translate([0, middleWebOffsetZ(), 0]) {
        rounded_cube_xy([extruderPosition.y - offset - eSizeY + innerFillet, spoolHolderPosition().z - middleWebOffsetZ(), eSizeX], innerFillet);
        translate([extruderPosition.y - offset - eSizeY + innerFillet, eSizeZ, 0])
            fillet(innerFillet, eSizeX);
    }
    translate([idlerBracketSize.x + spoolHolderBracketSize().z + 0.25, middleWebOffsetZ(), 0])
        rounded_cube_xy([10, spoolHolderPosition().z - middleWebOffsetZ(), eSizeX + 5], 2);
    translate([idlerBracketSize.x, spoolHolderPosition().z, 0])
        fillet(innerFillet, eSizeX);

    translate([0, middleWebOffsetZ(), 0]) {
        height = eSizeZ + 5;
        rounded_cube_xy([idlerBracketSize.x, 3*eSizeZ, height], fillet);
        translate([frontReinforcementThickness(), 0, 0])
            rotate(270)
                fillet(innerFillet, height);
        translate([frontReinforcementThickness(), 3*eSizeZ, 0])
            fillet(innerFillet, height);
    }
}

motorUprightWidth = max(10, eSizeY); // make sure at least 10 wide, to accept inserts

module motorUpright(NEMA_width, left) {
    //uprightTopZ = coreXYPosBL(NEMA_width, carriageType(_yCarriageDescriptor)).z - (left ? coreXYSeparation().z : 0);
    uprightTopZ = xyMotorPosition(NEMA_width, left).z + 2*fillet;
    uprightPosZ = middleWebOffsetZ() + eSizeZ - 2*fillet;
    upperFillet = 1.5;
    translate([eY + 2*eSizeY - motorClearance().y + upperFillet, uprightPosZ, 0])
        cube([motorClearance().y - upperFillet, uprightTopZ - uprightPosZ, eSizeXBase]);
}

module idlerUpright(NEMA_width, left) {
    difference() {
        rounded_cube_xy([eSizeY, eZ - eSizeZ + fillet + eps, eSizeX], 3);
        if (!left)
            // cutouts for zipties
            for (y = idlerUprightZipTiePositions())
                translate([eSizeY, y, eSizeX + eps])
                    rotate([0, 90, 0])
                        zipTieCutout();
    }
    // idler upright, top part, xSize matches idler
    idlerBracketSize = idlerBracketSize(coreXYPosBL(NEMA_width));
    translate([0, middleWebOffsetZ(), 0])
        rounded_cube_xy([idlerBracketSize.x, eZ - middleWebOffsetZ() - _topPlateThickness, eSizeX], fillet);
    // idler upright reinforcement to stop front face shear
    coreXYPosBL = coreXYPosBL(NEMA_width, carriageType(_yCarriageDescriptor));
    translate([0, eSizeZ, 0])
        rounded_cube_xy([frontReinforcementThickness(), coreXYPosBL.z - coreXYSeparation().z/2 - idlerBracketSize.y - eSizeZ, idlerBracketSize.z], fillet);
    translate([frontReinforcementThickness(), coreXYPosBL.z - idlerBracketSize.x - 2, 0])
        rotate(270)
            fillet(1.5, idlerBracketSize.z);
    translate([0, eZ - eSizeZ - 5, 0]) {
        extraZ = _xyMotorDescriptor == "NEMA14" ? 4 : 10;
        rounded_cube_xy([idlerBracketSize.x, eSizeZ + 5 - _topPlateThickness, _backFaceHoleInset + extraZ], fillet);
        rounded_cube_xy([_backPlateThickness, eSizeZ + 5, _backFaceHoleInset + extraZ], fillet);
    }
}

module frameLower(NEMA_width, left=true, offset=0, cf=false, length=0) {
    if (!cf)
        translate([eY + 2*eSizeY - motorUprightWidth, 0, offset]) {
            difference() {
                size = [motorUprightWidth, middleWebOffsetZ(), eSizeXBase - offset];
                union() {
                    translate([0, eSizeZ, 0])
                        rounded_cube_xy(size, fillet);
                    // small cube for back face boltholes
                    translate([0, middleWebOffsetZ(), 0]) {
                        rounded_cube_xy([eSizeY, eSizeZ, _backFaceHoleInset + 4 - offset], fillet);
                        if (offset==0)
                            translate([-eSizeY, 0, 0])
                                cube([2*eSizeY, eSizeZ, eSizeX], fillet);
                    }
                }
                // cutouts for zipties
                for (y = motorUprightZipTiePositions())
                    translate([-eps, y, size.z])
                        zipTieCutout();
                translate([eSizeZ, backFaceHolePositions()[1], _backFaceHoleInset - offset])
                    rotate([90, 0, -90])
                        boltHoleM3Tap(backBoltLength(), horizontal=!cf, chamfer_both_ends=false);
            }
        }

    difference() {
        // bottom chord
        union() {
            fillet = 1.5;
            translate([length == 0 ? offset : eY + 2*eSizeY - length, 0, offset])
                rounded_cube_xy([length == 0 ? eY + 2*eSizeY - offset : length, eSizeZ, eSizeXBase - offset], fillet);
            translate([eY + 2*eSizeY - 10, 0, offset])
                rounded_cube_xy([10, 20, 35 - offset], fillet); // 38 to match frontConnector size
        }
        translate([eY + 2*eSizeY, backFaceHolePositions()[0], _backFaceHoleInset])
            rotate([90, 0, -90])
                boltHoleM3Tap(backBoltLength(), horizontal=true, chamfer_both_ends=false);
        translate([eY + 2*eSizeY, backFaceBracketLowerOffset().y, backFaceBracketLowerOffset().x])
            rotate([90, 0, -90])
                boltHoleM3Tap(10, horizontal=true, chamfer_both_ends=false);
        if (!cf)
            for (x = bottomChordZipTiePositions(left))
                translate([x, eSizeY + eps, eSizeX + 2])
                    rotate(-90)
                        zipTieCutout();
        lowerChordHolePositions()
            rotate([90, 0, 180])
                // !! changing bolthole length can cause STL file to become invalid
                // try setting bolt length to eSizeZ -1 to fix.
                //boltHoleM3TapOrInsert(eSizeZ - 2, horizontal=true);
                //boltHoleM3TapOrInsert(eSizeZ, horizontal=true, chamfer_both_ends=true);
                boltHoleM3Tap(eSizeZ - 2, horizontal=true, chamfer_both_ends=false);
                *translate_z(-eps)
                    poly_cylinder(r=M3_tap_radius, h=eSizeZ - 2, sides=6);
    }
    translate([eY + eSizeY, eSizeZ, offset])
        rotate(90)
            fillet(innerFillet, eSizeXBase - offset);
}

module frontConnector() {
    overlap = faceConnectorOverlap();
    overlapHeight = faceConnectorOverlapHeight();
    size = [eSizeY, frontLowerChordSize().y, idlerBracketSize(coreXYPosBL(_xyNEMA_width)).z + overlap];

    fillet = 1.5;
    difference() {
        translate_z(_sidePlateThickness)
            union() {
                rounded_cube_xy([size.x, size.y, size.z - _sidePlateThickness - overlap], fillet);
                translate([overlapHeight, 0, 0])
                    rounded_cube_xy([size.x - overlapHeight, size.y, size.z - _sidePlateThickness], fillet);
            }
            for (y = [5, size.y/2, size.y - 5])
                translate([size.x, y, size.z - overlap/2])
                    rotate([90, 0, -90])
                        boltHoleM3TapOrInsert(size.x - overlapHeight, horizontal=true, chamfer_both_ends=true);
    }
}


//use coordinate frame of flat frame
module frame(NEMA_type, left=true) {
    assert(isNEMAType(NEMA_type));
    NEMA_width = NEMA_width(NEMA_type);

    idlerUpright(NEMA_width, left);
    difference() {
        union() {
            frameLower(NEMA_width, left);
            // cube for top face bolt holes
            topBoltHolderSize = topBoltHolderSize(0);
            translate([0, eZ - _topPlateThickness - topBoltHolderSize.y, 0]) {
                translate([_frontPlateCFThickness, 0, 0])
                    rounded_cube_xy(topBoltHolderSize, fillet);
                translate([idlerBracketSize(coreXYPosBL(NEMA_width)).x, 0, 0])
                    rotate(270)
                        fillet(2, topBoltHolderSize.z);
            }
            motorUpright(NEMA_width, left);

            frontConnector();
            // middle chord
            translate([0, middleWebOffsetZ(), 0])
                cube([eY + eSizeY + eps, eSizeZ, eSizeX]);
        }
        sideFaceTopHolePositions()
            boltHoleM3Tap(topBoltHolderSize().y, horizontal=true, chamfer_both_ends=true);
        faceConnectorHolePositions()
            rotate([90, 0, 180])
                boltHoleM3TapOrInsert(backBoltLength(), _useInsertsForFaces, horizontal=true);
        // add a holes to access a motor bolt
        translate([coreXYPosTR(NEMA_width).y, eZ - yRailSupportThickness() + eps, coreXYPosBL(NEMA_width).x + coreXY_drive_pulley_x_alignment(coreXY_type())])
            rotate([-90, 90, 0])
                NEMA_screw_positions(NEMA_type, n=1)
                    rotate([180, 0, 90])
                        translate([-M3_clearance_radius, -2.6, 0]) {
                            size = [2*M3_clearance_radius, 5, 8 + 2*eps];
                            cube(size);
                            rotate([-90, 180, 0])
                                fillet(fillet, size.y);
                            translate([size.x, 0, 0])
                                rotate([-90, -90, 0])
                                    fillet(fillet, size.y);
                            translate([size.x, 0, size.z])
                                rotate([-90, 0, 0])
                                    fillet(fillet, size.y);
                            translate([0, 0, size.z])
                                rotate([-90, 90, 0])
                                    fillet(fillet, size.y);
                        }
        // middle chord
        if (!left)// add cutouts for extruder motor wires
            for (y = extruderZipTiePositions())
                translate([y + extruderPosition(NEMA_width).y, middleWebOffsetZ() - eps, eSizeX])
                    rotate(90)
                        zipTieCutout();
    }

    // fillets

    // middle
    translate([eSizeY, middleWebOffsetZ(), 0]) {
        rotate(-90)
            fillet(innerFillet, eSizeX);
        translate([eY, 0, 0])
            rotate(180)
                fillet(innerFillet, eSizeX);
        if (left)
            translate([idlerBracketSize(coreXYPosBL(NEMA_width)).x - eSizeY, eSizeZ, 0])
                fillet(innerFillet, eSizeX); // fillet not needed on right side because of spoolholder
        translate([eY + eSizeY - motorClearance().y + upperFillet, eSizeZ, 0])
            rotate(90)
                fillet(3, eSizeX);// smaller fillet by motor cutout
    }

    // lower
    translate([eSizeY, eSizeZ, 0])
        fillet(innerFillet, eSizeXBase);
}

function extruderZipTiePositions() = [10, 48];
function motorUprightZipTiePositions() = [30, middleWebOffsetZ() - 18];
function idlerUprightZipTiePositions() = [middleWebOffsetZ() - 20];
function bottomChordZipTiePositions(left) = left ? [eY/2 + eSizeY + 30, eY + 2*eSizeY - 30] : [eY + 2*eSizeY - 30];

module zipTieCutout() {
    cutoutSize = [5, 4, 2];
    cutoutDepth = cutoutSize.x/2;

    translate([0, -cutoutSize.y/2, - cutoutSize.z - cutoutDepth]) {
        difference() {
            union() {
                translate([-eps, 0, 0])
                    cube(cutoutSize + [eps, 0, 0]);
                translate([cutoutSize.x - cutoutSize.z, 0, 0])
                    cube([cutoutSize.z, cutoutSize.y, cutoutSize.z + cutoutDepth + 2*eps]);
                translate([cutoutSize.x - cutoutSize.z + eps, -eps, cutoutSize.y - cutoutSize.z - eps])
                    rotate([90, 0, 180])
                        right_triangle(1.5, 1.5, cutoutSize.y + 2*eps, center=false);
            }
            // add a fillet to make it easier to insert the ziptie
            translate([cutoutSize.x + eps, -eps, -eps])
                rotate([90, 0, 180])
                    fillet(3, cutoutSize.y + 2*eps); // rounded fillet seems to work better than triangular one
                    //right_triangle(1, 1, cutoutSize.y + 2*eps, center=false);
        }
    }
}

module leftAndRightFaceZipTies(left, lowerZipTies=true) {
    translate([eY + 2*eSizeY - motorUprightWidth, 0, 0])
        for (y = motorUprightZipTiePositions())
            translate([0.5, y, eSizeXBase])
                rotate(90)
                    cable_tie(cable_r=3, thickness=3);
    if (lowerZipTies)
        for (x = bottomChordZipTiePositions(left))
            translate([x, eSizeY - 1, eSizeX + 1])
                rotate(180)
                    cable_tie(cable_r=3, thickness=2);
}

module rightFaceExtruderZipTies(NEMA_width) {
    for (y = extruderZipTiePositions())
        translate([eX + eSizeX, y + extruderPosition(NEMA_width).y, middleWebOffsetZ() + 0.5])
            rotate([90, 0, -90])
                cable_tie(cable_r=3, thickness=3);
}

module rightFaceIdlerUprightZipTies() {
    for (y = idlerUprightZipTiePositions())
        translate([eSizeY, y, eSizeX + eps])
            rotate([0, 0, -90])
                cable_tie(cable_r=3, thickness=3);
}
