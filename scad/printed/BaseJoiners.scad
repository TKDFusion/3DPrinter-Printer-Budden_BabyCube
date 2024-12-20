include <../config/global_defs.scad>

include <NopSCADlib/utils/core/core.scad>
use <NopSCADlib/utils/fillet.scad>

include <../vitamins/bolts.scad>
include <../utils/HolePositions.scad>
use <../utils/translateRotate.scad>
include <../config/Parameters_Main.scad>

function baceCoverCenterHolePosY() = 144.5;


module Base_Front_Joiner_stl() {
    size = [eX, eSizeY, eSizeZ];
    stl("Base_Front_Joiner")
        difference() {
            translate([eSizeX, _frontPlateCFThickness, 0])
                color(pp2_colour)
                    rounded_cube_xy(size, _fillet);
            baseFrontHolePositions(frontCenterHole=true)
                boltHoleM3Tap(size.z);
            baseAllCornerHolePositions()
                boltHoleM3Tap(size.z);
            rotate([90, 0, 0])
                frontFaceLowerHolePositions(-size.y - _frontPlateCFThickness)
                    boltHoleM3Tap(size.y, horizontal=true);
        }
}

backBoltLength = 9;

module baseSideJoiner(offset=0, baseCoverOffset, left) {
    difference() {
        // bottom chord
        union() {
            fillet = 1.5;
            translate([offset, 0, offset]) {
                rounded_cube_xy([eY + 2*eSizeY - offset, eSizeZ, eSizeXBase - offset], fillet);
                rounded_cube_xy([eSizeY, 55, eSizeXBase - offset], fillet);
                rounded_cube_xy([2*eSizeY, baseCoverOffset, eSizeXBase - offset], fillet);
                translate([2*eSizeY, eSizeZ, 0])
                    fillet(fillet, eSizeXBase - offset);
            }
            translate([eY + eSizeY, 0, offset]) {
                rounded_cube_xy([eSizeY, 20, 35 - offset], fillet); // 38 to match frontConnector size
                translate([0, eSizeZ, 0])
                    rotate(90)
                        fillet(5, eSizeXBase - offset);
            }
        }
        translate([offset + 3*eSizeY/2, baseCoverOffset, (eSizeXBase + offset)/2])
            rotate([90, 0, 0])
                boltHoleM3Tap(10);
        translate([eY + 2*eSizeY, backFaceHolePositions()[0], _backFaceHoleInset])
            rotate([90, 0, -90])
                boltHoleM3Tap(backBoltLength, horizontal=true, chamfer_both_ends=false);
        translate([eY + 2*eSizeY, backFaceBracketLowerOffset().y, backFaceBracketLowerOffset().x])
            rotate([90, 0, -90])
                boltHoleM3Tap(10, horizontal=true, chamfer_both_ends=false);
        lowerChordHolePositions()
            rotate([90, 0, 180])
                boltHoleM3Tap(eSizeZ - 2, horizontal=true, chamfer_both_ends=false);
    }
}

module Base_Left_Joiner_stl() {
    stl("Base_Left_Joiner")
        difference() {
            color(pp1_colour)
                baseSideJoiner(offset=_sidePlateThickness, baseCoverOffset=baseCoverInsideHeight, left=true);
            lowerSideJoinerHolePositions(_sidePlateThickness, left=true)
                boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
            frontSideJoinerHolePositions(_sidePlateThickness)
                boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
            rotate([0, -90, 0])
                frontFaceSideHolePositions(-_sidePlateThickness)
                    vflip()
                        boltHoleM3Tap(eSizeXBase, horizontal=true, rotate=-90);
            faceConnectorHolePositions()
                rotate([90, 0, 180])
                    boltHoleM3Tap(backBoltLength, horizontal=true);
    }
}

