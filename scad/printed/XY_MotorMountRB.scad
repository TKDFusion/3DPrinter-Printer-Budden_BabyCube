include <XY_Motors.scad>


backSizeY = 5;
sideSizeX = _useCNC ? 5 : 4.5;
braceHeight = 10 - xyMotorMountBasePlateThickness();

pulleyStackHeight = 2*washer_thickness(coreXYIdlerBore() == 3 ? M3_washer : coreXYIdlerBore() == 4 ? M4_shim : M5_shim) + pulley_height(coreXY_plain_idler(coreXY_type()));

function xyMotorMountRBSize(NEMA_width) = [
    floor(NEMA_width) + 10,
    floor(NEMA_width) + 8 + (useReversedBelts() ? motorClearance().y - 12 : 0),
    38 + xyMotorMountBasePlateThickness()
];

module xyMotorMountBeltGuide(sizeZ=10) {
    fillet = 0.5;
    size = [2, 7 + fillet, sizeZ + eps];
    translate([-size.x/2, fillet - size.y, 0]) {
         rounded_cube_xy(size, fillet);
         translate([-size.y + fillet, size.y - fillet, 0])
            rounded_cube_xy([2*(size.y + fillet), 1, size.z], 0.45);
    }
    translate([-size.x/2, 0, 0])
        rotate(180)
            fillet(size.y - 2*fillet, size.z);
    translate([size.x/2, 0, 0])
        rotate(270)
            fillet(size.y - 2*fillet, size.z);
}

module rounded_cube(xyz, size, fillet) {
    if (xyz==0)
        rounded_cube_yz(size, fillet)
            children();
    else if (xyz==1)
        rounded_cube_xz(size, fillet)
            children();
    else if (xyz==2)
        rounded_cube_xy(size, fillet)
            children();
    else
        assert(false);
}

module xyMotorMountRB(NEMA_type, left, xyz=2) {
    assert(isNEMAType(NEMA_type));

    NEMA_width = NEMA_width(NEMA_type);
    size = xyMotorMountRBSize(NEMA_width);
    basePlateThickness = xyMotorMountBasePlateThickness();
    backSize = [size.x, backSizeY, size.z];
    sideSize = [sideSizeX, size.y, size.z];
    fillet = 1;
    offsetZ = eZ - _topPlateThickness - size.z;

    difference() {
        translate_z(offsetZ)
            union() {
                // baseplate for motor with cutouts
                translate([ left ? _sidePlateThickness : eX + 2*eSizeX - _sidePlateThickness - size.x, eY + 2*eSizeY, 0]) {
                    translate([0, -size.y, 0])
                        rounded_cube(xyz, [size.x, size.y, basePlateThickness], fillet);
                    translate([left ? 0 : size.x - sideSize.x, -sideSize.y, 0])
                        rounded_cube(xyz, sideSize, fillet);
                    translate([0, -backSize.y, 0]) {
                        cutoutSize = [8, 0, 15];
                        rounded_cube(xyz, [backSize.x, backSize.y, backSize.z - cutoutSize.z], fillet);
                        translate([left ? 0 : cutoutSize.x, 0, 0])
                            rounded_cube(xyz, [backSize.x - cutoutSize.x, backSize.y, backSize.z], fillet);
                    }
                    translate([left ? sideSize.x : size.x - sideSize.x, -backSize.y, 0])
                        rotate(left ? -90 : 180)
                            fillet(5, basePlateThickness + 2*coreXYSeparation().z - 1);
                    if (left)
                        translate([sideSize.x + 9.5 + 26/2, -backSize.y, basePlateThickness])
                            xyMotorMountBeltGuide();
                }
            }
        translate([left ? coreXYPosBL(NEMA_width).x : coreXYPosTR(NEMA_width).x, coreXYPosTR(NEMA_width).y, offsetZ]) {
            boltHoleM3Tap(basePlateThickness, horizontal=(xyz==0), rotate=-90);
            translate(left ? leftDrivePulleyOffset() : rightDrivePulleyOffset()) {
                boltHole(NEMA_boss_radius(NEMA_type)*2 + 1, basePlateThickness, horizontal=(xyz==0), rotate=left ? -90 : 90);
                NEMA_screw_positions(NEMA_type)
                    boltHoleM3(basePlateThickness, horizontal=(xyz==0), rotate=left ? -90 : 90);
            }
        }

        if (xyz == 2) // side holes not needed when xyMotorMount incorporated in Left_Face stl file
            translate([left ? _sidePlateThickness : eX + 2*eSizeX - _sidePlateThickness, 0, 0])
                rotate([90, 0, 90])
                    xyMotorMountSideHolePositions()
                        vflip(!left)
                            boltHoleM3Tap(sideSize.x, horizontal=true, rotate=left ? 0 : 180, chamfer_both_ends=false);
        translate([0, eY + 2*eSizeY, 0])
            rotate([90, 0, 0])
                xyMotorMountBackHolePositions(left)
                    boltHoleM3Tap(backSize.y, horizontal=true, rotate=(xyz == 0 ? (left ? -90 : 90) : 0), chamfer_both_ends=false);
        xyMotorMountTopHolePositions(left, eZ - _topPlateThickness)
            vflip()
                boltHoleM3Tap(sideSize.x, horizontal=(xyz==0), left ? -90 : 90);
        translate([0, eY + 2*eSizeY - backSizeY, offsetZ + basePlateThickness + 2*pulleyStackHeight + yCarriageBraceThickness() + braceHeight/2])
            translate([left ? _sidePlateThickness + sideSizeX + size.x/2 : eX + 2*eSizeX - _sidePlateThickness - sideSizeX - size.x/2, 0, 0])
                rotate([-90, 0, 0])
                    boltHoleM3Countersunk(backSizeY, horizontal=true, rotate=(xyz == 0 ? (left ? -90 : 90) : 180));
    }
}

