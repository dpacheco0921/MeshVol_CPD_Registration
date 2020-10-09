function h = vizsurf(node, elem, facealpha, edgealpha, varargin)
% vizsurf: function that plot surfaces/meshes using plotmesh
%
% Usage:
%   vizsurf(node, elem, facealpha, edgealpha, varargin)
%
% Args:
%   node: a node coordinate list or a structure containing both:
%       node.node and node.elem
%   elem: a triangular surface face list.
%   facealpha and edgealpha: defines the transparency of faces/edges
%       (default, facealpha = 0.9, edgealpha = 0)
%
% See also:
% plotmesh from iso2mesh repo.

if isstruct(node)
    
    if nargin > 1 && (nargin < 3 || isempty(facealpha))
        facealpha = elem;
    end
    
    elem = node.elem;
    node = node.node;
    
end

if nargin < 3 || isempty(facealpha)
    facealpha = 0.9;
end

if nargin < 4 || isempty(edgealpha)
    edgealpha = 0;
end

if size(elem, 2) < 4
    elem(:, end + 1) = 1;
end

% figure
h = plotmesh(node, elem, ...
    'facealpha', facealpha, ...
    'linestyle', '-', ...
    'edgealpha', edgealpha, ...
    varargin{:});

axis equal

if ~isempty(varargin) && sum(contains(varargin{1:2:end}, 'gridon')) ~= 0
    graygrid
end

% extra lighting option

%camlight
%lighting gouraud
%material metal

if nargout < 1; clear h; end

end
