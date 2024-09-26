# Registration of meshes/volumes using CoherentPointDrift-MATLAB

Matlab functions to register meshes and volumes using [Andriy Myronenko](https://sites.google.com/site/myronenko/) [Coherent Point Drift library](https://sites.google.com/site/myronenko/research/cpd) for nonrigid registration.

# Usage

See examples in MeshVol_CPD_registration_demo.m on how to go from binary volumes to meshes, edit meshes, and register meshes.

# Dependencies

This code requires additional repositories for mesh processing and visualization:
- [iso2mesh](https://github.com/fangq/iso2mesh)

To run batch functions in server:
- [pu_cluster_interface](https://github.com/dpacheco0921/pu_cluster_interface)

To overlay videos using FIJI:
- [StackViewer](https://github.com/dpacheco0921/StackViewer)

To run do demo of transforming skeletons or matrices from FAFB14 to IVIA:
- [FlyCaImAn](https://github.com/dpacheco0921/FlyCaImAn)
- See demo_transform_skts_or_xyz_from_fafb14_to_IBWB.R script to transform skeletons/xyz matrices from FAFB14 to IBNWB atlas.
- See demo_transform_skt_or_xyz_from_IBNWB_to_IVIA.m script to transform skeletons/xyz matrices from IBNWB to IVIA atlas.

# Citation

If you use this code please cite the following corresponding paper:
[Myronenko A., Song X. (2010): "Point-Set Registration: Coherent Point Drift", IEEE Trans. on Pattern Analysis and Machine Intelligence, vol. 32, issue 12, pp. 2262-2275](https://arxiv.org/abs/0905.2635)