module xyMotorMountRBBrace(NEMA_type, left) {
    assert(isNEMAType(NEMA_type));

    NEMA_width = NEMA_width(NEMA_type);
    xyMotorMountRBSize = xyMotorMountRBSize(NEMA_width);
    size = [xyMotorMountRBSize(NEMA_width).x - sideSizeX, motorClearance().y + 3, braceHeight];
    fillet = 1;

    offsetZ  = eZ - _topPlateThickness - xyMotorMountRBSize.z + xyMotorMountBasePlateThickness() + 2*pulleyStackHeight + yCarriageBraceThickness();
    difference() {
        translate([0, eY + 2*eSizeY - backSizeY - size.y, offsetZ])
            translate([left ? _sidePlateThickness + sideSizeX : eX + 2*eSizeX - _sidePlateThickness - sideSizeX - size.x, 0, 0]) {
                cutoutSize = [8, 2];
                rounded_cube_xy([size.x, size.y - cutoutSize.y, size.z], fillet);
                translate([left ? 0 : cutoutSize.x, 0, 0])
                    rounded_cube_xy([size.x - cutoutSize.x, size.y, size.z], fillet);
                translate([left ? size.x - cutoutSize.x : cutoutSize.x, size.y - cutoutSize.y, 0])
                    rotate(left ? 0 : 90)
                        fillet(fillet, size.z);
                if (!left)
                    translate([4.5 + 26/2, size.y - 1, -10])
                        xyMotorMountBeltGuide(10);
            }
        translate([left ? coreXYPosBL(NEMA_width).x : coreXYPosTR(NEMA_width).x, coreXYPosTR(NEMA_width).y, offsetZ])
            translate(left ? leftDrivePulleyOffset() : rightDrivePulleyOffset()) {
                translate_z(-eps)
                    poly_cylinder(r=10, h=size.z + 2*eps);
                NEMA_screw_positions(NEMA_type, 2)
                    translate_z(size.z)
                        boltHoleM3Countersunk(size.z);
            }
        translate([0, eY + 2*eSizeY - backSizeY, offsetZ])
            translate([left ? _sidePlateThickness + (3*sideSizeX + size.x)/2 : eX + 2*eSizeX - _sidePlateThickness - (3*sideSizeX + size.x)/2, 0, braceHeight/2])
                rotate([90, 0, 0])
                    boltHoleM3Tap(size.y, horizontal=true);
    }
}

module XY_Motor_Mount_Left_stl() {
    NEMA_type = NEMA14_36;

    stl("XY_Motor_Mount_Left")
        color(pp1_colour)
            xyMotorMountRB(NEMA_type, left=true);
}

module XY_Motor_Mount_Right_stl() {
    NEMA_type = NEMA14_36;

    stl("XY_Motor_Mount_Right")
        color(pp1_colour)
            xyMotorMountRB(NEMA_type, left=false);
}

module XY_Motor_Mount_Brace_Left_stl() {
    NEMA_type = NEMA14_36;

    stl("XY_Motor_Mount_Brace_Left")
        color(pp2_colour)
            xyMotorMountRBBrace(NEMA_type, left=true);
}

module XY_Motor_Mount_Brace_Right_stl() {
    NEMA_type = NEMA14_36;

    stl("XY_Motor_Mount_Brace_Right")
        color(pp2_colour)
            vflip()
                xyMotorMountRBBrace(NEMA_type, left=false);
}

module XY_Pulley_Spacer_M3_stl() {
    stl("XY_Pulley_Spacer_M3");
    color(pp3_colour)
        difference() {
            h = pulleyStackHeight + yCarriageBraceThickness();
            cylinder(h=h, d=7);
            boltHoleM3(h);
        }
}

