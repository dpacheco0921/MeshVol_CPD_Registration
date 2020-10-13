%% demo
%% 1) add paths
% it assumes you have already add the repository folders to your path
addpath(genpath(pwd))

% add paths of all dependencies
% iso2mesh

%% 2) Move to folder and Download demo data
tDir = strrep(which('MeshVol_CPD_registration_demo'), 'MeshVol_CPD_registration_demo.m', '');
cd(tDir)

url = 'https://www.dropbox.com/s/8imtwt2i7a4er7b/IBNWB_IVIA.zip?dl=1';
filename = 'IBNWB_IVIA.zip';

if ~exist('./demodata/IBNWB_IVIA', 'dir')
    mkdir('./demodata/IBNWB_IVIA')
end
cd('./demodata/IBNWB_IVIA')

outfilename = websave(filename, url);
unzip(outfilename);

clear url outfilename

% structure of varaibles within '.mat' files
% 'IBNWB.mat' & 'nsybIVAi.mat' contains 3D binary images or many regions of
%   interest (ROIs, such as bmask_cbrain, etc).

%% 3) Generate meshes from binary images (BW images)

% load *mat files, get paths
datadir = [tDir, filesep, 'demodata', filesep, 'IBNWB_IVIA'];

% IBNWB: optic lobe is complete
IBNWB_Path = ff(datadir, 'IBNWB_binary.mat');

% nsybIVAi: optic lobe is clipped
IVA_Path = ff(datadir, 'nsybIVAi_binary.mat');

% params
isoval = 0.9; % isovalue for surface meshing from binary volume
reduce_factor = 0.1; % factor to reduce surface size by

% select binary images to convert to mesh
rois = {'bmask_AL', 'bmask_AMMCC_L', 'bmask_AMMCC_R', 'bmask_AOT_L', 'bmask_AOT_R', ...
    'bmask_GC', 'bmask_IVLPC', 'bmask_MB_L', 'bmask_MB_R', 'bmask_POC', ...
    'bmask_PB', 'bmask_iALT_L', 'bmask_iALT_R', 'bmask_pCCF_L', ...
    'bmask_pCCF_R', 'bmask_sSADc', 'bmask_cbrain', 'bmask_opticlobes_R', 'bmask_opticlobes_L'};

% IBNWB
t0 = stic;
S1 = mesh_matfiles(IBNWB_Path, isoval, reduce_factor, rois);
save(ff('data', strrep(get_filename(IBNWB_Path)), '_binary', ''), '-struct', 'S1')
stocf(t0, 'Meshed %s', get_filename(IBNWB_Path))

% nsybIVAi
t0 = stic;
S2 = mesh_matfiles(IVA_Path, isoval, reduce_factor, rois);
save(ff('data', strrep(get_filename(IVA_Path)), '_binary', ''), '-struct', 'S2')
stocf(t0, 'Meshed %s', get_filename(IVA_Path))

%% 4) load meshes, and define ROIs to use per data

% load both .mat and .nrrd files
datadir = [tDir, filesep, 'demodata', filesep, 'IBNWB_IVIA'];

S_IBNWB = matfile([datadir, filesep, 'IBNWB.mat']);
[im, meta] = nrrdread([datadir, filesep, 'IBNWB.nrrd']);
siz_IBNWB = size(im);
res_IBNWB = nrrdread_res(meta);

S_IVA = matfile([datadir, filesep, 'nsybIVAi.mat']);
[im, meta] = nrrdread([datadir, filesep, 'nsybIVAi.nrrd']);
siz_IVA = size(im);
res_IVA = nrrdread_res(meta);

% define ROIs to use:
%   bmask_wbrain (whole)
%   bmask_cbrain (central)
%   bmask_opticlobes
%   bmask_AL, etc

use_rois = {'bmask_AL', 'bmask_AMMCC_L', 'bmask_AMMCC_R', 'bmask_AOT_L', 'bmask_AOT_R', ...
    'bmask_GC', 'bmask_IVLPC', 'bmask_MB_L', 'bmask_MB_R', 'bmask_POC', ...
    'bmask_PB', 'bmask_iALT_L', 'bmask_iALT_R', 'bmask_pCCF_L', ...
    'bmask_pCCF_R', 'bmask_sSADc', 'bmask_cbrain', 'bmask_opticlobes_R', 'bmask_opticlobes_L'};

%% 5) Edit meshes to be used for registration and for testing (with optic lobes)
% load meshes 
stic;
mesh_IBNWB = cf(@(x)S_IBNWB.(x), use_rois);
mesh_IVA = cf(@(x)S_IVA.(x), use_rois);
stocf('Loaded')

