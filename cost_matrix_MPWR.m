function C1 = cost_matrix_MPWR(t, Y, p, Lmin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matJ = cost_matrix_MPWR(t, Y, p, Lmni)
% matrice_cout calcule la matrice cout de fisher pour
% la segmentation du signal
%   C1(a,b) = sum_{t=a}^{t=b}[log(sigma2)+(xt-mu)^2/sigma2]
% avec mu = beta'*r_i : un polynome d'ordre p;
% ici beta se calcule pour chaque couple (a,b).
%
% ENTREES:
%
%        Y : signal de dim(nxd) (pour linstant cette fonction
%            n'est utilisable que pour des signaux monovaries)
%        t : domaine temporel.
%        p : ordre de regression
%        Lmin : nbre de points minimum dans un segment (par defaut Lmin = 1)
%
% SORTIES:
%
%        C1 : matrice cout (partition en un seul segment) de dim [nxn]
%
%
%
% Faicel Chamroukhi, 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
    Lmin = 1;
end
[n, d] = size(Y);

X = designmatrix(t,p);

nl = n-Lmin+1;

C1 = Inf(n,n);
C1 = tril(C1,Lmin-2);

for a = 0:nl
    for b = a+1+Lmin:n     % ici et dans ce qui suit a+1 car en Matlab les indices commencent de 1
        Yab = Y(a+1:b,:);
        X_ab = X(a+1:b,:);
        nk = b-a; %length(xab)
        beta = inv(X_ab'*X_ab)*X_ab'*Yab;
        Z = Yab - X_ab*beta;
        Sigma = Z'*Z/nk;
        
        mahalanobis = sum((Z*inv(Sigma)).*Z,2);
        C1(a+1, b)= nk * (d/2)*log(2*pi) + nk * 0.5*log(det(Sigma)) + 0.5*sum(mahalanobis);
    end
    
end








