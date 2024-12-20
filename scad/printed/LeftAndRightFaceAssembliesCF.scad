include <LeftAndRightFaceAssemblies.scad>

include <NopSCADlib/vitamins/sheets.scad>

use <SpoolHolderExtras.scad>

include <../config/Parameters_CoreXY.scad>



fan = fan30x10;
fanOffsetCF = [-_sidePlateThickness, _frontPlateCFThickness + 50];

module Left_Face_Lower_Joiner_Back_stl() {
    NEMA_width = NEMA_width(xyMotorType());

    stl("Left_Face_Lower_Joiner_Back")
        difference() {
            color(pp1_colour)
                frameLower(NEMA_width, left=true, offset=_sidePlateThickness, length=120);
            lowerSideJoinerHolePositions(_sidePlateThickness, left=true)
                boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
            lowerChordHolePositions()
                rotate([90, 0, 180])
                    boltHoleM3Tap(eSizeZ - 2);
            faceConnectorHolePositions()
                rotate([90, 0, 180])
                    boltHoleM3Tap(backBoltLength(), horizontal=true);
        }
}


module Left_Face_Lower_Joiner_Front_stl() {
    stl("Left_Face_Lower_Joiner_Front")
        difference() {
            color(pp1_colour)
                translate([_sidePlateThickness, 0, _sidePlateThickness]) {
                    rounded_cube_xy([eSizeY, eZ - 70, eSizeXBase - _sidePlateThickness], _fillet);
                    rounded_cube_xy([60, eSizeZ, eSizeXBase - _sidePlateThickness], _fillet);
                    translate([eSizeY, eSizeZ, 0])
                        fillet(5, eSizeXBase - _sidePlateThickness);
                }
            frontSideJoinerHolePositions(_sidePlateThickness)
                boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
            rotate([0, -90, 0])
                frontFaceSideHolePositions()
                    vflip()
                        boltHoleM3Tap(eSizeY - _sidePlateThickness);
        }
}

module Right_Face_Lower_Joiner_Back_stl() {
    NEMA_width = NEMA_width(xyMotorType());

    stl("Right_Face_Lower_Joiner_Back")
        mirror([0, 1, 0])
            difference() {
                color(pp1_colour)
                    frameLower(NEMA_width, left=false, offset=_sidePlateThickness, length=120);
                lowerSideJoinerHolePositions(_sidePlateThickness, left=false)
                    boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
                lowerChordHolePositions()
                    rotate([90, 0, 180])
                        boltHoleM3Tap(eSizeZ - 2);
            }
}

module Right_Face_Lower_Joiner_Front_stl() {
    stl("Right_Face_Lower_Joiner_Front")
        mirror([0, 1, 0])
            difference() {
                color(pp1_colour)
                    translate([_sidePlateThickness, 0, _sidePlateThickness]) {
                        rounded_cube_xy([eSizeY, eZ - 70, eSizeXBase - _sidePlateThickness], _fillet);
                        rounded_cube_xy([35, eSizeZ, eSizeXBase - _sidePlateThickness], _fillet);
                        translate([eSizeY, eSizeZ, 0])
                            fillet(2, eSizeXBase - _sidePlateThickness);
                    }
                frontSideJoinerHolePositions(_sidePlateThickness)
                    boltHoleM3Tap(eSizeXBase - _sidePlateThickness + 2);
                lowerSideJoinerHolePositions(_sidePlateThickness, left=false)
                    boltHoleM3Tap(eSizeXBase - _sidePlateThickness);
                rotate([0, -90, 0])
                    frontFaceSideHolePositions()
                        vflip()
                            boltHoleM3Tap(eSizeY - _sidePlateThickness);
            }
}

module Left_Face_y200_z200_dxf() {
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    dxf("Left_Face_y200_z200")
        leftFaceCNC(NEMA_width(NEMA14_36));
}

module Left_Face_y220_z210_dxf() {
    assert(_chordLengths.y == 220);
    assert(_chordLengths.z == 210);
    dxf("Left_Face_y220_z210")
        leftFaceCNC(NEMA_width(NEMA14_36));
}

CF3Red = CF3;//[ "CF3",       "Sheet carbon fiber",      3, [1, 0, 0],                false,  5,  5,  [0.5, 0, 0] ];

module Left_Face_CF(render=true) {
    size = [eY + 2*eSizeY + _backPlateCFThickness, eZ];

