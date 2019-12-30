#!/usr/bin/python
import open3d as o3d
import pdb
import numpy as np
import copy
import glob
from scipy.io import loadmat
from scipy.spatial import ConvexHull
import cupy as cp
from convert_coordinate_spherical2openMVG import spherical2openmvg
import json
from scipy.spatial import Delaunay
from timeit import default_timer as timer
# from numba import jit, cuda, f8

with open("./mat/directories.json", "r") as read_file:
    data = json.load(read_file)

home_dir = data['home_dir']
integrated_cross_sections_dir = data['integrated_cross_sections_dir']
spherical_cross_sections_dir = data['spherical_cross_sections_dir']
openmvg_cross_sections_dir = data['openmvg_cross_sections_dir']
openmvg_resonst_dir = data['openmvg_reconst_dir']
# This programs for finding the real scale by comparing 2 point cloud

def save_as_csv(data,prefix):
    filename= prefix +".csv"
    np.savetxt(filename, data, delimiter=",")

class lightsectionPointClass():
    def __init__(self, cross_sections, T, num_frame):
        self.num_frame = num_frame
        self.cross_sections = cross_sections # openMVG coordinate
        self.T = T # 4 x 4
        self.T_current = T # with current scale
        self.integrated_points = None
        self.count_num_points()
        self.current_scale = 1
        self.integrate_cross_sections()


    def change_scale(self, scale):
        T_new = copy.deepcopy(self.T)
        self.current_scale = scale
        for i in range(self.num_frame):
            trans_tmp = copy.deepcopy(T_new[1:3,3,i])
            trans = scale*trans_tmp
            T_new[1:3,3,i] = trans
        
        self.T_current = T_new
    
    def count_num_points(self):
        # Counts the number of points in the cross sections
        n_all_p = 0 # the number of all points in all cross sections
        for i in range(self.num_frame):
            n_tmp = self.cross_sections[i].shape[0]
            n_all_p += n_tmp
        
        self.n_all_p  = n_all_p

    def integrate_cross_sections(self):
        intgrt_p = np.zeros([self.n_all_p,3]) # integrated points
        cnt = 0
        for i in range(self.num_frame):
            n_tmp = self.cross_sections[i].shape[0] # the number of points in frame
            d3 = copy.deepcopy(self.cross_sections[i])
            n_p = d3.shape[0] # number of points
            d3_ = np.hstack([d3, np.ones([n_p,1])]) # homogenerous
            intgrt_p_tmp = np.matmul(self.T_current[:,:,i], d3_.T) # intgrt_d3 = d3 * (sfm_est_T(:,:,j))'; % (A*B)' = B' * A'; intgrd3 = T*d3' % all points from 1st view's coordinate
            save_as_csv(intgrt_p_tmp.T[:,0:3], integrated_cross_sections_dir + "cross_" + str(i).zfill(5)+"integrated")
            intgrt_p[cnt:(cnt+n_tmp),:] = intgrt_p_tmp.T[:,0:3]
            cnt += n_tmp
        self.integrated_points = intgrt_p
        save_as_csv(intgrt_p, integrated_cross_sections_dir + "all_integrated_" +str(self.current_scale))
        

def change_scale_lightsection(ls_pcd, scale):
    ls_pcd.change_scale(scale) # Update T_current
    ls_pcd.integrate_cross_sections() # Integrate cross sections in shperical with the scale movement
    return ls_pcd

