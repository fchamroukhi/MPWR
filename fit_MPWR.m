function MPWR = fit_MPWR(x, Y, K, p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithme de fisher de regression par morceaux pour la parametrisation
% des signaux de manoeuvre d'aiguillages en utilisant la programmation dynamique.
% les parametres à estimer sont:
% 1. les temps de changement de différents phases du signal
%
% Une fois la partition estimée; on calcule les coeffecients de regression
% associés a chaque segment ainsi que la variance du bruit sur chaque segment
% 2. les parametres de regression de chaque phase du signal
% 3. les variances du bruit additif sur chaque phase
%  La méthode d'estimation est le maximum de vraisemblance.
%
%
%
% Faicel Chamroukhi Decembre 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if size(y,2)~=1, y=y';end
if size(x,2)~=1, x=x';end

[n, d] = size(Y);

Lmin=p + d;%1

warning off

X = designmatrix(x,p);
%%% Initialisation : calcul de J_1;

tic
%%% matrice "cut"
C1 = cost_matrix_MPWR(x, Y, p, Lmin);

%%% dynamic programming
[Ck, t_est] = dynamic_prog(C1, K);

gammak = [0 t_est(end,:)]; % change points

% estimation of the corresponding regression coefficients
mean_function = zeros(n, d);
Betak = zeros(p+1,d,K);
Sigmak = zeros(d,d,K);
for k=1:K
    i = gammak(k)+1;
    j = gammak(k+1);
    nk = j-i+1;
    Yij = Y(i:j, :);
    X_ij = X(i:j,:);
    betak = inv(X_ij'*X_ij)*X_ij'*Yij;%regression coeff matrix
    Z = Yij-X_ij*betak;
    Betak(:, :, k) = betak;
    Sigmak(:,:,k) = Z'*Z/nk;    %covariance matrix
    
    mean_function(i:j,:) = X_ij*betak;%Betak(:,:,k);
end
%
% classes estimees:
klas = zeros(n,1);
Zik = zeros(n,K);
for k = 1:K
    i = gammak(k)+1;
    j = gammak(k+1);
    klas(i:j) = k;
    Zik(i:j,k)=1;
end
MPWR.param.Betak = Betak;
MPWR.param.Sigmak = Sigmak;
MPWR.param.gammak = gammak(2:end-1);%sans le 0 et le n
MPWR.param.parameter_vector = [MPWR.param.gammak(:);MPWR.param.Betak(:);MPWR.param.Sigmak(:)];

MPWR.stats.klas = klas;
MPWR.stats.mean_function=mean_function;
for k = 1:K
    MPWR.stats.regressors(:,:,k) = X*MPWR.param.Betak(:,:,k);
end
MPWR.stats.Zik = Zik;
MPWR.stats.objective = Ck(end);
MPWR.stats.cputime = toc;

