function [figH, axH] = plot_mesh_overlap_regresults(...
    xform, float_mesh, ref_mesh, oDir, figname)
% plot_mesh_overlap_regresults: overlay ROIs to visualize registration
%   results
%
% Usage:
%   [figH, axH] = plot_mesh_overlap_regresults(...
%      xform, float_mesh, ref_mesh, oDir, figname)
%
% Args:
%   xform: a cell collection of structures containing
%       ridig (ICP) and CPD transformation.
%   float_mesh: cell of float meshes
%   ref_mesh: cell of ref meshes
%   oDir: target directory
%   figname: name of figure to save

if ~exist('float_mesh', 'var') || isempty(float_mesh)
    float_mesh = [];
end

if ~exist('ref_mesh', 'var') || isempty(ref_mesh)
    ref_mesh = [];
end

if ~exist('oDir', 'var') || isempty(oDir)
    oDir = '.';
end

if ~exist('figname', 'var') || isempty(figname)
    figname = [];
end

if ~iscell(ref_mesh)
    ref_mesh{1} = ref_mesh;
end

if ~iscell(float_mesh)
    float_mesh{1} = float_mesh;
end

if ~iscell(xform)
    xform{1} = xform;
end

row_n = numel(ref_mesh);
figH = figure('Position', [124 326 1122 361]); 

for i = 1:row_n
    
    mesh_float_ = float_mesh{i};
    mesh_float_ = apply_tform(mesh_float_, xform);

    axH(1 + 3*(i-1)) = subplot(row_n, 3, 1 + 3*(i-1));
    vizsurfn(ref_mesh{i}, mesh_float_); view([90 90]);
    axH(2 + 3*(i-1)) =subplot(row_n, 3, 2 + 3*(i-1));
    vizsurfn(ref_mesh{i}, mesh_float_); view([0 0]);
    axH(3 + 3*(i-1)) =subplot(row_n, 3, 3 + 3*(i-1));
    vizsurfn(ref_mesh{i}, mesh_float_); view([90 0]);

    XYZmin = min([ref_mesh{i}.node], [], 1);
    XYZmax = max([ref_mesh{i}.node], [], 1);

    axH(1 + 3*(i-1)).XLim = [XYZmin(1) XYZmax(1)];
    axH(1 + 3*(i-1)).YLim = [XYZmin(2) XYZmax(2)];
    axH(2 + 3*(i-1)).ZLim = [XYZmin(3) XYZmax(3)];
    axH(2 + 3*(i-1)).XLim = [XYZmin(1) XYZmax(1)];
    axH(3 + 3*(i-1)).YLim = [XYZmin(2) XYZmax(2)];
    axH(3 + 3*(i-1)).ZLim = [XYZmin(3) XYZmax(3)];
    
end

if ~isempty(figname)
    saveas(figH, [oDir, filesep, figname, '.fig']);
    print(figH, [oDir, filesep, figname, '.png'], ...
    '-dpng', '-opengl', '-r300');
    pause(1)
    close(figH)
end

end
