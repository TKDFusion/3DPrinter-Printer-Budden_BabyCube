include <../config/global_defs.scad>

include <../vitamins/bolts.scad>
include <NopSCADlib/utils/fillet.scad>
include <NopSCADlib/vitamins/blowers.scad>
include <NopSCADlib/vitamins/zipties.scad>

include <../utils/carriageTypes.scad>
include <../utils/PrintheadOffsets.scad>
include <../utils/ziptieCutout.scad>
include <../utils/rounded_cutout.scad>

use <../vitamins/DropEffectXG.scad>
use <X_Carriage.scad>
use <X_CarriageAssemblies.scad>
use <X_CarriageFanDuct.scad>

function xCarriageDropEffectXGSize(xCarriageType, beltWidth) = [xCarriageBeltSideSize(xCarriageType, beltWidth).x, 5, xCarriageBeltSideSize(xCarriageType, beltWidth).z];
function blowerOffset() = [0, -3, -4]; // -3 is experimental, -2 gives more clearance for blower wire, -2.25 just clears boltholes
sideZipTieCutoutSize = [8, 3.5, 2];

module xCarriageDropEffectXG(hotendDescriptor, inserts=false) {
    xCarriageType = MGN9C_carriage;
    size = xCarriageDropEffectXGSize(xCarriageType, beltWidth()); // [30, 5, 54]
    hotendOffset = printheadHotendOffset(hotendDescriptor);
    blower = BL30x10;
    blowerOffset = blowerOffset();

    fillet = 1.5;

    difference() {
        union() {
            //xCarriageBack(xCarriageType, size, extraX, holeSeparationTop, holeSeparationBottom, strainRelief=false, countersunk=4, topHoleOffset=-xCarriageBeltAttachmentMGN9CExtraX()/2, accelerometerOffset = accelerometerOffset());
            xCarriageDropEffectXGBack(xCarriageType, size, fillet);
            DropEffectXGHolder(hotendDescriptor, size, blowerOffset, fillet);
        }
        xCarriageDropEffectXGSideZipTiePositions(size, hotendOffset, blowerOffset, sideZipTieCutoutSize.y)
            zipTieFullCutout(size=sideZipTieCutoutSize, triangular=true);

        translate(hotendOffset)
            rotate(90)
                DropEffectXGSideBoltPositions()
                    translate_z(size.y)
                        boltPolyholeM3Countersunk(size.y);
        translate([-size.x/2, hotendOffset.y + blower_width(blower)/2 + blowerOffset.y, hotendOffset.z + blowerOffset.z - 27.8]) // -27.8 leaves fan duct level with bottom of X_Carriage
            rotate(-90) {
                rotate([90, 0, 0])
                    blower_hole_positions(blower)
                        vflip()
                            boltHoleM2p5Tap(5, horizontal=true, rotate=90, chamfer_both_ends=false);
                fanDuctHolePositions(blower)
                    vflip()
                        boltHoleM2p5Tap(5, horizontal=true, rotate=90, chamfer_both_ends=false);
            }
        translate([0, -railCarriageGap(), 0])
            xCarriageHotendSideHolePositions(xCarriageType)
                if (inserts) {
                    insertHoleM3(size.y);
                } else {
                    //boltHoleM3Tap(size.y, horizontal=true, rotate=180);
                   boltHoleM3Tap(size.y + 5);
                }
    }
}

module DropEffectXGHolder(hotendDescriptor, size, blowerOffset, baseFillet) {
    hotendOffset = printheadHotendOffset(hotendDescriptor);
    fillet = 1;

    carriageSizeY = 20; // carriage_size(MGN9C_carriage), since coordinates are based on center of MGN X carriage
    boltCoverSizeX = 5;

