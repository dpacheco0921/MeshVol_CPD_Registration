function [jaccard_index, float_frac, ref_frac] = ...
    get_registration_accuracy(regstruct, float_mesh, ...
    ref_mesh, repairtype)
% get_registration_accuracy: estimate registration accuracy by
%   measuring the jaccard_index, float fraction of overlap, and
%   ref fraction of overlap.
%
% Usage:
%   [jaccard_index, float_frac, ref_frac] = ...
%       get_registration_accuracy(regstruct, float_mesh, ...
%       ref_mesh, repairtype)
% 
% Args:
%   regstruct: registration structure used to move float_mesh to ref
%       coordinates
%   float_mesh: mesh/surface in floating image coordinates
%   ref_mesh: mesh/surface in reference image coordinates
%   repairtype: 1x4 vector that defines if repairing and what kind of
%       repair to perform on float_mesh
% 
% See also:
%   mesh_checkrepair_all, apply_tform, meshcheckrepair

if ~exist('repairtype', 'var') || ...
    isempty(repairtype)
    repairtype = zeros(1, 5);
end

jaccard_index = NaN(numel(float_mesh), 1);
float_frac = NaN(numel(float_mesh), 1);
ref_frac =  NaN(numel(float_mesh), 1);

% iteration of repairing
iter = 2;

for i = 1:numel(float_mesh)
    
    t0 = stic;
    
    % repair meshes
    float_ = float_mesh{i}; 
    ref_ = ref_mesh{i};
    
    for j = 1:iter
        float_ = mesh_checkrepair_all(float_, repairtype);
        ref_ = mesh_checkrepair_all(ref_, repairtype);     
    end
    
    % transform float mesh
    float_in_ref_coord = apply_tform(float_, regstruct);
    [float_in_ref_coord.node, float_in_ref_coord.elem] = ...
        meshcheckrepair(float_in_ref_coord.node, ...
        float_in_ref_coord.elem, 'meshfix');

    % add a buffer on edges of each axis
    xyzi = floor(min([float_.node; ref_.node; float_in_ref_coord.node])) - 5;
    xyze = ceil(max([float_.node; ref_.node; float_in_ref_coord.node])) + 5;

    % from mesh to BW
    ref_pix = inpolyhedron(ref_.elem, ref_.node, ...
        xyzi(1):1:xyze(1), xyzi(2):1:xyze(2), xyzi(3):1:xyze(3));
    float_pix = inpolyhedron(float_in_ref_coord.elem, float_in_ref_coord.node, ...
        xyzi(1):1:xyze(1), xyzi(2):1:xyze(2), xyzi(3):1:xyze(3));

    % get intersection
    int_pix_n = sum(float_pix(:) & ref_pix(:));
    
    % get union
    union_pix_n = sum(float_pix(:) | ref_pix(:));
    
    % get n per image
    float_n = sum(float_pix(:));
    ref_n = sum(ref_pix(:));

    % get indeces
    jaccard_index(i) = int_pix_n / union_pix_n;
    float_frac(i) = int_pix_n / float_n;
    ref_frac(i) = int_pix_n / ref_n;
    
    clear float_in_ref_coord xyzi xyze ...
        ref_pix float_pix int_pix_n ...
        union_pix_n float_n ref_n
    
    stocf(t0, ['Finished mesh # ', num2str(i)]);
    
end

end
