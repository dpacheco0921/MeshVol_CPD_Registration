function [X, Y, Z]= gen_bw_meshgrid(BW, xyz_res, grid_res, iaxisOrder)
% gen_bw_meshgrid: generate meshgrid of BW
% 
% Usage:
%   [X, Y, Z] = gen_bw_meshgrid(BW, xyz_res, grid_res, iaxisOrder)
%
% Arguments
%   BW: 3D matrix
%   xyz_res: pixel resolution
%       (default, [1 1 1])
%   grid_res: grid resolution
%       (default, xyz_res)
%   iaxisOrder: order of axis (for generating grid)
%       (default, 'xyz')
%
% See also:
%   meshgrid

if ~exist('xyz_res', 'var') || isempty(xyz_res)
    xyz_res = [1 1 1];
end

if ~exist('grid_res', 'var') || isempty(grid_res)
    grid_res = xyz_res;
end

if ~exist('iaxisOrder', 'var') || isempty(iaxisOrder)
    iaxisOrder = 'xyz';
end

% define surface grid
siz = size(BW);

if strcmpi(iaxisOrder, 'xyz')
    
    [X, Y, Z] = meshgrid(xyz_res(1)/2:grid_res(1):(xyz_res(1)*siz(1)), ...
       xyz_res(2)/2:grid_res(2):(xyz_res(2)*siz(2)), ...
       xyz_res(3)/2:grid_res(3):(xyz_res(3)*siz(3))); 
   
elseif strcmpi(iaxisOrder, 'yxz')
    
    [X, Y, Z] = meshgrid(xyz_res(2)/2:grid_res(2):(xyz_res(2)*siz(2)), ...
       xyz_res(1)/2:grid_res(1):(xyz_res(1)*siz(1)), ...
       xyz_res(3)/2:grid_res(3):(xyz_res(3)*siz(3)));
   
elseif strcmpi(iaxisOrder, 'xy')
    
    [X, Y, Z] = meshgrid(xyz_res(1)/2:grid_res(1):(xyz_res(1)*siz(1)), ...
       xyz_res(2)/2:grid_res(2):(xyz_res(2)*siz(2)), 0); 
   
elseif strcmpi(iaxisOrder, 'yx')
    
    [X, Y, Z] = meshgrid(xyz_res(2)/2:grid_res(2):(xyz_res(2)*siz(2)), ...
       xyz_res(1)/2:grid_res(1):(xyz_res(1)*siz(1)), 0);   

elseif strcmpi(iaxisOrder, 'yz')
    
    [X, Y, Z] = meshgrid(xyz_res(1)/2:grid_res(1):(xyz_res(1)*siz(1)), ...
       0, xyz_res(3)/2:grid_res(3):(xyz_res(3)*siz(3))); 
   
elseif strcmpi(iaxisOrder, 'yzi')
    
    [X, Y, Z] = meshgrid(xyz_res(2)/2:grid_res(2):(xyz_res(2)*siz(2)), ...
       0, xyz_res(3)/2:grid_res(3):(xyz_res(3)*siz(3)));
   
end

end
