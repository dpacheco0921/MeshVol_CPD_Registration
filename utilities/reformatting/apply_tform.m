function Y = apply_tform(X, xform)
% apply_tform: apply transform to meshes/surfaces/trees
%
% Usage:
%   Y = apply_tform(X, xform)
% 
% Args:
%   X: points or surface
%   xform: structure contaning ridig (ICP) and CPD transformation
% 
% See also: 

pts = X;

if isstruct(X)
    pts = X.node;
end

if isfield(xform, 'tform_initial')
    pts = xform.tform_initial.transformPointsForward(pts);
end

pts = cpd_transform(pts, xform.tform_cpd);

Y = pts;
if isstruct(X)
    Y = X;
    Y.node = pts;
end

end
