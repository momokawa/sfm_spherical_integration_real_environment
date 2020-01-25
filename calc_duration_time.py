import os
from timeit import default_timer as timer
import numpy as np
start = timer()

# OpenMVG
os.system("./sfm_openmvg.sh")
os.system("./openmvg_bin2json.sh")
sfm_duration = timer() - start
print("sfm duration:", sfm_duration)
np.savetxt("./csv/sfm_duration.txt", (sfm_duration, sfm_duration))