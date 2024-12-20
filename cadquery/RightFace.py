import cadquery as cq

from TypeDefinitions import T, Point2D, Point3D

import dogboneT
from LeftFace import leftFace
from fans import fan30x10, fan_bore, fan_hole_pitch
from stepper_motors import NEMA17_40, NEMA_boss_radius, NEMA_hole_pitch

from constants import fittingTolerance, cncKerf, cncCuttingRadius, lsrKerf, lsrCuttingRadius, wjKerf, wjCuttingRadius
from constants import cSizeY, cSizeZ, plateThickness
from constants import M3_clearance_radius, M4_clearance_radius


def rightFace(
    self: T,
    sizeX: float,
    sizeY: float,
    sizeZ: float,
    dogboneTolerance: float = 0,
    cuttingRadius: float = 1.5,
    kerf: float = 0,
) -> T:

    size = Point3D(sizeX, sizeY, sizeZ)

    result = leftFace(self, size.x, size.y, size.z, cuttingRadius, dogboneTolerance, kerf, grill=False)

    # fan
    fan = fan30x10
    result = (
        result.faces(">Z")
        .moveTo(68, 25)
        .circle(fan_bore(fan)/2 - 0.5)
        .rect(2*fan_hole_pitch(fan), 2*fan_hole_pitch(fan), forConstruction=True)
        .vertices()
        .circle(M3_clearance_radius - kerf/2)
        .cutThruAll()
    )

    # extruder
    motor = NEMA17_40
    result = (
        result.faces(">Z")
        .moveTo(size.x - 75, size.y - 73)
        .circle(NEMA_boss_radius(motor) + 0.25)
        .rect(NEMA_hole_pitch(motor), NEMA_hole_pitch(motor), forConstruction=True)
        .vertices()
        .circle(M3_clearance_radius - kerf/2)
        .cutThruAll()
    )

    # spool holder
    result = (
        result.faces(">Z")
        .pushPoints([(x, size.y - 80) for x in [8, 45]])
        .circle(M3_clearance_radius - kerf/2)
        .cutThruAll()
    )


    # IEC
    iecPosition = Point2D(175.5, 33)
    result = (
        result.faces(">Z")
        .pushPoints([(iecPosition.x, iecPosition.y + y) for y in [-20, 20]])
        .circle(M4_clearance_radius - kerf/2)
        .cutThruAll()
    )
    iecCutoutSize = Point2D(48, 30)
    result = (
        result.faces(">Z")
        .moveTo(iecPosition.x, iecPosition.y)
        .sketch().rect(iecCutoutSize.x, iecCutoutSize.y)
        .vertices()
        .fillet(5)
        .finalize()
        .cutThruAll()
    )

    return result


def main() -> None:
    #dxf = (cq.importers.importDXF("../BC220CF/dxfs/Right_Face_y220_z210.dxf").wires().toPending().extrude(sizeZ))

    rightFaceCNC = rightFace(cq.Workplane("XY"), sizeX=cSizeY, sizeY=cSizeZ, sizeZ=plateThickness, dogboneTolerance=fittingTolerance, cuttingRadius=cncCuttingRadius, kerf=cncKerf)
    #rightFaceLSR = rightFace(cq.Workplane("XY"), sizeX=cSizeY, sizeY=cSizeZ, sizeZ=plateThickness, dogboneTolerance=fittingTolerance, cuttingRadius=lsrCuttingRadius, kerf=lsrKerf)
    #rightFaceWJ  = rightFace(cq.Workplane("XY"), sizeX=cSizeY, sizeY=cSizeZ, sizeZ=plateThickness, dogboneTolerance=fittingTolerance, cuttingRadius=wjCuttingRadius, kerf=wjKerf)

    show_object(rightFaceCNC)
    #show_object(rightFaceLSR)
    #show_object(dxf)


# check if running in cq-editor
if 'show_object' in globals():
    main()