    translate([-size.x/2, carriageSizeY/2, hotendOffset.z]) {
        sizeTop = [size.x, hotendOffset.y + 10 + blowerOffset.y, xCarriageTopThickness() - 1];
        translate_z(xCarriageTopThickness() - sizeTop.z)
            difference() {
                union() {
                    rounded_cube_xz([sizeTop.x, 10, sizeTop.z], fillet);
                    rounded_cube_xz([5, sizeTop.y, sizeTop.z], fillet);
                    translate([5, 10, 0]) {
                        fillet(7, sizeTop.z);
                        translate([-2, 0, 0])
                            cube([2, 8, sizeTop.z]); // fill in gap caused by fillet on sizeTop
                    }
                    // extension for blower bolt holes
                    extensionZ = xCarriageTopThickness() - sizeTop.z + 3;
                    translate_z(-extensionZ + blowerOffset.z) {
                        rounded_cube_xz([boltCoverSizeX, sizeTop.y, sizeTop.z + extensionZ], fillet);
                        translate([sizeSide.x, 0, 0])
                            rotate([-90, 0, 0])
                                fillet(fillet, sizeTop.y);
                    }
                }
                *translate([hotendOffset.x + sizeTop.x/2, hotendOffset.y - carriageSizeY/2, 0]) {
                    // hole for hotend adaptor
                    boltHole(17.5, sizeTop.z, horizontal=true, chamfer=0.5);
                }
            }

        sizeSide = [2, sizeTop.y, size.z - 11 - blowerOffset.z];
        translate_z(xCarriageTopThickness() - sizeSide.z) {
            translate_z(2*fillet)
               cube(sizeSide - [0, 0, 4*fillet]);
            sizeBoltCover = [boltCoverSizeX, sizeTop.y, 12 - blowerOffset.z];
            rounded_cube_xz(sizeBoltCover, fillet);
            translate([sizeSide.x, 0, sizeBoltCover.z])
                rotate([-90, -90, 0])
                    fillet(fillet, sizeTop.y);
        }

        sizeBaffle = [6.5, sizeTop.y, 3];
        translate_z(-23 - sizeBaffle.z) {
            rounded_cube_xz(sizeBaffle, 0.5);
            translate([5,0,0])
                rotate([-90, 0, 0])
                    fillet(fillet, sizeTop.y);
            *translate([0, 12.5, 0])
                rounded_cube_xz([sizeBaffle.x + 1, 14, sizeBaffle.z], 0.5); // extra baffle
            translate_z(-12)
                rounded_cube_xz([sizeBaffle.x, 6, 13], 0.5); // bolt cover
        }
        // fill in gap between back bolt extensions and boltcover
        translate_z(xCarriageTopThickness() - hotendOffset.z - size.z)
            rounded_cube_xz([boltCoverSizeX, 6, 12], baseFillet);
    }
}

module xCarriageDropEffectXG_hotend(hotendOffset, fan=true) {
    xCarriageType = MGN9C_carriage;
    size = xCarriageDropEffectXGSize(xCarriageType, beltWidth());

    translate(hotendOffset) {
        rotate(90) {
            /*DropEffectXGTopBoltPositions(xCarriageTopThickness() - 2)
                boltM2p5Caphead(10);
            */
            DropEffectXGSideBoltPositions()
                translate_z(size.y)
                    explode(50)
                        boltM3Countersunk(8);
            explode(-50, true) {
                DropEffectXG();
                if (fan)
                    explode([0, -50, 0], true)
                        not_on_bom()
                            DropEffectXGFan();
            }
        }
    }
}

module xCarriageDropEffectXG_hardware(hotendDescriptor, blowerOffset) {
    xCarriageType = MGN9C_carriage;
    hotendOffset = printheadHotendOffset(hotendDescriptor);
    size = xCarriageDropEffectXGSize(xCarriageType, beltWidth());
    blower = BL30x10;

    xCarriageDropEffectXG_hotend(hotendOffset, fan=true);

    translate([-size.x/2, hotendOffset.y + blower_width(blower)/2 + blowerOffset.y, hotendOffset.z + blowerOffset.z - 27.8]) // -27.8 leaves fan duct level with bottom of X_Carriage
        rotate(-90) {
            rotate([90, 0, 0])
                explode(40, true, show_line=false) {
                    blower(blower);
                    blower_hole_positions(blower)
                        translate_z(blower_lug(blower))
                            boltM2p5Caphead(6);
                }
            explode([0, -40, -10], true) {
                stl_colour(pp2_colour)
                    DropEffectXG_Fan_Duct_stl();
                Fan_Duct_hardware(blower);
            }
        }

    xCarriageDropEffectXGStrainReliefCableTiePositions(xCarriageType)
        translate([1, railCarriageGap() + 2, 0])
            if (!exploded())
                ziptie(small_ziptie, r=3.5, t=5.0);

    xCarriageDropEffectXGSideZipTiePositions(size, hotendOffset, blowerOffset, sideZipTieCutoutSize.y)
        rotate([-90, 0, 0])
            translate([0, -2.5, 0])
                if (!exploded())
                    ziptie(small_ziptie, r=2.5, t=2.5);
    translate([size.x/4, 11.5, 11.75])
        rotate([0, 90, 0])
            if (!exploded())
                ziptie(small_ziptie, r=2.5, t=4.5);
    translate([size.x/2 + 0.5, 11.5, 35 - size.z])
        rotate([0, 180, 0])
            if (!exploded())
                ziptie(small_ziptie, r=3.5, t=0.5);
}

