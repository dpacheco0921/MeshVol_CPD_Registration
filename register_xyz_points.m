function xyz = register_xyz_points(xyz, refi, refo, xDir)
% register_xyz_points: function that performs reformatting
%   of XYZ points from IBNWB to IVIA or IVIA to IBNWB coordinates using CPD
%
% Usage:
%   xyz = to_atlas2atlas_xform(xyz, refi, refo, xDir)
%
% Args:
%   xyz: input object (xyz matrix or matfile with xyz matrix)
%   refi: input reference atlas
%   refo: output reference atlas
%   xDir: directory of transformation

if ~exist('xDir', 'var') || isempty(xDir)
    xDir = '.';
end

% load transformation
if contains(refo, 'nsybIVAi')

    transform_ = 'reg_1to2_woOL_cbrain_lambda_1_beta_5_outliers_02_smp_1.mat';
    load([xDir, filesep, transform_], 'reg_struct')
    reg_struct = reg_struct.reg_1to2;

elseif contains(refi, 'nsybIVAi')

    transform_ = 'reg_2to1_woOL_cbrain_lambda_1_beta_10_outliers_02_smp_1.mat';
    load([xDir, filesep, transform_], 'reg_struct')                 
    reg_struct = reg_struct.reg_2to1;

end

if ischar(xyz)
    xyz = load([xyz, '.mat'], 'xyz');
    xyz = xyz.xyz;
elseif ~isvector(xyz)
    fprintf('error with input variable')
    return
end

% invert axis (trasformation takes 3D matrices were first axis is y instead of x)
xyz = xyz(:, [2 1 3]);

if size(xyz, 1) > 10^4
    
    % partition matrix if it is too big
    xyz = chunk2cell(xyz, 10^4);
    
    for i = 1:numel(xyz)
        stic
        xyz_temp{i, 1} = apply_tform(xyz{i}, reg_struct);
        stoc
    end
    
    xyz = cell2mat(xyz_temp);
    clear xyz_temp i
    
else
    
    xyz = apply_tform(xyz, reg_struct);
    
end

clear reg_struct
xyz = xyz(:, [2 1 3]);

end
