# Script to download, skeletonize, register (to IBNWB), and save xyz points (in a matfile) of flywire neurons

###########################################
# 1) move to working directory
###########################################

# set working directory to the location of this R function.
# then create 'targetdir' variable
targetdir <- getwd()

###############################################
# 2) load flywire neurons and generate skeleton
###############################################

library(natverse)
library(fafbseg)
library(R.matlab)

# 1) download example flywire neuron
neuron2download <- flywire_latestid("720575940627354562")
choose_segmentation('flywire31')

# download mesh and generate skeleton
skt_FAFB14 <- read_l2skel(neuron2download)

# plot skeleton
open3d(windowRect = c(20, 30, 800, 800))
plot3d(FAFB14, alpha=0.1)
plot3d(skt_FAFB14, col='blue', add = T)

###########################################
# 2) move skeleton from FAFB14 to IBNWB
###########################################

# transform full skeleton
skt_IBNWB <- xform_brain(skt_FAFB14, sample = FAFB14, reference = IBNWB)

# transform matrix of XYZ points
# get xyz matrix
xyz_FAFB14 = xyzmatrix(skt_FAFB14)
# get transformation sequence
reg <- shortest_bridging_seq(sample = FAFB14, reference = IBNWB)
# apply transformation
xyz_IBNW <- xformpoints(reg, xyz_FAFB14, FallBackToAffine = TRUE, na.action = "error")

# save matrix as a matfile
writeMat('demodata/IBNWB/xyz_IBNW.mat', xyz=xyz_IBNW)

# save skeleton as SWC
write.neurons(skt_IBNWB, dir="demodata/IBNWB", format="swc", Force=T)
