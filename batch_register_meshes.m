function xform = batch_register_meshes(...
    ibeta, lambda, outliers, resample_factor, ...
    mesh_1, mesh_2, reg_direction, plot_flag, ...
    oDir, mesh_3, mesh_4, xform)
% batch_register_meshes: performs registration of meshes 
%   using point set registration algorithm in batches of 
%   different parameters (ibeta, lambda, and outliers)
%   allowing parameter exploration.
%
% Usage:
%   xform = batch_register_meshes(...
%       ibeta, lambda, outliers, resample_factor, ...
%       mesh_1, mesh_2, reg_direction, plot_flag, ...
%       oDir, mesh_3, mesh_4, xform)
% 
% Args:
%   ibeta: strength of interaction between points (width of Gaussian kernel)
%       -> small: more local deformations, large: more globally translational
%       (default, 10)
%   lambda: trade-off between data fitting and smoothness regularization
%       i.e. controls how smooth the transformation is.
%       (default, 1)
%   outliers: noise weight
%       (default, 0.2)
%   resample_factor: factor used for resampling
%       (default, 0.1)
%   iparams: parameters to update
%   mesh_1: mesh/surface 1
%   mesh_2: mesh/surface 2
%   reg_direction: direction of registratrion to generate
%       (default, '1to2', from mesh 1 (floating) to mesh 2 (reference))
%   plot_flag: flag to plot results
%       (default, 1)
%   oDir: output directory where to save figures
%       (default, pwd)
%   mesh_3: meshes/surfaces 3 with same coordinates as mesh 1, used to
%       vizualize goodness of registation
%   mesh_4: meshes/surfaces 4  with same coordinates as mesh 2, used to
%       vizualize goodness of registation
%   xform: family of transformations
%       (default, [])
%       (if inputed then set plot_flag == 2 to just plot the results of registration)
%
% Output:
%   xform: a cell collection of structures containing
%       ridig (ICP) and CPD transformation.
%
% Notes:
%   ibeta: seems like relevant values are below 10.
%   outliers: maybe try lower as noise should be minimal
%       given that the domains are manually annotated.
%
% See also:
%   register_meshes

if ~exist('ibeta', 'var') || isempty(ibeta)
    ibeta = 10;
end

if ~exist('lambda', 'var') || isempty(lambda)
    lambda = 1;
end

if ~exist('outliers', 'var') || isempty(outliers)
    outliers = 0.2;
end

if ~exist('reg_direction', 'var') || isempty(reg_direction)
    reg_direction = '1to2';
end

if ~exist('plot_flag', 'var') || isempty(plot_flag)
    plot_flag = 1;
end

if ~exist('resample_factor', 'var') || isempty(resample_factor)
    resample_factor = 0.1;
end

if ~exist('mesh_3', 'var') || isempty(mesh_3)
    mesh_3 = [];
end

if ~exist('mesh_4', 'var') || isempty(mesh_4)
    mesh_4 = [];
end

if ~exist('oDir', 'var') || isempty(oDir)
    oDir = pwd;
end

% run allcombinations of parameters
if ~exist('registration_', 'var') || isempty(xform)
    xform = cell([numel(ibeta), ...
        numel(lambda), numel(outliers)]);
end

iparams.viz = 0;

for i = 1:numel(ibeta)
    
    for j = 1:numel(lambda)
        
        for k = 1:numel(outliers)
           
            % collect params
            iparams.beta = ibeta(i);
            iparams.lambda = lambda(j);
            iparams.outliers = outliers(k);
            
            if isempty(xform{i, j, k}) || plot_flag == 2
                
                figname = ['reg', reg_direction, ...
                    '_ibeta_', num2str(iparams.beta), ...
                    '_lambda_', num2str(iparams.lambda), ...
                    '_outliers_', num2str(iparams.outliers)];
                figname = strrep(figname, '.', '');
                
                % do registration
                if strcmp(reg_direction, '1to2')
                    
                    if plot_flag ~= 2
                        
                        t0 = stic;
                        xform{i, j, k} = ...
                            register_meshes(mesh_2, mesh_1, ...
                            resample_factor, iparams);
                        stocf(t0, 'Finished registration 1 -> 2');
                        
                    end
                    
                    % plot results
                    if plot_flag
                        overlay_meshes(xform{i, j, k}, ...
                            mesh_2, mesh_1, oDir, figname, mesh_3, mesh_4);
                    end
                    
                elseif strcmp(reg_direction, '2to1')
                    
                    if plot_flag ~= 2
                        
                        t0 = stic;
                        xform{i, j, k} = ...
                            register_meshes(mesh_1, mesh_2, ...
                            resample_factor, iparams);
                        stocf(t0, 'Finished registration 2 -> 1');
                        
                    end
                    
                    % plot results
                    if plot_flag
                        overlay_meshes(xform{i, j, k}, ...
                            mesh_1, mesh_2, oDir, figname, mesh_4, mesh_3);
                    end
                    
                end
                
            else
                
                fprintf('Already tested\n')
                
            end
            
        end
        
    end
    
