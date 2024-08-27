import cadquery as cq
from typing import (TypeVar)
T = TypeVar("T", bound="Workplane")

import dogboneT
import TopFaceWiringCutout
from exports import exports
from constants import fittingTolerance, cncKerf, cncCuttingRadius, lsrKerf, lsrCuttingRadius, wjKerf, wjCuttingRadius
from constants import backPlateThickness, sizeZ, _zLeadScrewDiameter, _zRodDiameter, _zRodSeparation, _zRodOffsetY
from constants import M3_clearance_radius


def topFace(
    self: T,
    sizeX: float,
    sizeY: float,
    sizeZ: float,
    dogboneTolerance: float = 0,
    cuttingRadius: float = 1.5,
    kerf: float = 0,
) -> T:

    sideHoles = [(x, y) for x in [5.25 - sizeX/2, sizeX/2 - 5.25] for y in [30 - sizeY/2, -backPlateThickness/2]]
    backHoles = [(x, sizeY/2 - 5.5) for x in [30 - sizeX/2, sizeX/2 - 30]]
    frontHoles = [(x, 8 - sizeY/2) for x in [15, -15]]
    idlerHoles = [(x, 8 - sizeY/2) for x in [25 - sizeX/2, sizeX/2 - 25]]
    motorHoles = [(x, sizeY/2 - 30 - backPlateThickness) for x in [5.5 - sizeX/2, sizeX/2 - 5.5]]
    railHoles = [(x, y - sizeY/2) for x in [18.5 - sizeX/2, sizeX/2 - 18.5] for y in range(24, 200, 40)]
    zRodHoles = [(x, sizeY/2 - _zRodOffsetY - backPlateThickness) for x in [-_zRodSeparation/2, _zRodSeparation/2]]

    result = (
        self
        .rect(sizeX, sizeY)
        .pushPoints(sideHoles)
        .circle(M3_clearance_radius - kerf/2)
        .pushPoints(railHoles)
        .circle(M3_clearance_radius - kerf/2)
        .pushPoints(frontHoles)
        .circle(M3_clearance_radius - kerf/2)
        .pushPoints(idlerHoles)
        .circle(M3_clearance_radius - kerf/2)
        .pushPoints(backHoles)
        .circle(M3_clearance_radius - kerf/2)
        .pushPoints(motorHoles)
        .circle(M3_clearance_radius - kerf/2)
        .moveTo(0, sizeY/2 - 7)
        .circle(M3_clearance_radius - kerf/2)
        .moveTo(0, sizeY/2 - _zRodOffsetY - backPlateThickness)
        .circle(_zLeadScrewDiameter/2 + 1 - kerf/2)
        .pushPoints(zRodHoles)
        .circle(_zRodDiameter/2 + 0.5 - kerf/2)
    )

    result = result.extrude(sizeZ)

    result = (
        result
        .moveTo(0, -14)
        .sketch().rect(sizeX - 56, sizeY - 55)
        .vertices()
        .fillet(4)
        .finalize()
        .cutThruAll()
    )

    result = result.moveTo(65, sizeY/2 - 41.5).wiringCutout().cutThruAll()

    leftDogbones = [(-sizeX/2, i - sizeY/2) for i in range(50, 190, 40)]
    rightDogbones = [(sizeX/2, i - sizeY/2) for i in range(50, 190, 40)]
    frontDogbones = [(i - sizeX/2, -sizeY/2) for i in range(10, sizeY, 40)]
    backDogbones = [(i - sizeX/2, sizeY/2) for i in range(10, sizeY, 40)]
    cornerDogbones = [(x, y) for x in [-sizeX/2, sizeX/2] for y in [-sizeY/2, sizeY/2 - backPlateThickness]]

    result = (
        result
        .pushPoints(rightDogbones)
        .dogboneT(20, 6, cuttingRadius, 90, dogboneTolerance).cutThruAll()
        .pushPoints(leftDogbones)
        .dogboneT(20, 6, cuttingRadius, 90, dogboneTolerance).cutThruAll()
        .pushPoints(frontDogbones)
        .dogboneT(20, 6, cuttingRadius, 0, dogboneTolerance).cutThruAll()
        .pushPoints(backDogbones)
        .dogboneT(20, 6, cuttingRadius, 0, dogboneTolerance).cutThruAll()
        .pushPoints(cornerDogbones)
        .dogboneT(40, 6, cuttingRadius, 90, dogboneTolerance).cutThruAll()
    )

    return result


dxf = (cq.importers.importDXF("../BC220CF/dxfs/Top_Face_x220_y220.dxf").wires().toPending().extrude(sizeZ))

topFaceCNC = topFace(cq.Workplane("XY"), sizeX=220, sizeY=220 + backPlateThickness, sizeZ=3, dogboneTolerance=fittingTolerance, cuttingRadius=cncCuttingRadius, kerf=cncKerf)
#topFaceLSR = topFace(cq.Workplane("XY"), sizeX=220, sizeY=220 + backPlateThickness, sizeZ=3, dogboneTolerance=fittingTolerance, cuttingRadius=lsrCuttingRadius, kerf=lsrKerf)
#topFaceWJ  = topFace(cq.Workplane("XY"), sizeX=220, sizeY=220 + backPlateThickness, sizeZ=3, dogboneTolerance=fittingTolerance, cuttingRadius=wjCuttingRadius, kerf=wjKerf)

#show_object(topFaceCNC)
#show_object(topFaceLSR)
#show_object(dxf)

if 'topFaceCNC' in globals():
    exports(topFaceCNC, "Top_Face_x220_y220", "CNC")
if 'topFaceLSR' in globals():
    exports(topFaceLSR, "Top_Face_x220_y220", "LSR")
if 'topFaceWJ' in globals():
    exports(topFaceWJ, "Top_Face_x220_y220", "WJ")
