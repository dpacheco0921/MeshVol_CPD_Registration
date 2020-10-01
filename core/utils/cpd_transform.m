function T=cpd_transform(Z, Transform)

switch lower(Transform.method)
    case {'rigid','affine'}
        T=Transform.s*(Z*Transform.R')+repmat(Transform.t',[size(Z,1) 1]);
    case {'nonrigid', 'nonrigid_lowrank'}
        
        % because of normalization during the registration
        % these steps are necessary for non-rigid transformation
        Transform.beta=Transform.beta*Transform.normal.yscale;
        Transform.W=Transform.normal.xscale*Transform.W;
        Transform.shift=Transform.normal.xd-Transform.normal.xscale/Transform.normal.yscale*Transform.normal.yd;
        Transform.s=Transform.normal.xscale/Transform.normal.yscale;

        G=cpd_G(Z, Transform.Yorig,Transform.beta);
        if size(G,2) == 1 && size(G,1) == size(Transform.W,1); G = G'; end
        T=Z*Transform.s+G*Transform.W+repmat(Transform.shift,size(Z,1),1);
        % T=Transform.s*Z+repmat(Transform.t',[size(Z,1) 1])+cpd_G(Z, Transform.Yorig,Transform.beta)*Transform.W;
    otherwise
        error('CPD: This transformation is not supported.')
end         