def generate_lspcd():
    # Generate class of lightsection point cloud
    print("Generating point cloud from cross_sectional shapes in "+str(spherical_cross_sections_dir))
    cross_section_path = sorted(glob.glob(spherical_cross_sections_dir+"d3_*.csv"))
    cross_sections = []
    for i in range(len(cross_section_path)):
        data = np.loadtxt(cross_section_path[i],delimiter=",")
        cross_sections.append(data)
    
    print("Size of cross_sections:" + str(len(cross_sections)))

    # Load T.mat
    matname = "sfm_est_T_spherical"
    T_path = home_dir + "mat/" + matname + ".mat"
    print("Reading estimated T matrix from " + str(T_path))
   
    T_load = loadmat(T_path)
    T = T_load[matname]

    # num_frame
    num_frame = T.shape[2]

    # Generate obj
    print("Generating initial point cloud of cross-sections.... \n")
    ls_pcd = lightsectionPointClass(cross_sections, T, num_frame)
    print("Done \n\n")
    return ls_pcd

def change_scale_mesh(mesh, scale):
    # Change the scale of mesh points' location
    points = np.asarray(mesh.vertices)
    p_new = o3d.utility.Vector3dVector(scale*points)
    mesh_new = copy.deepcopy(mesh)
    mesh_new.vertices = p_new
    save_as_csv(p_new, home_dir + "csv/tmp/openMVG_points_scale"+str(scale))
    # o3d.visualization.draw_geometries([mesh_new])
    return mesh_new

def gen_new_pointcloud(scale, sfm_mesh, ls_pcd):
    # generate new sfm point cloud with scale
    # ls_pcd: ligit section method point cloud
    print("Generating new point cloud and mesh with scale: " + str(scale))
    sfm_mesh_new = change_scale_mesh(sfm_mesh, scale)
    ls_pcd_new = change_scale_lightsection(ls_pcd, scale)
    print("Done\n\n")
    return sfm_mesh_new, ls_pcd_new

#def is_inside_triangle_plane(t1, t2, t3, p):
#    # ti: the three triangle corners
#    # p: the point to be checked whether it is inside of triangle
#    c1 = np.cross((p-t1), (t2-t1))
#    c2 = np.cross((p-t2), (t3-t2))
#    c3 = np.cross((p-t3), (t1-t3))
#
#    if (np.dot(c1,c2)>0 and np.dot(c1,c3) >0 ):
#        is_inside = True
#    else:
#        is_inside = False
#    
#    return is_inside


def in_hull(p, hull):
    """
    Test if points in `p` are in `hull`

    `p` should be a `NxK` coordinates of `N` points in `K` dimensions
    `hull` is either a scipy.spatial.Delaunay object or the `MxK` array of the 
    coordinates of `M` points in `K`dimensions for which Delaunay triangulation
    will be computed
    """

    if not isinstance(hull,Delaunay):
        hull = Delaunay(hull)

    return hull.find_simplex(p)>=0

def get_scales_candi(numerator, points, normals):
    # Adopt points whose scales are potive
    # scales: the scale, for each light-section point ray, which crosses the triangle plane
    denom = cp.diag(cp.dot(normals, points))
    scales = numerator / denom
    positive_index = cp.asnumpy(cp.where(scales>0)[0])
    scales = cp.asnumpy(scales)
    return positive_index, scales


def define_triangle_region(tmp_vertices):
    bottom = 0.5
    top = 1.5
    hull_vertics = np.vstack((bottom*tmp_vertices[0,:], bottom*tmp_vertices[1,:], bottom*tmp_vertices[2,:], top*tmp_vertices[0,:], top*tmp_vertices[1,:], top*tmp_vertices[2,:]))
    return hull_vertics


def dist_triangle2pcd(mesh, pcd):
    print("Calclating distance from triangles to points...")
    # s = (n_j*n_j^T) / (n_j)*(r_i)^T
    # This function calculate distance from each point from pcd to the nearest triangle of mesh

    # Mesh info
    mesh.compute_triangle_normals() # Updte normal vector of mesh
    normals = cp.asarray(mesh.triangle_normals) # normal vectors of triangle plane
    points_mesh = np.asarray(mesh.vertices) # points location of mesh
    index_triangle_vertices = np.asarray(mesh.triangles) # the index of vertices of triangles in the mesh obj

    # Cross sections info
    points_pcd = pcd.integrated_points # point location of lightsection pcd
    n_triangle = normals.shape[0] # num of triangles in mesh
    n_pcd = points_pcd.shape[0] # num of point in lightsection pcd

    
    print("The num of lightsection points: " + str(n_pcd))
    print("The num of triangles: " + str(n_triangle))

    numerator = cp.diag(cp.dot(normals, normals.T))
    print("numerator shape: "+ str(numerator.shape))

    (sum_dist, cnt) = dist_triangle2pcd_(n_pcd, points_pcd, n_triangle, numerator, normals, index_triangle_vertices, points_mesh)

    return sum_dist, cnt

