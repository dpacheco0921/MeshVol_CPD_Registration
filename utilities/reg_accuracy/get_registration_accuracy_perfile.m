function regacc = get_registration_accuracy_perfile(...
    roi_meshes_filepath, roi_meshes, reg2use_path, repairtype)
% get_registration_accuracy_perfile: runs get_registration_accuracy 
%   per roi_meshes_filepath
%
% Usage:
%   regacc = get_registration_accuracy_perfile(...
%       roi_meshes_filepath, roi_meshes, reg2use_path, repairtype)
% 
% Args:
%   roi_meshes_filepath: path to file containing roi meshes
%       to use for accuracy measurement
%   roi_meshes: roi meshes to load
%       (this is a cell, where first is float, and second is ref),
%   reg2use_path: registration structure
%   repairtype: gate to perform mesh repair
%
% Output:
%   regacc: structure with jaccard_index, float_frac and ref_frac.
% 
% Notes: 
%   roi_meshes: defines the float and ref meshes (1, 2) respectively
%       then depending on the registration structure it finds it
%       will change the order to calculate the accuracy for the 
%       particular registration direction 
%
% See also:
%   get_registration_accuracy

t0 = stic;

% load meshes to use
mesh2use = load_sel_vars(roi_meshes_filepath, roi_meshes);

% load registration file (loads reg_struct)
%   reg_struct has either a field "reg_1to2" or "reg_2to1"
load(reg2use_path)

stocf(t0, 'Finished loading reg-struct and rois');

% get accuracy measurement
t0 = stic;

if isfield(reg_struct, 'reg_1to2')
    
    % "reg_1to2" has registration to move roi_meshes{1} (float) to
    %   roi_meshes{2} (ref) coordinates
    [jaccard_index, float_frac, ref_frac] = ...
        get_registration_accuracy(reg_struct.reg_1to2, ...
        mesh2use.(roi_meshes{1}), mesh2use.(roi_meshes{2}), repairtype);

else
    
    % "reg_2to1" has registration to move roi_meshes{2} to roi_meshes{1}
    %   coordinates
    [jaccard_index, float_frac, ref_frac] = ...
        get_registration_accuracy(reg_struct.reg_2to1, ...
        mesh2use.(roi_meshes{2}), mesh2use.(roi_meshes{1}), repairtype);

end

stocf(t0, 'Finished calculating registration accuracy');

% collect output variable
use_rois = load_sel_vars(roi_meshes_filepath, {'use_rois'});
use_rois = use_rois.use_rois;

regacc.roi_names = use_rois(:);
regacc.jaccard_index = jaccard_index;
regacc.float_frac = float_frac;
regacc.ref_frac = ref_frac;

end
