include <LeftAndRightFaces.scad>

include <NopSCADlib/vitamins/cameras.scad>
use <NopSCADlib/vitamins/pcb.scad>

include <../vitamins/cables.scad>
use <../vitamins/extruder.scad>


module Left_Face_stl() {
    assert(_useReversedBelts==false);
    assert(_chordLengths.x == 220);
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Left_Face")
        color(pp1_colour)
            leftFace(NEMA14T(), useFrontSwitch=_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
            //cube([eY + 2*eSizeY, eZ, eSizeX]);
}

module Left_Face_NEMA_17_stl() {
    assert(_useReversedBelts==false);
    assert(_chordLengths.x == 220);
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Left_Face_NEMA_17")
        color(pp1_colour)
            leftFace(NEMA17_40, useFrontSwitch=_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
            //cube([eY + 2*eSizeY, eZ, eSizeX]);
}

module Left_Face_y200_z200_stl() {
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Left_Face_y200_z200")
        color(pp1_colour)
            leftFace(NEMA14T(), useFrontSwitch=_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
}

module Left_Face_y220_z210_stl() {
    assert(_chordLengths.y == 220);
    assert(_chordLengths.z == 210);
    stl("Left_Face_y220_z210")
        color(pp1_colour)
            leftFace(NEMA14T(), useFrontSwitch=_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
}

module Right_Face_stl() {
    assert(_useReversedBelts==false);
    assert(_chordLengths.x == 220);
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Right_Face")
        color(pp1_colour)
            rightFace(NEMA14T(), useIEC=!_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
}

module Right_Face_NEMA_17_stl() {
    assert(_useReversedBelts==false);
    assert(_chordLengths.x == 220);
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Right_Face_NEMA_17")
        color(pp1_colour)
            rightFace(NEMA17_40, useIEC=!_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
            //cube([eY + 2*eSizeY, eZ, eSizeX]);
}
module Right_Face_y200_z200_stl() {
    assert(_chordLengths.y == 200);
    assert(_chordLengths.z == 200);
    stl("Right_Face_y200_z200")
        color(pp1_colour)
            rightFace(NEMA14T(), useIEC=!_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
}

module Right_Face_y220_z210_stl() {
    assert(_chordLengths.y == 220);
    assert(_chordLengths.z == 210);
    stl("Right_Face_y220_z210")
        color(pp1_colour)
            rightFace(NEMA14T(), useIEC=!_useFrontSwitch, reversedBelts=_useReversedBelts, fan=_useReversedBelts);
}
module leftFaceAssembly() {
    translate([-eps, 0, 0])
        rotate([90, 0, 90]) {
            if (_xyMotorDescriptor == "NEMA14") {
                if (_useReversedBelts) {
                    if (eZ == 200)
                        Left_Face_y200_z200_stl();
                    else
                        Left_Face_y220_z210_stl();
                } else {
                    Left_Face_stl();
                }
            } else {
                Left_Face_NEMA_17_stl();
            }
        }
}

module leftFaceHardware(NEMA_type, cnc=false, rocker=true) {
    stepper_motor_cable(400);
    rotate([90, 0, 90]) {
        if (!cnc) {
            XY_IdlerBracketHardware(coreXYPosBL(NEMA_width(NEMA_type), carriageType(_yCarriageDescriptor)));
            XY_MotorUprightHardware(NEMA_type, left=true);
            if (_useFrontSwitch)
                translate(rockerPosition(rocker_type()))
                    rotate([0, -90, 0])
                        rocker(rocker_type(), "red");
        }
        if (!exploded() && !cnc)
            leftAndRightFaceZipTies(left=true, lowerZipTies=!cnc);
    }
}

rpi_camera_zero_pcb = ["", "",
    5, 7, 1,
    0, // corner radius
    0, // mounting hole diameter
    0, // pad around mounting hole
    "green", // color
    false, // true if parts should be separate BOM items
    [], // hole positions
    [
        //[12,   3.25,  0, "-flat_flex", true],
        //[-4.5, -5,    0, "smd_led", LED0603, "red"],
        //[-5.5, -4,    0, "smd_res", RES0603, "1K2"],
    ],
    []];

rpi_camera_zero = ["rpi_camera_zero", "Raspberry Pi Zero camera", rpi_camera_zero_pcb,
    [0, 0],
    [
        [[8, 8, 3], 0],
        [[0, 0, 4], 7.5 / 2],
        [[0, 0, 5], 5.5 / 2, [1.5/2, 2/2, 0.5]],
    ],
    [0, 12+10 - 1.5 - 2.5], [8, 5, 1],
    [54, 41] // FOV
];


//!1. Place the cork damper on the stepper motor and bolt the motor to the frame.
//!Note the cork damper is important as it provides thermal insulation between the stepper motor and the frame.
//!Note orientation of the JST connector.
//!2. Secure the motor wires with zip ties.
//!3. Bolt the front idler pulleys with washers to the frame.
//!4. Attach the wires to the switch and bolt the **Switch_Shroud** to the left face.
//
module Left_Face_assembly(camera=false, fov_distance=0) pose(a=[55, 0, 25 + 50])
assembly("Left_Face", big=true) {

    stl_colour(pp1_colour)
        leftFaceAssembly();
    leftFaceHardware(xyMotorType());
    if (_useFrontSwitch) {
        explode([25, 0, 0])
            Switch_Shroud_assembly();
        Switch_Shroud_bolts();
    }
    if (camera) {
        cameraType = rpi_camera_zero;
        cameraPCBSize = pcb_size(camera_pcb(cameraType));
        translate([eSizeX + cameraPCBSize.x/2, 3, 145])
            rotate([-90, 0, -45])
                translate_z(5)
                    camera(cameraType, fov=[160, 160], fov_distance=fov_distance);
    }
}

//!1. Place the cork damper on the stepper motor and bolt the motor to the frame.
//!Note the cork damper is important as it provides thermal insulation between the stepper motor and the frame.
//!Note orientation of the JST connector.
//!2. Secure the motor wires with zip ties.
//!3. Bolt the front idler **F623** bearings with washers to the frame.
//
module Left_Face_RB_assembly(camera=false, fov_distance=0) pose(a=[55, 0, 25 + 50])
assembly("Left_Face_RB", big=true) {

    stl_colour(pp1_colour)
        leftFaceAssembly();
    stl_colour(pp2_colour)
        XY_Motor_Mount_Brace_Left_stl();
    XY_Motor_Mount_RB_hardware(xyMotorType(), left=true);
    coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
    rotate([90, 0, 90])
        XY_IdlerBracketHardware(coreXYPosBL, reversedBelts=true, left=true);
    if (camera) {
        cameraType = rpi_camera_zero;
        cameraPCBSize = pcb_size(camera_pcb(cameraType));
        translate([eSizeX + cameraPCBSize.x/2, 3, 145])
            rotate([-90, 0, -45])
                translate_z(5)
                    camera(cameraType, fov=[160, 160], fov_distance=fov_distance);
    }
}

module rightFaceFan(fan, offset, boltOffset=_sidePlateThickness) {
    translate(rightFaceFanPosition(fan, offset))
       rotate([0, 90, 0]) {
            explode(-40)
                fan(fan);
            fan_hole_positions(fan) {
                translate_z(boltOffset)
                    boltM3Buttonhead(screw_longer_than(fan_depth(fan) + nut_thickness(M3_nut) + boltOffset));
                translate_z(-fan_depth(fan))
                    vflip()
                        explode(70, true)
                            nut(M3_nut);
            }
        }
}

module IEC_hardware() {
    translate(iecPosition())
        rotate([0, 90, 0]) {
            iec(iecType());
            translate([0, -12, 2 + eps])
                rotate(90)
                    not_on_bom() no_explode()
                        rocker(small_rocker, "red");
            iec_screw_positions(iecType())
                translate_z(3)
                    boltM3Countersunk(12);
        }
}

module IEC_Housing() {
    translate(iecPosition())
        rotate([-90, 0, -90])
            color(pp4_colour)
                IEC_Housing_stl();
}

module rightFaceStage1Assembly() {
    translate([eX + 2 * eSizeX + eps, 0, 0])
        rotate([90, 0, -90])
            if (_xyMotorDescriptor=="NEMA14") {
                if (_useReversedBelts) {
                    if (eZ == 200)
                        Right_Face_y200_z200_stl();
                    else
                        Right_Face_y220_z210_stl();
                } else {
                    Right_Face_stl();
                }
            } else {
                Right_Face_NEMA_17_stl();
            }
}

//!1. Place the cork damper on the stepper motor and bolt the motor to the frame.
//! Note the cork damper is important as it provides thermal insulation between the stepper motor and the frame.
//! Note orientation of the JST connector.
//!2. Attach the toothed idler pulleys to the frame, separated by the washers as shown.
//!3. Thread the zip ties through the frame, but do not tighten them yet, since the extruder motor cable will also go through
//!the zip ties.
module Right_Face_Stage_1_assembly() pose(a=[55, 0, 25 + 260])
assembly("Right_Face_Stage_1", big=true, ngb=true) {

    stl_colour(pp1_colour)
        rightFaceStage1Assembly();
    if (_useReversedBelts) {
        stl_colour(pp2_colour)
            vflip()
                XY_Motor_Mount_Brace_Right_stl();
        XY_Motor_Mount_RB_hardware(xyMotorType(), left=false);
        coreXYPosBL = coreXYPosBL(_xyNEMA_width, carriageType(_yCarriageDescriptor));
        translate([eX + 2*eSizeX, 0, 0])
            rotate([90, 0, 90])
                vflip()
                    mirror([0, 1, 0])
                        XY_IdlerBracketHardware(coreXYPosBL, reversedBelts=true, left=false);

    } else {
        rightFaceHardware(xyMotorType());
    }
}

module rightFaceAssembly(NEMA_width, zipTies=true) {