def dist_triangle2pcd_(n_pcd, points_pcd, n_triangle, numerator, normals, index_triangle_vertices, points_mesh):
    sum_dist = 0.0
    cnt = 0
    step = 500
    for i in range(0,n_pcd,step):
        # print(str(i)+"th lightsection point...")
        p = cp.tile(points_pcd[i,:], (n_triangle,1)).T # rshape (3,n_triangle)
        # n_j * r_i^T
        (positive_index, scales) = get_scales_candi(numerator, p, normals)
        for j in positive_index: # As for valid triangle plane

            tmp_index = index_triangle_vertices[j,:]

            # hull vertics
            tmp_vertices = points_mesh[tmp_index, :] # sfm points which consist the triangle 
            hull_vertics = define_triangle_region(tmp_vertices)
            
            tmp_scale = scales[j]
            tmp_p = tmp_scale*points_pcd[i,:]
            
            if in_hull(tmp_p, hull_vertics):
                # Return wheter the point is on and inside the triagle mesh
                length = cp.linalg.norm(cp.asarray(tmp_p))
                sum_dist += cp.abs(length * (tmp_scale - 1))
                cnt += 1
            
    print("The lightsection points which have crossing mesh triangle: " + str(cnt) + "\n")
    print("Out of  all lightsection points: " + str(n_pcd))
    print("The num of triangles: " + str(n_triangle))

    return sum_dist, cnt

def loop(mesh, ls_pcd):
    min_scale = 0.1
    max_scale = 0.4
    interval = -0.02
    best_scale = min_scale
    av_sum_dist = np.Inf
    scales = np.arange(max_scale, min_scale + interval, interval)
    print(scales)
    for current_scale in scales:
        print("========= \n Current scale: " + str(current_scale))
        (current_sfm_mesh, current_ls_pcd) = gen_new_pointcloud(current_scale, mesh, ls_pcd)
        (current_sum_dist, cnt) = dist_triangle2pcd(current_sfm_mesh, current_ls_pcd)
        av_current_sum_dist = current_sum_dist / cnt
        print("Current sum_dist: ", current_sum_dist, " Current cnt: ", cnt, " Current av_sum_dist:", av_current_sum_dist)

        if av_current_sum_dist < av_sum_dist:
            av_sum_dist = av_current_sum_dist
            best_scale = current_scale
            print("Update best scale!: " ,best_scale, "\nsum_dist:" ,current_sum_dist,  " cnt: " , cnt, "av_sum_dist: ", av_sum_dist,  "\n")


    return best_scale, av_sum_dist

def main():
    # in case of just point cloud
    # filename =  openMVG_output_dir + "/cloud_only.ply"
    # pcd = o3d.io.read_point_cloud(filename)
    # mesh = generate_mesh(pcd, 10)
    print("Start finding best scale....")
    sfm_filename =  home_dir + 'ply/' +"mesh_sfm_points_spherical_1stcam.ply" # mesh file given by CloudCompare
    mesh = o3d.io.read_triangle_mesh(sfm_filename)
    ls_pcd = generate_lspcd()

    start = timer()
    (best_scale, av_sum_dist) = loop(mesh, ls_pcd)
    print("Best scale is: ", best_scale, " av_sum_dist: ", av_sum_dist)
    print("Calculation time:", timer()-start)
    

if __name__ == "__main__":
    main()