end

end

function overlay_meshes(xform, mesh_ref, ...
    mesh_float, oDir, figname, mesh_float_2, mesh_ref_2)
% overlay_meshes: plot results of registration, it reformat mesh_float to
%   ref coordinates and the overlays it to mesh_ref
%
% Usage:
%   overlay_meshes(registration_, mesh_ref, ...
%       mesh_float, oDir, figname, mesh_float_2, mesh_ref_2)
% 
% Args:
%   xform: transformation
%   mesh_ref: reference mesh
%   mesh_float: floating mesh
%   oDir: output directory where to save figures
%   mesh_float_2: meshes/surfaces with same coordinates as mesh_float, used to
%       vizualize goodness of registation
%   mesh_ref_2: meshes/surfaces with same coordinates as mesh_ref, used to
%       vizualize goodness of registation

% reformat float to ref coordinates
mesh_float = apply_tform(mesh_float, xform);

% plo meshes
figH = figure('Position', [124 326 1122 361]); 
axH(1) = subplot(2, 3, 1);
vizsurfn(mesh_ref, mesh_float);
view([90 90]);

axH(2) =subplot(2, 3, 2);
vizsurfn(mesh_ref, mesh_float);
view([0 0]);

axH(3) =subplot(2, 3, 3);
vizsurfn(mesh_ref, mesh_float);
view([90 0]);

XYZmin = min([mesh_ref.node], [], 1);
XYZmax = max([mesh_ref.node], [], 1);

% do extra mesh
if ~isempty(mesh_float_2)
    
    if exist('mesh_ref_2', 'var') && ...
            ~isempty(mesh_ref_2)
        mesh_ref = mesh_ref_2;
    end
    
    mesh_float_2 = apply_tform(mesh_float_2, xform);
    
    axH(4) = subplot(2, 3, 4);
    vizsurfn(mesh_ref, mesh_float_2);
    view([90 90]);
    
    axH(5) = subplot(2, 3, 5);
    vizsurfn(mesh_ref, mesh_float_2);
    view([0 0]);
    
    axH(6) = subplot(2, 3, 6);
    vizsurfn(mesh_ref, mesh_float_2);
    view([90 0]);
    
    XYZmin_ = min([mesh_ref.node], [], 1);
    XYZmax_ = max([mesh_ref.node], [], 1);
    
end

axH(1).XLim = [XYZmin(1) XYZmax(1)];
axH(1).YLim = [XYZmin(2) XYZmax(2)];
axH(4).XLim = [XYZmin_(1) XYZmax_(1)];
axH(4).YLim = [XYZmin_(2) XYZmax_(2)];
axH(2).ZLim = [XYZmin(3) XYZmax(3)];
axH(2).XLim = [XYZmin(1) XYZmax(1)];
axH(5).ZLim = [XYZmin_(3) XYZmax_(3)];
axH(5).XLim = [XYZmin_(1) XYZmax_(1)];
axH(3).YLim = [XYZmin(2) XYZmax(2)];
axH(3).ZLim = [XYZmin(3) XYZmax(3)];
axH(6).YLim = [XYZmin_(2) XYZmax_(2)];
axH(6).ZLim = [XYZmin_(3) XYZmax_(3)];

pause(1)

print(figH, [oDir, filesep, figname, '.png'], ...
    '-dpng', '-opengl', '-r300');

close(figH)

end
