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


home_dir= "/home/momoko/Documents/research_programs/20191224_experiment/"

spherical_cross_sections_dir = home_dir + "csv/spherical_cross_sections/"
openmvg_resonst_dir = home_dir + "openMVG_output/reconstruct/"
integrated_cross_sections_dir = home_dir + "csv/integrated_cross_sections/"

print("Generating directories....")
directories = {'home_dir': home_dir,
'spherical_cross_sections_dir': spherical_cross_sections_dir,
'openmvg_reconst_dir': openmvg_resonst_dir,
'integrated_cross_sections_dir': integrated_cross_sections_dir}
my_json = json.dumps(directories)
f = open("./mat/directories.json","w")
f.write(my_json)
f.close()

home_dir = directories['home_dir']
integrated_cross_sections_dir = directories['integrated_cross_sections_dir']
spherical_cross_sections_dir = directories['spherical_cross_sections_dir']

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

def gen_new_pointcloud(scale,ls_pcd):
    # generate new sfm point cloud with scale
    # ls_pcd: ligit section method point cloud
    print("Generating new point cloud and mesh with scale: " + str(scale))
    # sfm_mesh_new = change_scale_mesh(sfm_mesh, scale)
    ls_pcd_new = change_scale_lightsection(ls_pcd, scale)
    print("Done")
    return ls_pcd_new

def calc_D_mesh2cpoints(invA, A, c_points, n_M, n_c):
    # D = summed d_j
    # A = [a, b, c] three corners of the triangle
    Ds = cp.zeros(n_M)
    cnt = 0
    rs_init = c_points.T
    rs = rs_init
    step = 100 # 全部のmeshを使う必要はない

    for j in range(0,n_M, step):
        coefficient = cp.matmul(invA[:,:,j], rs)
        triangle = A[:,:,j] # [a,b,c]
        pos = coefficient > 0
        crossing_index = cp.multiply(cp.multiply(pos[0,:],pos[1,:]),pos[2,:]) # 要素積
        a = cp.where(crossing_index==True) # メッシュ交差してるr_i判定 #このaが変なtypeで帰ってくるの.....だからbをいれる
        if np.size(a) == 0:
            continue # skip this mesh
        # print(j,"th")
        # cnt += 1
        b = a[0]
        index = b[0] # 採用したr_iのindex i 一番はやいindexのやつを使う
        coeffi = coefficient[:, index] # alpha, beta, gamma
        # Calcualte d_j
        d_j = calc_d(coeffi, triangle)
        # Dに足す
        Ds[j] = d_j
        cnt += 1
        del coefficient, triangle, pos, crossing_index, a, index, d_j
    D = cp.sum(Ds)
    return D,  cnt

def calc_A(mesh_points, mesh_index_triangle_vertices, n_M):
    A = cp.zeros((3,3,n_M))
    invA = cp.zeros((3,3,n_M))

    for i in range(n_M):
        index = mesh_index_triangle_vertices[i,:]
        triangle = mesh_points[index,:]
        A[:,:,i] = triangle.T
        invA[:,:,i] = cp.linalg.inv(triangle.T)

    return A, invA

def calc_d(coeffi, triangle):
    # Caculate norm(d)^2
    a = coeffi[0]*triangle[:,0] + coeffi[1]*triangle[:,1] + coeffi[2]*triangle[:,2]
    b = cp.sqrt(cp.square(coeffi[0])+cp.square(coeffi[1])+cp.square(coeffi[2]))
    inside =  a - ( a / b )
    d_square = cp.square(cp.linalg.norm(inside))
    return d_square

def loop(mesh, ls_pcd):
    min_scale = 10
    max_scale = 1000
    interval = -10
    best_scale = min_scale
    av_sum_dist = np.Inf
    scales = np.arange(max_scale, min_scale + interval, interval)
    mesh_index_triangle_vertices = cp.asarray(mesh.triangles)
    mesh_points_init = cp.asarray(mesh.vertices)
    n_M = mesh_index_triangle_vertices.shape[0] # number of mesh triangle
    n_c = ls_pcd.n_all_p # number of points of cross sections
    print("n_M: ", n_M, "\n")
    print("n_c: ", n_c, "\n")
    (A, invA) = calc_A(mesh_points_init, mesh_index_triangle_vertices, n_M)

    print(scales)
    for current_scale in scales:
        print("========= Current scale: " + str(current_scale), "=========")
        current_ls_pcd = gen_new_pointcloud(current_scale, ls_pcd)
        c_points = cp.asarray(current_ls_pcd.integrated_points) # cross sections points
        # (current_sum_dist, cnt) = dist_triangle2pcd(current_sfm_mesh, current_ls_pcd)
        (D_current, cnt) = calc_D_mesh2cpoints(invA/current_scale, current_scale*A, c_points, n_M, n_c)
        av_current_sum_dist = D_current / cnt
        print("Current sum_dist: ", D_current, " Current cnt: ", cnt, " Current av_sum_dist:", av_current_sum_dist)
        if av_current_sum_dist < av_sum_dist:
            av_sum_dist = av_current_sum_dist
            best_scale = current_scale
            save_as_csv(current_ls_pcd.integrated_points, "./csv/integrated_cross_sections/all_integrated_best_scale")
            print("Update best scale!: " ,best_scale, " sum_dist:" , D_current ,  " cnt: " , cnt, "av_sum_dist: ", av_sum_dist)


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
    duration = timer()-start
    print("============== FINAL RESULT ==================")
    print("Best scale is: ", best_scale, " av_sum_dist: ", av_sum_dist)
    print("Calculation time:", duration)
    save_as_csv([duration, best_scale], "./csv/duration_and_best_scale")

if __name__ == "__main__":
    main()