%% Example script to transform skeletons or xyz points (in a matfile) of
%   flywire neurons from IBNWM to IVIA.

%% 1) brain surfaces for reference
transformDir = '.\demodata\IBNWB_IVIA\';
load([transformDir, 'atlas_surf.mat'], 'nsybIVAi')
load([transformDir, 'atlas_surf.mat'], 'IBNWB')
nsybIVAi = flip_surf_format(nsybIVAi.brain.surf);
IBNWB = flip_surf_format(IBNWB.brain.surf);

%% 2) in matlab transform skeletons from IBNWB to IVIA

% 2.1) define directories
oDir = '.\demodata\IVIA\';
iDir = '.\demodata\IBNWB\';
redo = 1;

% 2.2) test if you can properly read all skeletons
tobj = traceObj;
loadtrees(tobj, iDir, [], [], [], 1);

% 2.3) test if you can resample
resolution_ = 1; % um (microns)
resampletree(tobj, resolution_)

% 2.4) display skeleton with reference brain surface
% plot IBNWB surface and aIPg skeleton
figH = figure('position', [200 200 900 900]); 
axH = subplot(1, 1, 1);

% plot IBNWB surface
surfHandle = vizsurf(IBNWB.node, IBNWB.elem, 0.1, 0);
surfHandle.FaceColor = 'flat';
set(figH, 'color', 'w');
hold(axH, 'on')

% plot aIPg skeleton
refIm_res = [0.64 0.64 1.41]; % um
skt_IBNWB = traceObj;
loadtrees(skt_IBNWB, iDir, [], {'720575940627354562'})
xyzmatrix(skt_IBNWB, []);
pruneNaNs(skt_IBNWB);
smoothtree(skt_IBNWB, 5);
xyz_um2pix(skt_IBNWB, 1, refIm_res)

colorvect = rgb('cyan');
plottree_3D(skt_IBNWB, [], axH, 1, 0, colorvect, '-');

view([45 34]);
camlight(180, 90);
lighting gouraud

% 3) transform skeleton from IBNWB to IVIA (save in IVIA folder)
tobj = traceObj;
atlas2tlas_xform_perfile(tobj, {'720575940627354562.swc'}, ...
    'IBNWB', 'nsybIVAi', transformDir, iDir, oDir, [], redo)

% 4) load transformed skeletons and plot with reference brain surface
refIm_res = [0.75 0.75 1]; % um
tobj_IVIA = traceObj;
loadtrees(tobj_IVIA, oDir, [], [], [], 1);
xyzmatrix(tobj_IVIA, []);
pruneNaNs(tobj_IVIA);
smoothtree(tobj_IVIA, 5);
xyz_um2pix(tobj_IVIA, 1, refIm_res)

% 4.2) plot IBNWB surface and skeleton
figH = figure('position', [200 200 900 900]); 
axH = subplot(1, 1, 1);

surfHandle = vizsurf(nsybIVAi.node, nsybIVAi.elem, 0.1, 0);
surfHandle.FaceColor = 'flat';
set(figH, 'color', 'w');
hold(axH, 'on')

colorvect = rgb('cyan');
plottree_3D(tobj_IVIA, [], axH, 1, 0, colorvect, '-');

view([45 34]);
camlight(180, 90);
lighting gouraud

%% 3) in matlab transform matrices/points from IBNWB to IVIA

% 2.1) define directories
transformDir = '.\demodata\IBNWB_IVIA\';
oDir = '.\demodata\IVIA\';
iDir = '.\demodata\IBNWB\';
redo = 1;

xyz_IBNWB = load([iDir, 'xyz_IBNW', '.mat']);
xyz_IBNWB = xyz_IBNWB.xyz;
xyz = register_xyz_points(xyz_IBNWB, 'IBNWB', 'nsybIVAi', transformDir);
save([oDir, 'xyz_IVIA'], 'xyz')

% plot first xyz point from transformed matrix in both reference brains (and overlay skeletons for reference)
figH = figure('position', [200 200 900 900]); 
axH = subplot(1, 2, 1);

surfHandle = vizsurf(nsybIVAi.node, nsybIVAi.elem, 0.1, 0);
surfHandle.FaceColor = 'flat';
set(figH, 'color', 'w');
hold(axH, 'on')

plot3(xyz(1, 1), xyz(1, 2), xyz(1, 3), ....
        'Color', 'red', 'Marker', 'o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', [1 1 1], ...
        'MarkerFaceColor',  'red', 'Parent', axH);
colorvect = rgb('cyan');
plottree_3D(tobj_IVIA, [], axH, 1, 0, colorvect, '-');

axH = subplot(1, 2, 2);
surfHandle = vizsurf(IBNWB.node, IBNWB.elem, 0.1, 0);
surfHandle.FaceColor = 'flat';
set(figH, 'color', 'w');
hold(axH, 'on')

plot3(xyz_IBNWB(1, 1), xyz_IBNWB(1, 2), xyz_IBNWB(1, 3), ....
        'Color', 'red', 'Marker', 'o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', [1 1 1], ...
        'MarkerFaceColor',  'red', 'Parent', axH);
colorvect = rgb('cyan');
plottree_3D(skt_IBNWB, [], axH, 1, 0, colorvect, '-');