% from pixel to microns
stic;
mesh_IBNWB = mesh_rescale(mesh_IBNWB, res_IBNWB);
mesh_IVA = mesh_rescale(mesh_IVA, res_IVA);
stocf('Scaled')

% visualize meshes: vizsurfn(mesh_IBNWB{:})

% count nodes per mesh and downsample
%[cf(@(x) size(x.node, 1), mesh_IBNWB)' cf(@(x) x.type, mesh_IBNWB)']
%[cf(@(x) size(x.node, 1), mesh_IVA)' cf(@(x) x.type, mesh_IVA)']

% smooth meshes
mesh_IBNWB = mesh_smooth(mesh_IBNWB, [], [], 20);
mesh_IVA = mesh_smooth(mesh_IVA, [], [], 20);

% resample to homogenize node # (to be equal across brains and meshes)
% group one

stic;
idx = 17;
mesh_IBNWB_rs(idx) = mesh_resample_rel2ref(mesh_IBNWB(idx), 3, 3000);
mesh_IVA_rs(idx) = mesh_resample_rel2ref(mesh_IVA(idx), 3, 3000);
clear X

stocf('Resampled')

% group three
stic;
idx = [1 4 5 6 8 9 10 11 16 14 15];
mesh_IBNWB_rs(idx) = mesh_resample_rel2ref(mesh_IBNWB(idx), 3, 1000);
mesh_IVA_rs(idx) = mesh_resample_rel2ref(mesh_IVA(idx), 3, 1000);
stocf('Resampled')

% group four
stic;
idx = [2 3 7 12 13 18 19];
mesh_IBNWB_rs(idx) = mesh_resample_rel2ref(mesh_IBNWB(idx), 3, 500);
mesh_IVA_rs(idx) = mesh_resample_rel2ref(mesh_IVA(idx), 3, 500);
stocf('Resampled')

% smooth
mesh_IBNWB_rs = mesh_smooth(mesh_IBNWB_rs, [], [], 20);
mesh_IVA_rs = mesh_smooth(mesh_IVA_rs, [], [], 20);

% count nodes per mesh and downsample
%[cf(@(x) size(x.node, 1), mesh_IBNWB_rs)' cf(@(x) x.type, mesh_IBNWB_rs)']
%[cf(@(x) size(x.node, 1), mesh_IVA_rs)' cf(@(x) x.type, mesh_IVA_rs)']

% fix meshes
mesh_IBNWB_rs = mesh_checkrepair_all(mesh_IBNWB_rs, [1 1 1 1 0]);
mesh_IVA_rs = mesh_checkrepair_all(mesh_IVA_rs, [1 1 1 1 0]);

% count nodes per mesh and downsample
%[cf(@(x) size(x.node, 1), mesh_IBNWB_rs)' cf(@(x) x.type, mesh_IBNWB_rs)']
%[cf(@(x) size(x.node, 1), mesh_IVA_rs)' cf(@(x) x.type, mesh_IVA_rs)']

%% 6) generate variables to be used for registration
% merge all rois for registration
stic;
mesh_IBNWB = mesh_merge(mesh_IBNWB_rs);
mesh_IVA = mesh_merge(mesh_IVA_rs);
stocf('Merged')

% merge internal rois for plotting match
stic;
test_rois = {'bmask_AL', 'bmask_AMMCC_L', 'bmask_AMMCC_R', 'bmask_AOT_L', 'bmask_AOT_R', ...
    'bmask_GC', 'bmask_IVLPC', 'bmask_MB_L', 'bmask_MB_R', 'bmask_POC', ...
    'bmask_PB', 'bmask_iALT_L', 'bmask_iALT_R', 'bmask_pCCF_L', ...
    'bmask_pCCF_R', 'bmask_sSADc'};

mesh_IBNWB_roi = mesh_merge(mesh_IBNWB_rs(1:16));
mesh_IVA_roi = mesh_merge(mesh_IVA_rs(1:16));
stocf('Merged')

% save all variables used for registration
save([datadir, filesep, 'prepro_meshes_woOL_s.mat'], ...
    'test_rois', 'use_rois', ...
    'mesh_IBNWB_roi', 'mesh_IVA_roi', ...               % for plotting
    'mesh_IBNWB', 'mesh_IVA', ...                       % for registration
    'mesh_IBNWB_rs', 'mesh_IVA_rs', ...                 % for accuracy estimation
    'res_IBNWB', 'res_IVA', 'siz_IBNWB', 'siz_IVA')     % general scaling