//!1. Place the cork damper on the stepper motor and bolt the motor to the **XY_Motor_Mount_Right**, using two bolts at the front,
// as shown. Note orientation of the JST connector.
//!2. Bolt the bearing, washers, and spacer **XY_Motor_Mount_Right** as shown. The bolts screw into the mounting holes on the stepper motor.
//!It's easier to do this if the motor mount is turned upside down.
//!3. Bolt the **XY_Motor_Mount_Brace_Right** to the **XY_Motor_Mount_Right**.
//!3. Bolt the pulley to the motor shaft, aligning it with the bearings.
//!
//! Note the cork damper is important as it provides thermal insulation between the stepper motor and the frame.
//
module XY_Motor_Mount_Left_RB_assembly()
assembly("XY_Motor_Mount_Left_RB", big=true, ngb=true) {

    NEMA_type = xyMotorType();

    stl_colour(pp1_colour)
        XY_Motor_Mount_Left_stl();
    if (useReversedBelts()) {
        explode(70, show_line=false)
            stl_colour(pp2_colour)
                XY_Motor_Mount_Brace_Left_stl();
    }
    XY_Motor_Mount_RB_hardware(NEMA_type, left=true);
}

//!1. Place the cork damper on the stepper motor and bolt the motor to the **XY_Motor_Mount_Right**, using two bolts at the front,
// as shown. Note orientation of the JST connector.
//!2. Bolt the bearing, washers, and spacer **XY_Motor_Mount_Right** as shown. The bolts screw into the mounting holes on the stepper motor.
//!3. Bolt the **XY_Motor_Mount_Brace_Right** to the **XY_Motor_Mount_Right**.
//!3. Bolt the pulley to the motor shaft, aligning it with the bearings.
//!
//! Note the cork damper is important as it provides thermal insulation between the stepper motor and the frame.
//
module XY_Motor_Mount_Right_RB_assembly()
assembly("XY_Motor_Mount_Right_RB", big=true, ngb=true) {

    NEMA_type = xyMotorType();

    stl_colour(pp1_colour)
        XY_Motor_Mount_Right_stl();
    if (useReversedBelts()) {
        explode(70, show_line=false)
            stl_colour(pp2_colour)
                vflip()
                    XY_Motor_Mount_Brace_Right_stl();
    }
    XY_Motor_Mount_RB_hardware(NEMA_type, left=false);
}

module XY_Motor_Mount_RB_hardware(NEMA_type, left=true) {
    NEMA_width = NEMA_width(NEMA_type);
    coreXYPosBL = coreXYPosBL(NEMA_width);
    coreXYPosTR = coreXYPosTR(NEMA_width);
    separation = coreXYSeparation();
    coreXY_type = coreXY_type();
    washer = M3_washer;
    basePlateThickness = xyMotorMountBasePlateThickness();

    //braceOffsetZ = 2*bearingStackHeight() + yCarriageBraceThickness() + 0.5; // tolerance of 0.5

    translate_z(eZ - _topPlateThickness - xyMotorMountRBSize(NEMA_width).z + basePlateThickness) {
        offsetX = _sidePlateThickness + sideSizeX + xyMotorMountRBSize(NEMA_width).x/2;
        translate([left ? offsetX : eX + 2*eSizeX - offsetX, eY + 2*eSizeY, 2*pulleyStackHeight + yCarriageBraceThickness() + braceHeight/2])
            rotate([90, 0, 180])
                explode(20, true)
                    boltM3Countersunk(12);
        translate(left ? [coreXYPosBL.x, coreXYPosTR.y] : [coreXYPosTR.x, coreXYPosTR.y]) {
            translate(left ? leftDrivePulleyOffset() : rightDrivePulleyOffset()) {
                corkDamperThickness = 2;
                translate_z(-basePlateThickness - corkDamperThickness) {
                    explode(-20)
                        corkDamper(NEMA_type, corkDamperThickness);
                    explode(-40)
                        rotate(left ? 90 : -90)
                            NEMA(NEMA_type, jst_connector=true);
                }
                rotate(left ? 180 : 180)
                    NEMA_screw_positions(NEMA_type, 2)
                        boltM3Caphead(8);
                translate_z(left ? 15 : 5)
                    vflip(left)
                        pulley(coreXY_drive_pulley(coreXY_type));
            }
            if (useReversedBelts()) {
                motorBoltHoleDepth = 5;
                bearingType = coreXYBearing();
                screwLength = 35;
                translate_z(screwLength - basePlateThickness - motorBoltHoleDepth)
                    explode(80, true)
                        boltM3Countersunk(screwLength);
                bearingStack(bearingType)
                    explode(25, true)
                        washer(washer)
                            explode(5, true)
                                washer(washer)
                                    explode(5, true)
                                        bearingStack(bearingType);
                translate(left ? plainIdlerPulleyOffset() : -plainIdlerPulleyOffset()) {
                    translate_z(screwLength - basePlateThickness - motorBoltHoleDepth)
                        explode(80, true)
                            boltM3Countersunk(screwLength);
                    if (left) {
                        explode(5, true)
                            bearingStack(bearingType);
                        explode(30)
                            translate_z(pulleyStackHeight)
                                stl_colour(pp3_colour)
                                    XY_Pulley_Spacer_M3_stl();
                    } else {
                        explode(5)
                            stl_colour(pp3_colour)
                                XY_Pulley_Spacer_M3_stl();
                        translate_z(separation.z)
                            explode(10, true)
                                bearingStack(bearingType);
                    }
                }
            }
        }
    }
}
