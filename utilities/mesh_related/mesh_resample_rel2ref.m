function S = mesh_resample_rel2ref(S, ref_Yidx, ref_node_n)
% mesh_resample_rel2ref: resample group of meshes, where the ratio
%    is relative to a member of the group or to a specific number of nodes
%
% Usage:
%   S = mesh_resample_rel2ref(Y, ref_Yidx, ref_node_n)
% 
% Args:
%   Y: mesh structure (ISO format)
%   ref_Yidx: index of mesh to use as reference for number of nodes
%   ref_node_n: reference number of nodes
%
% See also:

fprintf('Original node size:\n')
display([cf(@(x) size(x.node, 1), S)' cf(@(x) x.type, S)'])
node_siz = cell2mat(cf(@(x) size(x.node, 1), S)');

% define reference size and estimate ratio
if exist('ref_node_n', 'var') && ~isempty(ref_node_n)
    ratios_ = node_siz.\ref_node_n;
else
    ratios_ = node_siz.\node_siz(ref_Yidx);
end

% resample to match to the size of a reference mesh
for i = 1:numel(ratios_)
    if ratios_(i) ~= 1
        [S{i}.node, S{i}.elem] = ...
            meshresample(S{i}.node, S{i}.elem, ratios_(i));
    end
end

fprintf('Final node size:\n')
display([cf(@(x) size(x.node, 1), S)' cf(@(x) x.type, S)'])
fprintf('Done\n')

end
