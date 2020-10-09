function S = mesh_resample_weighted(S, i_ratios)
% mesh_resample_weighted: resample group of meshes/surfaces, where 
%   the ratio is relative to members of the group
%
% Usage:
%   S = mesh_resample_weighted(Y, i_ratios)
% 
% Args:
%   S: mesh/surface structure (ISO format)
%   i_ratios: ratio per mesh/surface
%
% See also:

fprintf('Original node size:\n')
display([cf(@(x) size(x.node, 1), S)' cf(@(x) x.type, S)'])

% upsample or downsample a group of meshes using weights
for i = 1:numel(i_ratios)
    if i_ratios(i) ~= 1
        [S{i}.node, S{i}.elem] = ...
            meshresample(S{i}.node, S{i}.elem, i_ratios(i));
    end
end

fprintf('Final node size:\n')
display([cf(@(x) size(x.node, 1), S)' cf(@(x) x.type, S)'])
fprintf('Done\n')

end
