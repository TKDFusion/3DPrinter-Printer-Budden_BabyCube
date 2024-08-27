import cadquery as cq
from typing import (TypeVar)
T = TypeVar("T", bound="Workplane")

from dogbone import dogbone


def dogboneT(
    self: T,
    sizeX: float,
    sizeY: float,
    radius: float = 0,
    angle: float = 0,
    tolerance: float = 0,
    kerf: float = 0,
) -> T:
    return dogbone(self, sizeX + tolerance - kerf, sizeY - kerf, radius, angle)

cq.Workplane.dogboneT = dogboneT