%% 7) register meshes
load([datadir, filesep, 'prepro_meshes_woOL_s.mat'])

resample_factor = 1;     % Factor to downsample registration meshes by.
                         % smaller values = faster and typically easier to
                         % register well, but may lose details

iparams_1to2.beta = 5;
iparams_1to2.lambda = 1;
iparams_1to2.outliers = 0.2;
                         
t0 = stic;
reg_1to2 = register_meshes(mesh_IVA, mesh_IBNWB, resample_factor, iparams_1to2);
stocf(t0, 'Finished registration 1 -> 2 || IBNWB to nsybIVAi');

iparams_2to1.beta = 5;
iparams_2to1.lambda = 0.1;
iparams_2to1.outliers = 0.2;

t0 = stic;
reg_2to1 = register_meshes(mesh_IBNWB, mesh_IVA, resample_factor, iparams_2to1);
stocf(t0, 'Finished registration 2 -> 1 || nsybIVAi to IBNWB');

% save registrations
reg_struct.im_name = {'IBNWB', 'nsybIVAi'};
reg_struct.reg_1to2 = reg_1to2;
reg_struct.resample_factor = resample_factor;
reg_struct.use_rois = use_rois;
reg_struct.test_rois = test_rois;
reg_struct.mesh_1 = mesh_IBNWB;
reg_struct.res1 = res_IBNWB;
reg_struct.vol1_sz = siz_IBNWB;
reg_struct.mesh_1_roi = mesh_IBNWB_roi;         % rois to test intersecction
reg_struct.mesh_2 = mesh_IVA;
reg_struct.mesh_2_roi = mesh_IVA_roi;           % rois to test intersecction
reg_struct.res2 = res_IVA;
reg_struct.vol2_sz = siz_IVA;
reg_struct.beta = iparams_1to2.beta;
reg_struct.lambda = iparams_1to2.lambda;
reg_struct.outliers = iparams_1to2.outliers;
reg_struct.resamplefactor = resample_factor;

filename = 'reg_1to2_lambda_1_beta_5_outliers_02_smp_1'; 
save([datadir, filesep, filename, '.mat'], 'reg_struct')

reg_struct.reg_2to1 = reg_2to1;
reg_struct.beta = iparams_1to2.beta;
reg_struct.lambda = iparams_1to2.lambda;
reg_struct.outliers = iparams_1to2.outliers;

filename = 'reg_2to1_lambda_01_beta_5_outliers_02_smp_1'; 
save([datadir, filesep, filename, '.mat'], 'reg_struct')

% Notes:
%   for exploring registration parameters see: batch_register_meshes

%% 8) reformat meshes/points or volumes

filename = 'reg_1to2_lambda_1_beta_5_outliers_02_smp_1'; 
load([datadir, filesep, filename, '.mat'], 'reg_struct')

% 1) reformat central brain surface to IVA
mesh_IBNWBtoIVA = apply_tform(mesh_IBNWB, reg_1to2);

% plot surfaces
figure();
vizsurfn(mesh_IVA, mesh_IBNWBtoIVA)

% 2) reformat rois surfaces to IVA
mesh_roi_IBNWBtoIVA = apply_tform(mesh_IBNWB_roi, reg_1to2);

% plot surfaces
figure();
vizsurfn(mesh_IVA_roi, mesh_roi_IBNWBtoIVA)

%% 9) reformat intensity images
% 1to2: IBNWB->IVA
% Note: to reformat intensity images, you need the opposite transformation

% 1) generate dform for this registration (this overwrite already saved files)
path_reg = [datadir, filesep, 'reg_1to2_lambda_1_beta_5_outliers_02_smp_1.mat'];
dform_1to2 = generate_dform(path_reg);
save(strrep(path_reg, '.mat', '_dform.mat'), 'deformation_struct', '-v7.3')

path_reg = [datadir, filesep, 'reg_2to1_lambda_01_beta_5_outliers_02_smp_1.mat'];
dform_2to1 = generate_dform(path_reg);
save(strrep(path_reg, '.mat', '_dform.mat'), 'deformation_struct', '-v7.3')

% 2)load dform and reformat volumes
load([datadir, filesep, 'reg_1to2_lambda_1_beta_5_outliers_02_smp_1_dform'])

% 3) transform image
[IVAim, ~] = nrrdread([datadir, filesep, 'nsybIVAi.nrrd']);
IVAim_IBNWB = apply_dform(IVAim, dform_1to2, '2to1', 'cubic');
