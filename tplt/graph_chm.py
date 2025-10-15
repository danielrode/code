#!/usr/bin/env python3
# Author: Daniel Rode
# Created: 01 Oct 2025
# Updated: -


# Take a list of points and scales and graph them, then save figures.


from pathlib import Path

import rasterio as rio
import matplotlib.pyplot as plt
from shapely import Point
from geopandas import GeoDataFrame
from rasterio.mask import mask as rio_mask
from rasterio.plot import show as rio_show
from matplotlib_scalebar.scalebar import ScaleBar
from matplotlib_scalebar.dimension import _Dimension
from matplotlib.colors import LinearSegmentedColormap


# Constants
ZISSOU1 = [
    # https://github.com/karthik/wesanderson/blob/master/R/colors.R
    "#3B9AB2", "#78B7C5", "#EBCC2A", "#E1AF00", "#F21A00",
]
ZISSOU1_CMAP = LinearSegmentedColormap.from_list("", ZISSOU1)

FIG_DPI = 600
FIG_CMAP = 'rainbow'
FIG_CMAP = ZISSOU1_CMAP

DST_DIR = Path("./")
CHM_PATH = Path("GEO_TIFF_RAST_PATH.tif")

POIS_CRS = "EPSG:6342"
CHM_POIS = (
    # X, Y, Scale
    (688681, 542811, 100),
    (694981, 393510, 100),
    (961729, 589382,  50),
)


# Classes
class ImperialLengthDimensionCommon(_Dimension):
    def __init__(self):
        super().__init__("ft")
        self.add_units("in", 1 / 12)
        self.add_units("mi", 5280)


# Functions
def grow_gdf(gdf, buff):
    return GeoDataFrame(
        geometry=gdf.buffer(
            buff,
            cap_style='square',
            join_style='mitre',
        ),
        crs=gdf.crs,
    )

    
def graph_chm_poi(chm_box, dst_path):
    fig, ax = plt.subplots(layout="compressed")

    with rio.open(CHM_PATH, 'r') as f:
        shapes = chm_box.to_crs(f.crs.wkt)["geometry"]
        rast, affine = rio_mask(f, shapes, crop=True)

    ax = rio_show(rast, transform=affine, ax=ax, cmap=FIG_CMAP)

    ax.figure.colorbar(
        ax.get_images()[0],
        ax=ax,
        orientation='vertical',
        shrink=0.5,
        pad=0.02,
    )

    ax.xaxis.set_visible(False)
    ax.yaxis.set_visible(False)
    scalebar = ScaleBar(
        dx=1, # Size of one pixel in units specified by `units`
        units="m",  # Units of dx
        dimension="si-length",  # Dimension of dx and units
        # units="ft",  # Units of dx
        # dimension=ImperialLengthDimensionCommon(),
        location="lower left",
    )
    ax.add_artist(scalebar)

    fig.savefig(dst_path, dpi=FIG_DPI, bbox_inches='tight')


# Main
for x, y, scale in CHM_POIS:
    for scale in (scale, scale / 2, scale * 2):
        view_bounds = GeoDataFrame(
            geometry=[Point([x, y])],
            crs=POIS_CRS,
        )
        view_bounds['geometry'] = view_bounds.buffer(
            scale,
            cap_style='square',
            join_style='mitre',
        )

        dst_path = DST_DIR / f"export_{x}_{y}_{scale}".replace(".", "_")
        graph_chm_poi(view_bounds, dst_path)