module Base_Right_Joiner_stl() {
    stl("Base_Right_Joiner")
        mirror([0, 1, 0])
            difference() {
                color(pp1_colour)
                    baseSideJoiner(offset=_sidePlateThickness, baseCoverOffset=baseCoverInsideHeight, left=false);
                lowerSideJoinerHolePositions(_sidePlateThickness, left=false)
                    boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
                frontSideJoinerHolePositions(_sidePlateThickness)
                    boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
                rotate([0, -90, 0])
                    frontFaceSideHolePositions(-_sidePlateThickness)
                        vflip()
                            boltHoleM3Tap(eSizeXBase, horizontal=true, rotate=-90);
                faceConnectorHolePositions()
                    rotate([90, 0, 180])
                        boltHoleM3Tap(backBoltLength, horizontal=true);
            }
}


module baseCover(baceCoverCenterHolePosY, cf=true) {
    sizeCenterPillar = [eSizeXBase - _sidePlateThickness, 5, baseCoverOutsideHeight];
    size = [eX + 2*eSizeX, baceCoverCenterHolePosY() + sizeCenterPillar.y/2, baseCoverOutsideHeight - baseCoverInsideHeight];
    tolerance = 0;
    fillet = 1;
    translate_z(eps)
    difference() {
        union() {
            translate([0, -size.y, 0]) {
                xOffset = cf ? _sidePlateThickness + tolerance : _webThickness + tolerance;
                sizeBack = [size.x - 2*xOffset, 3, baseCoverOutsideHeight - eSizeZ];
                translate([xOffset, 0, 0]) {
                    rounded_cube_xy([size.x - 2*xOffset, size.y - eSizeY - tolerance - (cf ? _frontPlateCFThickness : 0), size.z], fillet);
                    rounded_cube_xy(sizeBack, fillet);
                }

                xOffset2 = cf ? eSizeX + tolerance : eSizeXBase + 26 + tolerance;
                translate([xOffset2, 0, 0])
                    rounded_cube_xy([eX - (cf ? tolerance : 2*xOffset2 - 2*eSizeX), size.y - (cf ? _frontPlateCFThickness : _webThickness), size.z], fillet);

                sizeBack2 = [size.x - 4*eSizeX, sizeBack.y, baseCoverOutsideHeight];
                translate([(size.x - sizeBack2.x)/2, 0, 0])
                    rounded_cube_xy(sizeBack2, fillet);

                sizePillar = [eSizeXBase - _sidePlateThickness, eSizeY, sizeBack.z];
                translate([xOffset, 0, 0]) {
                    rounded_cube_xy(sizePillar, fillet);
                    translate([0, sizeBack.y, 0])
                        fillet(2, sizePillar.z);
                }
                translate([size.x - xOffset - sizePillar.x, 0, 0]) {
                    rounded_cube_xy(sizePillar, fillet);
                    translate([0, sizeBack.y, 0])
                        rotate(90)
                            fillet(2, sizePillar.z);
                }
                translate([size.x/2 - sizeCenterPillar.x/2, 0, 0]) {
                    rounded_cube_xy(sizeCenterPillar, fillet);
                    translate([sizeCenterPillar.x, sizeBack.y, 0])
                        fillet(1, sizeCenterPillar.z);
                    translate([0, sizeBack.y, 0])
                        rotate(90)
                            fillet(1, sizeCenterPillar.z);
                }
            }
        }// end union
        cutoutSize = [10, 3 + 2*eps, eSizeZ + eps];
        translate([size.x/2 + sizeCenterPillar.x/2, -size.y - eps, baseCoverOutsideHeight - cutoutSize.z + eps]) {
            cube(cutoutSize + [0, 2, 0]);
            for (v = [ [0, 0, 0, 90], [cutoutSize.x, 0, 0, 0], [cutoutSize.x, cutoutSize.y, 0, -90] ])
                translate_r(v)
                    fillet(1, cutoutSize.z);
        }
        for (x = [cf ? _sidePlateThickness + 3.5 : 7, size.x - (cf ? _sidePlateThickness + 3.5 : 7)])
            translate([x, -3*eSizeY/2 - (cf ? _frontPlateCFThickness : 0), 0])
                boltHoleM3(size.z);
        assert(baceCoverCenterHolePosY() == size.y - sizeCenterPillar.y/2);
        translate([(size.x)/2, -size.y + sizeCenterPillar.y/2, sizeCenterPillar.z])
            vflip()
                boltHoleM3Tap(10);
    }// end difference
}