    stepper_motor_cable(300); // cable to extruder motor
    if (!exploded() && zipTies)
        rightFaceExtruderZipTies(NEMA_width);
    corkDamperThickness = _useCNC ? 0 : _corkDamperThickness; // no cork damper necessary to between motor and CF right side
    translate(extruderPosition(NEMA_width))
        rotate([90, 0, 90])
            Extruder_MK10_Dual_Pulley(extruderMotorType(), motorOffsetZ = extruderMotorOffsetZ() + corkDamperThickness, corkDamperThickness=corkDamperThickness);

    if (!_useFrontSwitch) {
        explode([-80, 0, 0], show_line=false)
            IEC_Housing();
        explode([40, 0, 0], true, show_line=false)
            IEC_hardware();
    }
}


module rightFaceHardware(NEMA_type, cnc=false) {
    translate([eX + 2*eSizeX, 0, 0])
        rotate([-90, 0, 90])
            mirror([0, 1, 0])
                if (!cnc) {
                    XY_IdlerBracketHardware(coreXYPosBL(NEMA_width(NEMA_type), carriageType(_yCarriageDescriptor)));
                    XY_MotorUprightHardware(NEMA_type, left=false);
                    if (!exploded())
                        leftAndRightFaceZipTies(left=false, lowerZipTies=!cnc);
                }
}

//!1. Attach the extruder gear to the stepper motor.
//!2. Place the cork damper on the stepper motor and attach the motor through the frame to the extruder. Note the cork
//!damper is important as it provides thermal insulation between the stepper motor and the frame.
//!3. Secure the cables for both motors with the zip ties.
module Right_Face_assembly() pose(a=[55, 0, 25 - 45])
assembly("Right_Face") {
    Right_Face_Stage_1_assembly();
    rightFaceAssembly(_xyNEMA_width);

    fan = fan30x10;
    if (_useReversedBelts)
        rightFaceFan(fan, fanOffsetRB, boltOffset=-fanOffsetRB.x);
}