    translate([size.x/2, size.y/2, 0])
        if (render) {
            render_2D_sheet(CF3Red, w=size.x, d=size.y)
                if (eZ == 200)
                    Left_Face_y200_z200_dxf();
                else
                    Left_Face_y220_z210_dxf();
        } else {
            if (eZ == 200)
                Left_Face_y200_z200_dxf();
            else
                Left_Face_y220_z210_dxf();
        }
}

module Right_Face_y200_z200_dxf() {
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    dxf("Right_Face_y200_z200")
        rightFaceCNC(NEMA_width(NEMA14_36));
}

module Right_Face_y220_z210_dxf() {
    assert(_chordLengths.y == 220);
    assert(_chordLengths.z == 210);
    dxf("Right_Face_y220_z210")
        rightFaceCNC(NEMA_width(NEMA14_36));
}

module Right_Face_CF(render=true) {
    size = [eY + 2*eSizeY + _backPlateCFThickness, eZ];

    translate([size.x/2, size.y/2, -_sidePlateThickness])
        if (render) {
            render_2D_sheet(CF3Red, w=size.x, d=size.y)
                if (eZ == 200)
                    Right_Face_y200_z200_dxf();
                else
                    Right_Face_y220_z210_dxf();
        } else {
            if (eZ == 200)
                Right_Face_y200_z200_dxf();
            else
                Right_Face_y220_z210_dxf();
        }
}

module leftFaceCNC(NEMA_width, toolType=CNC) {
    size = [eY + 2*eSizeY + _backPlateCFThickness, eZ];
    kerf = toolType == LSR ? lsrKerf : toolType ==WJ ? wjKerf : 0;
    kerf2 = kerf/2;

    difference() {
        sheet_2D(CF3, size.x, size.y);
        translate([-size.x/2, -size.y/2]) {
            if (NEMA_width < NEMA_width(NEMA17_40) && !_useReversedBelts)
                sideFaceMotorCutout(left=true, NEMA_width=NEMA_width, zOffset=1.5);
            sideFaceTopDogbones(toolType, plateThickness=_topPlateThickness);
            translate([_backPlateCFThickness, 0])
                sideFaceBackDogBones(toolType, plateThickness=_sidePlateThickness);
            translate([-eY - 2*eSizeY, 0])
                sideFaceBackDogBones(toolType, plateThickness=_sidePlateThickness);
            if (_useFrontSwitch)
                switchShroudHolePositions()
                    circle(r=M3_clearance_radius - kerf2);
            lowerSideJoinerHolePositions(left=true)
                circle(r=M3_clearance_radius - kerf2);
            upperSideJoinerHolePositions(reversedBelts=_useReversedBelts)
                circle(r=M3_clearance_radius - kerf2);
            backSideJoinerHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            frontSideJoinerHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            xyMotorMountSideHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            xyIdlerBracketHolePositions(NEMA_width)
                circle(r=M3_clearance_radius - kerf2);
            if (!is_undef(fan))
                translate([rightFaceFanPosition(fan, fanOffsetCF).y, rightFaceFanPosition(fan, fanOffsetCF).z])
                    rotate(90)
                        psu_grill(25, 30, grill_hole=M3_clearance_radius*2 - kerf, grill_gap=2, fn=0, avoid=[]);

        }
    }
}

module rightFaceCNC(NEMA_width, toolType=CNC) {
    size = [eY + 2*eSizeY + _backPlateCFThickness, eZ];
    kerf = toolType == LSR ? lsrKerf : toolType ==WJ ? wjKerf : 0;
    kerf2 = kerf/2;

