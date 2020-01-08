#!/usr/bin/python
import numpy as np
import pdb
def spherical2openmvg(spherical_points):
    x =  -1*spherical_points[:,0] # ok
    y =  -1*spherical_points[:,2] # ok
    z =  spherical_points[:,1]

    openmvg_p = np.stack([x,y,z],axis=1)
    return openmvg_p