module xCarriageDropEffectXGBack(xCarriageType, size, fillet) {
    /*holeSeparationTop = xCarriageHoleSeparationTop(xCarriageType);
    holeSeparationBottom = xCarriageHoleSeparationBottom(xCarriageType);
    extraX = 0;
    xCarriageBack(xCarriageType, size, extraX, holeSeparationTop, holeSeparationBottom, strainRelief=false, countersunk=4, topHoleOffset=-xCarriageBeltAttachmentMGN9CExtraX()/2, accelerometerOffset = accelerometerOffset());
    */

    sizeX = [size.x, size.y, size.z + 6];
    carriageSize = carriage_size(xCarriageType);
    topThickness = xCarriageTopThickness();
    baseThickness = xCarriageBaseThickness();

    translate([-size.x/2, carriageSize.y/2, topThickness - size.z]) {
        difference() {
            union() {
                rounded_cube_xz(sizeX, fillet);
                translate([16, 0, size.z + 6])
                rotate([-90,-90,0])
                    fillet(4, size.y);
            }
            // hotend fan exhaust outlet
            translate([2, -eps, baseThickness + 13.5])
                rounded_cube_xz([10, size.y + 2*eps, 16], 1);
            // ziptie cutout
            translate([size.x - 4, -eps, 25])
                rounded_cube_xz([2, size.y + 2*eps, 4.5], 0.5);
            // top ziptie cutout
            translate([3*size.x/4 - 4.5/2, -eps, size.z])
                rounded_cube_xz([4.5, size.y + 2*eps, 1.5], 0.5);
        }
        // extra extensions for bottom bolts
        rounded_cube_xz([size.x, size.y + 1, baseThickness], fillet);
        // extra extensions for top bolts
        /*translate_z(-topThickness)
            rounded_cube_xz([size.x, size.y + 2, topThickness], fillet);*/
        xCarriageDropEffectXGStrainRelief(carriageSize, size, fillet);
    }
}

module xCarriageDropEffectXGStrainReliefCableTieOffsets(strainReliefSizeX) {
    for (z = [10, 20, 30])
       translate([strainReliefSizeX/2, 0, z])
            children();
}

module xCarriageDropEffectXGStrainReliefCableTiePositions(xCarriageType, strainReliefSizeX=16) {
    xCarriageBackSizeX = xCarriageDropEffectXGSize(xCarriageType, beltWidth()).x;
    carriageSize = carriage_size(xCarriageType);

    translate([-xCarriageBackSizeX/2 - 1, carriageSize.y/2, xCarriageBaseThickness()])
        xCarriageDropEffectXGStrainReliefCableTieOffsets(strainReliefSizeX)
            children();
}

module xCarriageDropEffectXGStrainRelief(carriageSize, xCarriageBackSize, fillet) {
    strainReliefSizeX =  16;
    tabSize = [strainReliefSizeX, xCarriageBackSize.y, 27.5 + 10 + 2*fillet]; // ensure room for bolt heads

    translate_z(xCarriageBackSize.z)
        difference() {
            translate_z(-2*fillet)
                rounded_cube_xz(tabSize, fillet);
            cutoutSize = [2, tabSize.y + 2*eps, 4.5];
            xCarriageDropEffectXGStrainReliefCableTieOffsets(strainReliefSizeX)
                for (x = [-4, 4])
                    translate([x - cutoutSize.x/2, -eps, -cutoutSize.z/2])
                        rounded_cube_xz(cutoutSize, 0.5);
        }
}

module xCarriageDropEffectXGSideZipTiePositions(size, hotendOffset, blowerOffset, zipTieCutoutSizeY) {
    translate([0, hotendOffset.y, hotendOffset.z + 10.5 - zipTieCutoutSizeY/2 - 4]) {// needs to clear boltHoles
        // blower side
        translate([-size.x/2, -13, blowerOffset.z])
            rotate([90, 0, -90])
                children();
    }
}


module X_Carriage_DropEffect_XG_stl() {
    stl("X_Carriage_DropEffect_XG")
        color(pp4_colour)
            rotate([90, 0, 0])
                xCarriageDropEffectXG("DropEffectXG", inserts=false);
}

module X_Carriage_DropEffect_XG_hardware() {
    xCarriageDropEffectXG_hardware("DropEffectXG", blowerOffset());
}

module DropEffectXG_Fan_Duct_stl() {
    stl("DropEffectXG_Fan_Duct")
        color(pp2_colour)
            fanDuct(blower=BL30x10, jetOffset=[-0.75, 22, -8], chimneySizeZ=14 + blowerOffset().z);
}