    difference() {
        sheet_2D(CF3, size.x, size.y);
        translate([-size.x/2, -size.y/2]) {
            if (_psuDescriptor == "ASUS_FSKE_120W") {
                translate([eSizeY + 35, eSizeZ])
                    rounded_square([eY - 75, 30], 5, center=false);
            } else {
                // MainBoard cutout
                //translate([eSizeY + 35, eSizeZ])
                //    rounded_square([40, 15], 5, center=false);
                // IEC cutout
                cutoutSize = [48 - kerf2, 30 - kerf2];
                translate([iecPosition().y, iecPosition().z]) {
                    rounded_square(cutoutSize, 5, center=true);
                    for(y = [-iec_pitch(iecType())/2, iec_pitch(iecType())/2])
                        translate([0, y])
                            circle(r=M4_clearance_radius - kerf2);
                }
            }
            // fan coutout
            if (!is_undef(fan))
                translate([rightFaceFanPosition(fan, fanOffsetCF).y, rightFaceFanPosition(fan, fanOffsetCF).z]) {
                    circle(r=fan_bore(fan)/2 - 0.5 - kerf2);
                    fan_hole_positions(fan, z=0)
                        circle(r=M3_clearance_radius - kerf2);
                }
            if (NEMA_width < NEMA_width(NEMA17_40) && !_useReversedBelts)
                sideFaceMotorCutout(left=false, NEMA_width=NEMA_width, zOffset=1.5);
            sideFaceTopDogbones(toolType, plateThickness=_topPlateThickness);
            translate([_backPlateCFThickness, 0])
                sideFaceBackDogBones(toolType, plateThickness=_sidePlateThickness);
            translate([-eY - 2*eSizeY, 0])
                sideFaceBackDogBones(toolType, plateThickness=_sidePlateThickness);
            translate([extruderPosition(NEMA_width).y, extruderPosition(NEMA_width).z]) {
                circle(r=NEMA_boss_radius(extruderMotorType()) + 0.25 - kerf2);
                // extruder motor bolt holes
                NEMA_screw_positions(extruderMotorType())
                    circle(r=M3_clearance_radius - kerf2);
            }
            //spoolHolderCutout(NEMA_width, cnc=true);
            translate([spoolHolderPosition(cf=true).y, spoolHolderPosition(cf=true).z - 20, 0])
                spoolHolderBracketHolePositions(M3=true)
                    circle(r=M3_clearance_radius - kerf2);
            lowerSideJoinerHolePositions(left=false)
                circle(r=M3_clearance_radius - kerf2);
            upperSideJoinerHolePositions(reversedBelts=_useReversedBelts)
                circle(r=M3_clearance_radius - kerf2);
            backSideJoinerHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            frontSideJoinerHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            xyMotorMountSideHolePositions()
                circle(r=M3_clearance_radius - kerf2);
            xyIdlerBracketHolePositions(NEMA_width)
                circle(r=M3_clearance_radius - kerf2);
        }
    }
}

//! 1. Bolt the **Front_Face_Joiner**, the **Left_Face_Back_Joiner**, and the **Left_Face_Upper_Joiner** to the
//!**Left_Face**
//! 2. Bolt the **XY_Idler_Bracket_Left_assembly** and the **XY_Motor_Mount_Left_RB_assembly** to the **Left_Face**
//
module Left_Face_CF_assembly() pose(a=[55, 0, 25 + 50 - 20])
assembly("Left_Face_CF", big=true) {

    translate([-eps, 0, 0])
        rotate([90, 0, 90]) {
            Left_Face_CF();
            *lowerSideJoinerHolePositions(left=true)
                vflip()
                    explode(10, true)
                        boltM3Buttonhead(screw_shorter_than(topBoltHolderSize(reversedBelts=true).z + _sidePlateThickness));
            upperSideJoinerHolePositions(reversedBelts=_useReversedBelts)
                vflip()
                    explode(10, true)
                        boltM3Buttonhead(8);
            backSideJoinerHolePositions()
                vflip()
                    explode(10, true)
                        boltM3Buttonhead(10);
            frontSideJoinerHolePositions()
                vflip()
                    explode(10, true)
                        boltM3Buttonhead(10);
            xyIdlerBracketHolePositions(_xyNEMA_width)
                vflip()
                    explode(10, true)
                        boltM3Buttonhead(10);
        }
    *explode([20, 0, 0], show_line=false) {
        XY_Motor_Mount_Left_RB_assembly();
        XY_Idler_Bracket_Left_assembly();
    }
    leftFaceHardware(xyMotorType(), cnc=true);
}

//!1. Bolt the extruder and stepper motor to the **Right_Face**.
//!2. Wire up the IEC power connector and bolt it through the **Right_Face** to the **IEC_Housing_stl**.
//!3. Bolt the **Spool_Holder_Bracket** to the **Right_Face**.
//!4. Bolt the fan to the **Right_Face**.
//!5. Attach the stepper motor cable to the stepper motor.
//
module Right_Face_CF_assembly() pose(a=[55, 0, 25 - 45])
assembly("Right_Face_CF", big=true) {

    translate([eX + 2*eSizeX + eps, 0, 0])
        rotate([90, 0, 90])
            Right_Face_CF();

    translate(spoolHolderPosition(cf=true))
        rotate([-90, 0, 90]) {
            explode(-40, true, show_line=false) {
                stl_colour(pp2_colour)
                    Spool_Holder_Bracket_stl();
                spoolHolderBracketHardware(M3=true, nutExplode=60);
            }
        }
    rightFaceHardware(xyMotorType(), cnc=true);
    rightFaceAssembly(_xyNEMA_width, zipTies=false);

    if (!is_undef(fan))
        rightFaceFan(fan, fanOffsetCF);
}
