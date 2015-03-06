function [q,out_param] = cubLattice_g(varargin)
%CUBLATTICE_G is a Quasi-Monte Carlo method using rank-1 Lattices cubature
%over a d-dimensional region to integrate within a specified generalized error 
%tolerance with guarantees under Fourier coefficients cone decay assumptions.
%
%   [q,out_param] = CUBLATTICE_G(f,hyperbox) estimates the integral of f
%   over the d-dimensional region described by hyperbox, and with an error
%   guaranteed not to be greater than a specific generalized error tolerance,
%   tolfun:=max(abstol,reltol*| integral(f) |). Input f is a function handle. f should
%   accept an n x d matrix input, where d is the dimension and n is the 
%   number of points being evaluated simultaneously. The input hyperbox is
%   a 2 x d matrix, where the first row corresponds to the lower limits 
%   and the second row corresponds to the upper limits of the integral.
%   Given the construction of our Lattices, d must be a positive integer
%   with 1<=d<=250.
% 
%   q = CUBLATTICE_G(f,hyperbox,measure,abstol,reltol)
%   estimates the integral of f over the hyperbox. The answer
%   is given within the generalized error tolerance tolfun. All parameters
%   should be input in the order specified above. If an input is not specified,
%   the default value is used. Note that if an input is not specified,
%   the remaining tail cannot be specified either. Inputs f and hyperbox 
%   are required. The other optional inputs are in the correct order:
%   measure,abstol,reltol,shift,mmin,mmax,fudge,transform,toltype and
%   theta.
% 
%   q = CUBLATTICE_G(f,hyperbox,'measure',measure,'abstol',abstol,'reltol',reltol)
%   estimates the integral of f over the hyperbox. The answer
%   is given within the generalized error tolerance tolfun. All the field-value
%   pairs are optional and can be supplied in any order. If an input is not
%   specified, the default value is used.
% 
%   q = CUBLATTICE_G(f,hyperbox,in_param) estimates the integral of f over the
%   hyperbox. The answer is given within the generalized error tolerance tolfun.
% 
%   Input Arguments
%
%     f --- the integrand whose input should be a matrix n x d where n is
%     the number of data points and d the dimension, which cannot be
%     greater than 250. By default f is f=@ x.^2.
%
%     hyperbox --- the integration region defined by its bounds. It must be
%     a 2 x d matrix, where the first row corresponds to the lower limits 
%     and the second row corresponds to the upper limits of the integral.
%     The default value is [0;1].
% 
%     in_param.abstol --- the absolute error tolerance, abstol>=0. By 
%     default it is 1e-4.
%
%     in_param.reltol --- the relative error tolerance, which should be
%     in [0,1]. Default value is 1e-1.
% 
%     in_param.measure --- for f(x)*mu(dx), we can define mu(dx) to be the
%     measure of a uniformly distributed random variable in they hyperbox
%     or normally distributed with covariance matrix I_d. The only possible
%     values are 'uniform' or 'normal'. For 'uniform', the hyperbox must be
%     finite while for 'normal', the hyperbox can only be defined as 
%     (-Inf,Inf)^d. By default it is 'uniform'.
% 
%   Optional Input Arguments
% 
%     in_param.shift --- the Rank-1 lattices can be shifted to avoid the origin
%     or other particular points. By default we consider a uniformly [0,1)
%     random shift.
% 
%     in_param.mmin --- the minimum number of points to start is 2^mmin. The
%     cone condition on the Fourier coefficients decay requires a minimum
%     number of points to start. The advice is to consider at least mmin=10.
%     mmin needs to be a positive integer with mmin<=mmax. By default it is 10.
% 
%     in_param.mmax --- the maximum budget is 2^mmax. By construction of our
%     Lattices generator, mmax is a positive integer such that mmin<=mmax<=26.
%     The default value is 24.
% 
%     in_param.fudge --- the positive function multiplying the finite 
%     sum of Fast Fourier coefficients specified in the cone of functions.
%     For more information about this parameter, refer to the references.
%     By default it is @(m) 5*2.^-m.
% 
%     in_param.transform --- the algorithm is defined for continuous
%     periodic functions. If the input function f is not, there are 5
%     types of transform to periodize it without modifying the result. 
%     By default it is the Baker's transform. The options are:
%       'id' : no transformation.
%       'Baker' : Baker's transform or tent map in each coordinate. Preserving
%                 only continuity but simple to compute. Chosen by default.
%       'C0' : polynomial transformation only preserving continuity.
%       'C1' : polynomial transformation preserving the first derivative.
%       'C1sin' : Sidi's transform with sine, preserving the first derivative.
%                 This is in general a better option than 'C1'.
%
%     in_param.toltype --- this is the generalized tolerance function.
%     There are two choices, 'max' which takes
%     max(abstol,reltol*| integral(f) |) and 'comb' which is the linear combination
%     theta*abstol+(1-theta)*reltol*| integral(f) |. Theta is another 
%     parameter to be specified with 'comb'(see below). For pure absolute
%     error, either choose 'max' and set reltol = 0 or choose 'comb' and set
%     theta = 1. For pure relative error, either choose 'max' and set 
%     abstol = 0 or choose 'comb' and set theta = 0. Note that with 'max',
%     the user can not input abstol = reltol = 0 and with 'comb', if theta = 1
%     abstol con not be 0 while if theta = 0, reltol can not be 0.
%     By default toltype is 'max'.
% 
%     in_param.theta --- this input is parametrizing the toltype 
%     'comb'. Thus, it is only afecting when the toltype
%     chosen is 'comb'. It stablishes the linear combination weight
%     between the absolute and relative tolerances
%     theta*abstol+(1-theta)*reltol*| integral(f) |. Note that for theta = 1, 
%     we have pure absolute tolerance while for theta = 0, we have pure 
%     relative tolerance. By default, theta=1.
%
%   Output Arguments
%
%     q --- the estimated value of the integral.
% 
%     out_param.n --- number of Rank-1 lattice points used for comupting
%     the integral of f.
% 
%     out_param.bound_err --- predicted bound on the error based on the cone
%     condition. If the function lies in the cone, the real error will be
%     smaller than generalized tolerance.
% 
%     out_param.time --- time elapsed in seconds when calling cubLattice_g.
%
%     out_param.exitflag --- this is a binary vector stating whether 
%     warning flags arise. These flags tell about which conditions make the
%     final result certainly not guaranteed. One flag is considered arisen
%     when its value is 1. The following list explains the flags in the
%     respective vector order:
%
%                       1    If reaching overbudget. It states whether
%                       the max budget is attained without reaching the
%                       guaranteed error tolerance.
%      
%                       2   If the function lies outside the cone. In
%                       this case, results are not guaranteed. Note that
%                       this parameter is computed on the transformed
%                       function, not the input function. For more
%                       information on the transforms, check the input
%                       parameter in_param.transfrom; for information about
%                       the cone definition, check the article mentioned
%                       below.
% 
%  Guarantee
% This algorithm computes the integral of real valued functions in [0,1)^d 
% with a prescribed generalized error tolerance. The Fourier coefficients of 
% the integrand are assumed to be absolutely convergent.
% If the algorithm terminates without warning messages, the output is 
% given with guarantees under the assumption that the integrand lies inside
% a cone of functions. The guarantee is based on the decay rate of the 
% Fourier coefficients. For more details on how the cone is defined, 
% please refer to the references below.
% 
%  Examples
% 
% Example 1:
% Estimate the integral with integrand f(x) = x1.*x2 in the interval [0,1)^2:
% 
% >> f = @(x) prod(x,2); hyperbox = [zeros(1,2);ones(1,2)]; q = cubLattice_g(f,hyperbox,'uniform',1e-5,1e-1,'transform','C1sin')
% q = 0.25***
% 
% 
% Example 2:
% Estimate the integral with integrand f(x) = x1.^2.*x2.^2.*x3.^2+0.11
% in the interval R^3 where x1, x2 and x3 are normally distributed:
% 
% >> f = @(x) x(:,1).^2.*x(:,2).^2.*x(:,3).^2+0.11; hyperbox = [zeros(1,3);ones(1,3)]; q = cubLattice_g(f,hyperbox,'normal',1e-3,1e-3,'transform','C1sin')
% q = 1.1***
% 
% 
% Example 3: 
% Estimate the integral with integrand f(x) = exp(-x1^2-x2^2) in the
% interval [0,1)^2:
% 
% >> f = @(x) exp(-x(:,1).^2-x(:,2).^2); hyperbox = [zeros(1,2);ones(1,2)]; q = cubLattice_g(f,hyperbox,'uniform',1e-3,1e-1,'transform','C1')
% q = 0.55***
%
%
% Example 4: 
% Estimate the price of an European call with S0=100, K=100, r=sigma^2/2,
% sigma=0.05 and T=1.
% 
% >> f = @(x) exp(-0.05^2/2)*max(100*exp(0.05*x)-100,0); hyperbox = [zeros(1,1);ones(1,1)]; q = cubLattice_g(f,hyperbox,'normal',1e-4,1e-1,'fudge',@(m) 2.^-(2*m),'transform','C1sin')
% q = 2.05***
%
%
% Example 5:
% Estimate the integral with integrand f(x) = 8*x1.*x2.*x3.*x4.*x5 in the interval
% [0,1)^5 with pure absolute error 1e-5.
% 
% >> f = @(x) 8*prod(x,2); hyperbox = [zeros(1,5);ones(1,5)]; q = cubLattice_g(f,hyperbox,'uniform',1e-5,0)
% q = 0.25***
%
%
%   See also CUBSOBOL_G, CUBMC_G, MEANMC_G, INTEGRAL_G
% 
%  References
%
%   [1] Lluis Antoni Jimenez Rugama and Fred J. Hickernell: Adaptive Multidimensional
%   Integration Based on Rank-1 Lattices (2014). Submitted for publication:
%   arXiv:1411.1966.
%
%   [2] Sou-Cheng T. Choi, Fred J. Hickernell, Yuhan Ding, Lan Jiang,
%   Lluis Antoni Jimenez Rugama, Xin Tong, Yizhi Zhang and Xuan Zhou,
%   "GAIL: Guaranteed Automatic Integration Library (Version 2.1)"
%   [MATLAB Software], 2015. Available from http://code.google.com/p/gail/
%
%   [3] Sou-Cheng T. Choi, "MINRES-QLP Pack and Reliable Reproducible
%   Research via Supportable Scientific Software", Journal of Open Research
%   Software, Volume 2, Number 1, e22, pp. 1-7, DOI:
%   http://dx.doi.org/10.5334/jors.bb, 2014.
%
%   [4] Sou-Cheng T. Choi and Fred J. Hickernell, "IIT MATH-573 Reliable
%   Mathematical Software" [Course Slides], Illinois Institute of
%   Technology, Chicago, IL, 2013. Available from
%   http://code.google.com/p/gail/ 
%
%   [5] Sou-Cheng T. Choi, "Summary of the First Workshop On Sustainable
%   Software for Science: Practice And Experiences (WSSSPE1)", Journal of
%   Open Research Software, Volume 2, Number 1, e6, pp. 1-21, DOI:
%   http://dx.doi.org/10.5334/jors.an, 2014.
%
%   If you find GAIL helpful in your work, please support us by citing the
%   above papers, software, and materials.
%

tic
%% Check and initialize parameters
[f,hyperbox,out_param] = cubLattice_g_param(varargin{:});

if strcmp(out_param.measure,'normal')
   f=@(x) f(gail.stdnorminv(x));
elseif strcmp(out_param.measure,'uniform')
   Cnorm = prod(hyperbox(2,:)-hyperbox(1,:));
   f=@(x) Cnorm*f(bsxfun(@plus,hyperbox(1,:),bsxfun(@times,(hyperbox(2,:)-hyperbox(1,:)),x))); % a + (b-a)x = u
end

if strcmp(out_param.transform,'Baker')
    f=@(x) f(1-2*abs(x-1/2)); % Baker's transform
elseif strcmp(out_param.transform,'C0')
    f=@(x) f(3*x.^2-2*x.^3).*prod(6*x.*(1-x),2); % C^0 transform
elseif strcmp(out_param.transform,'C1')
    f=@(x) f(x.^3.*(10-15*x+6*x.^2)).*prod(30*x.^2.*(1-x).^2,2); % C^1 transform
elseif strcmp(out_param.transform,'C1sin')
    f=@(x) f(x-sin(2*pi*x)/(2*pi)).*prod(1-cos(2*pi*x),2); % Sidi C^1 transform
end

%% Main algorithm
r_lag=4; %distance between coefficients summed and those computed
l_star=out_param.mmin-r_lag;
Stilde=zeros(out_param.mmax-out_param.mmin+1,1); %initialize sum of DFT terms
StildeNC=zeros(out_param.mmax-out_param.mmin+1,r_lag); %initialize various sums of DFT terms for necessary conditions
cond1=(1+out_param.fudge(r_lag))*(1+2*out_param.fudge(r_lag-(1:r_lag)))./(1+out_param.fudge(r_lag-(1:r_lag))); % Factors for the necessary conditions
cond2=(1+out_param.fudge(r_lag-(1:r_lag)))*(1+2*out_param.fudge(r_lag))/(1+out_param.fudge(r_lag)); % Factors for the necessary conditions
errest=zeros(out_param.mmax-out_param.mmin+1,1); %initialize error estimates
appxinteg=zeros(out_param.mmax-out_param.mmin+1,1); %initialize approximations to integral
exit_len = 2;
out_param.exit=logical(zeros(exit_len,1)); %we start the algorithm with all warning flags down

%% Initial points and FWT
out_param.n=2^out_param.mmin; %total number of points to start with
n0=out_param.n; %initial number of points
xpts=mod(gail.lattice_gen(1,out_param.n,out_param.d)+out_param.shift,1); %grab Lattice points
y=f(xpts); %evaluate integrand
yval=y;

%% Compute initial FFT
for l=0:out_param.mmin-1
   nl=2^l;
   nmminlm1=2^(out_param.mmin-l-1);
   ptind=repmat([true(nl,1); false(nl,1)],nmminlm1,1);
   coef=exp(-2*pi()*sqrt(-1)*(0:nl-1)/(2*nl))';
   coefv=repmat(coef,nmminlm1,1);
   evenval=y(ptind);
   oddval=y(~ptind);
   y(ptind)=(evenval+coefv.*oddval)/2;
   y(~ptind)=(evenval-coefv.*oddval)/2;
end
% y now contains the FFT coefficients

%% Approximate integral
q=mean(yval);
appxinteg(1)=q;

%% Create kappanumap implicitly from the data
kappanumap=(1:out_param.n)'; %initialize map
for l=out_param.mmin-1:-1:1
   nl=2^l;
   oldone=abs(y(kappanumap(2:nl))); %earlier values of kappa, don't touch first one
   newone=abs(y(kappanumap(nl+2:2*nl))); %later values of kappa, 
   flip=find(newone>oldone); %which in the pair are the larger ones
   temp=kappanumap(nl+1+flip); %then flip
   kappanumap(nl+1+flip)=kappanumap(1+flip); %them
   kappanumap(1+flip)=temp; %around
end

%% Compute Stilde
nllstart=int64(2^(out_param.mmin-r_lag-1));
Stilde(1)=sum(abs(y(kappanumap(nllstart+1:2*nllstart))));
for i = 1:r_lag % Storing the information for the necessary conditions
    nllstart=2*nllstart;
    StildeNC(i,i)=sum(abs(y(kappanumap(nllstart+1:2*nllstart))));
end
out_param.bound_err=out_param.fudge(out_param.mmin)*Stilde(1);
errest(1)=out_param.bound_err;

deltaplus = 0.5*(gail.tolfun(out_param.abstol,...
    out_param.reltol,out_param.theta,abs(q-errest(1)),...
    out_param.toltype)+gail.tolfun(out_param.abstol,out_param.reltol,...
    out_param.theta,abs(q+errest(1)),out_param.toltype));
deltaminus = 0.5*(gail.tolfun(out_param.abstol,...
    out_param.reltol,out_param.theta,abs(q-errest(1)),...
    out_param.toltype)-gail.tolfun(out_param.abstol,out_param.reltol,...
    out_param.theta,abs(q+errest(1)),out_param.toltype));

is_done = false;
if out_param.bound_err <= deltaplus
   q=q+deltaminus;
   appxinteg(1)=q;
   out_param.time=toc;
   is_done = true;
elseif out_param.mmin == out_param.mmax % We are on our max budget and did not meet the error condition => overbudget
   out_param.exit(1) = true;
end

%% Loop over m
for m=out_param.mmin+1:out_param.mmax
   if is_done,
       break;
   end
   out_param.n=2^m;
   mnext=m-1;
   nnext=2^mnext;
   xnext=mod(gail.lattice_gen(nnext+1,2*nnext,out_param.d)+out_param.shift,1);
   n0=n0+nnext;
   ynext=f(xnext);
   yval=[yval; ynext];

   %% Compute initial FFT on next points
   for l=0:mnext-1
      nl=2^l;
      nmminlm1=2^(mnext-l-1);
      ptind=repmat([true(nl,1); false(nl,1)],nmminlm1,1);
      coef=exp(-2*pi()*sqrt(-1)*(0:nl-1)/(2*nl))';
      coefv=repmat(coef,nmminlm1,1);
      evenval=ynext(ptind);
      oddval=ynext(~ptind);
      ynext(ptind)=(evenval+coefv.*oddval)/2;
      ynext(~ptind)=(evenval-coefv.*oddval)/2;
   end

   %% Compute FFT on all points
   y=[y;ynext];
   nl=2^mnext;
   ptind=[true(nl,1); false(nl,1)];
   coef=exp(-2*pi()*sqrt(-1)*(0:nl-1)/(2*nl))';
   coefv=repmat(coef,nmminlm1,1);
   evenval=y(ptind);
   oddval=y(~ptind);
   y(ptind)=(evenval+coefv.*oddval)/2;
   y(~ptind)=(evenval-coefv.*oddval)/2;
   
   %% Update kappanumap
   kappanumap=[kappanumap; (nnext+1:out_param.n)']; %initialize map
   for l=m-1:-1:m-r_lag-1
      nl=2^l;
      oldone=abs(y(kappanumap(2:nl))); %earlier values of kappa, don't touch first one
      newone=abs(y(kappanumap(nl+2:2*nl))); %later values of kappa, 
      flip=find(newone>oldone);
      temp=kappanumap(nl+1+flip);
      kappanumap(nl+1+flip)=kappanumap(1+flip);
      kappanumap(1+flip)=temp;
   end

   %% Compute Stilde
   nllstart=int64(2^(m-r_lag-1));
   meff=m-out_param.mmin+1;
   Stilde(meff)=sum(abs(y(kappanumap(nllstart+1:2*nllstart))));
   for i = 1:r_lag % Storing the information for the necessary conditions
       nllstart=2*nllstart;
       StildeNC(i+meff-1,i)=sum(abs(y(kappanumap(nllstart+1:2*nllstart))));
   end
   % disp((Stilde(meff)*cond1(1:min(meff-1,r_lag)))>=(StildeNC(meff-1,1:min(meff-1,r_lag)))) % Displaying necessary condition 1 results (1 if satisfied)
   % disp((StildeNC(meff-1,1:min(meff-1,r_lag)).*cond2(1:min(meff-1,r_lag)))>=(Stilde(meff)*ones(1,min(meff-1,r_lag)))) % Displaying necessary condition 2 results (1 if satisfied)
   if ~(all((Stilde(meff)*cond1(1:min(meff-1,r_lag)))>=(StildeNC(meff-1,1:min(meff-1,r_lag))))*   ...
    all((StildeNC(meff-1,1:min(meff-1,r_lag)).*cond2(1:min(meff-1,r_lag)))>=(Stilde(meff)*ones(1,min(meff-1,r_lag))))),
        out_param.exit(2) = true;
   end
   out_param.bound_err=out_param.fudge(m)*Stilde(meff);
   errest(meff)=out_param.bound_err;
   
   %% Approximate integral
   q=mean(yval);
   appxinteg(meff)=q;

    deltaplus = 0.5*(gail.tolfun(out_param.abstol,...
        out_param.reltol,out_param.theta,abs(q-errest(meff)),...
        out_param.toltype)+gail.tolfun(out_param.abstol,out_param.reltol,...
        out_param.theta,abs(q+errest(meff)),out_param.toltype));
    deltaminus = 0.5*(gail.tolfun(out_param.abstol,...
        out_param.reltol,out_param.theta,abs(q-errest(meff)),...
        out_param.toltype)-gail.tolfun(out_param.abstol,out_param.reltol,...
        out_param.theta,abs(q+errest(meff)),out_param.toltype));

   if out_param.bound_err <= deltaplus
      q=q+deltaminus;
      appxinteg(meff)=q;
      out_param.time=toc;
      is_done = true;
   elseif m == out_param.mmax % We are on our max budget and did not meet the error condition => overbudget
       out_param.exit(1) = true;
   end
end

exit_str='';
if sum(out_param.exit) == 0
  exit_str = '0';
else
  for i=1:exit_len
    if out_param.exit(i)==1,
      if i<exit_len 
        exit_str = strcat(exit_str,{num2str(i)}, {' '});
      else
        exit_str = strcat(exit_str,{num2str(i)});
      end
    end
  end
end
out_param.exitflag = exit_str;
out_param = rmfield(out_param,'exit');

out_param.time=toc;
end


%% Parsing for the input of cubLattice_g
function [f,hyperbox, out_param] = cubLattice_g_param(varargin)

% Default parameter values
default.hyperbox = [zeros(1,1);ones(1,1)];% default hyperbox
default.measure  = 'uniform';
default.abstol  = 1e-4;
default.reltol  = 1e-1;
default.shift  = rand;
default.mmin  = 10;
default.mmax  = 24;
default.fudge = @(m) 5*2.^-m;
default.transform = 'Baker';
default.toltype  = 'max';
default.theta  = 1;

if numel(varargin)<2
    help cubLattice_g
    warning('MATLAB:cubLattice_g:fdnotgiven',...
        'At least, function f and hyperbox need to be specified. Example for f(x)=x^2:')
    f = @(x) x.^2;
    out_param.f=f;
    hyperbox = default.hyperbox;
else
    f = varargin{1};
    if ~gail.isfcn(f)
        warning('MATLAB:cubLattice_g:fnotfcn',...
            'The given input f was not a function. Example for f(x)=x^2:')
        f = @(x) x.^2;
        out_param.f=f;
        hyperbox = default.hyperbox;
    else
        out_param.f=f;
        hyperbox = varargin{2};
        if ~isnumeric(hyperbox) || ~(size(hyperbox,1)==2) || ~(size(hyperbox,2)<251)
            warning('MATLAB:cubLattice_g:cubLattice_g:hyperbox_error1',...
                'The hyperbox must be a real matrix of size 2xd where d can not be greater than 250. Example for f(x)=x^2:')
            f = @(x) x.^2;
            out_param.f=f;
            hyperbox = default.hyperbox;
        end
    end
end

validvarargin=numel(varargin)>2;
if validvarargin
    in3=varargin(3:end);
    for j=1:numel(varargin)-2
    validvarargin=validvarargin && (isnumeric(in3{j}) ...
        || ischar(in3{j}) || isstruct(in3{j}) || gail.isfcn(in3{j}));
    end
    if ~validvarargin
        warning('MATLAB:cubLattice_g:validvarargin','Optional parameters must be numeric or strings. We will use the default optional parameters.')
    end
    in3=varargin{3};
end

MATLABVERSION = gail.matlab_version;
if MATLABVERSION >= 8.3
  f_addParamVal = @addParameter;
else
  f_addParamVal = @addParamValue;
end

if ~validvarargin
    out_param.measure = default.measure;
    out_param.abstol = default.abstol;
    out_param.reltol = default.reltol;
    out_param.shift = default.shift;
    out_param.mmin = default.mmin;
    out_param.mmax = default.mmax;  
    out_param.fudge = default.fudge;
    out_param.transform = default.transform;
    out_param.toltype = default.toltype;
    out_param.theta = default.theta;
else
    p = inputParser;
    addRequired(p,'f',@gail.isfcn);
    addRequired(p,'hyperbox',@isnumeric);
    if isnumeric(in3) || ischar(in3)
        addOptional(p,'measure',default.measure,...
            @(x) any(validatestring(x, {'uniform','normal'})));
        addOptional(p,'abstol',default.abstol,@isnumeric);
        addOptional(p,'reltol',default.reltol,@isnumeric);
        addOptional(p,'shift',default.shift,@isnumeric);
        addOptional(p,'mmin',default.mmin,@isnumeric);
        addOptional(p,'mmax',default.mmax,@isnumeric);
        addOptional(p,'fudge',default.fudge,@gail.isfcn);
        addOptional(p,'transform',default.transform,...
            @(x) any(validatestring(x, {'id','Baker','C0','C1','C1sin'})));
        addOptional(p,'toltype',default.toltype,...
            @(x) any(validatestring(x, {'max','comb'})));
        addOptional(p,'theta',default.theta,@isnumeric);
    else
        if isstruct(in3) %parse input structure
            p.StructExpand = true;
            p.KeepUnmatched = true;
        end
        f_addParamVal(p,'measure',default.measure,...
            @(x) any(validatestring(x, {'uniform','normal'})));
        f_addParamVal(p,'abstol',default.abstol,@isnumeric);
        f_addParamVal(p,'reltol',default.reltol,@isnumeric);
        f_addParamVal(p,'shift',default.shift,@isnumeric);
        f_addParamVal(p,'mmin',default.mmin,@isnumeric);
        f_addParamVal(p,'mmax',default.mmax,@isnumeric);
        f_addParamVal(p,'fudge',default.fudge,@gail.isfcn);
        f_addParamVal(p,'transform',default.transform,...
            @(x) any(validatestring(x, {'id','Baker','C0','C1','C1sin'})));
        f_addParamVal(p,'toltype',default.toltype,...
            @(x) any(validatestring(x, {'max','comb'})));
        f_addParamVal(p,'theta',default.theta,@isnumeric);
    end
    parse(p,f,hyperbox,varargin{3:end});
    out_param = p.Results;
end;

[two, out_param.d]=size(hyperbox); %hyperbox should be 2 x dimension
if ~isnumeric(hyperbox) || ~(size(hyperbox,1)==2) || ~(size(hyperbox,2)<251)
    warning('MATLAB:cubLattice_g:hyperbox_error2',...
        'The hyperbox must be a real matrix of size 2xd where d can not be greater than 250. Example for f(x)=x^2:')
    f = @(x) x.^2;
    out_param.f=f;
    hyperbox = default.hyperbox;
end

% Force absolute tolerance greater than 0
if (out_param.abstol <= 0 )
    warning('MATLAB:cubLattice_g:abstolnonpos',['Error tolerance should be greater than 0.' ...
            ' Using default absolut tolerance ' num2str(default.abstol)])
    out_param.abstol = default.abstol;
end

% Force relative tolerance greater than 0 and smaller than 1
if (out_param.reltol < 0) || (out_param.reltol > 1)
    warning('MATLAB:cubLattice_g:reltolnonunit',['Relative tolerance should be chosen in [0,1].' ...
            ' Using default relative tolerance ' num2str(default.reltol)])
    out_param.reltol = default.reltol;
end

% Force measure to be uniform or normal only
if ~(strcmp(out_param.measure,'uniform') || strcmp(out_param.measure,'normal') )
    warning('MATLAB:cubLattice_g:notmeasure',['The measure can only be uniform or normal.' ...
            ' Using default measure ' num2str(default.measure)])
    out_param.measure = default.measure;
end

% Force mmin to be integer greater than 0
if (~gail.isposint(out_param.mmin) || ~(out_param.mmin < out_param.mmax+1))
    warning('MATLAB:cubLattice_g:lowmmin',['The minimum starting exponent ' ...
            'should be an integer greater than 0 and smaller or equal than the maxium.' ...
            ' Using default mmin ' num2str(default.mmin)])
    out_param.mmin = default.mmin;
end

% Force exponent budget number of points be a positive integer greater than
% or equal to mmin an smaller than 27
if ~(gail.isposint(out_param.mmax) && out_param.mmax>=out_param.mmin && out_param.mmax<=26)
    warning('MATLAB:cubLattice_g:wrongmmax',['The maximum exponent for the budget should be an integer smaller or equal to 27.' ...
            ' Using default mmax ' num2str(default.mmax)])
    out_param.mmax = default.mmax;
end

% Force fudge factor to be greater than 0
if ~((gail.isfcn(out_param.fudge) && (out_param.fudge(1)>0)))
    warning('MATLAB:cubLattice_g:fudgenonpos',['The fudge factor should be a positive function.' ...
            ' Using default fudge factor ' func2str(default.fudge)])
    out_param.fudge = default.fudge;
end

% Force transform to only be id, Baker, C0, C1 or C1sin
if ~(strcmp(out_param.transform,'id') || strcmp(out_param.transform,'Baker') || strcmp(out_param.transform,'C0') || strcmp(out_param.transform,'C1') || strcmp(out_param.transform,'C1sin') )
    warning('MATLAB:cubLattice_g:notmeasure',['The periodizing transformations can only be id, Baker, C0, C1 or C1sin.' ...
            ' Using default error tolerance ' num2str(default.transform)])
    out_param.transform = default.transform;
end

% Force toltype to be max or comb
if ~(strcmp(out_param.toltype,'max') || strcmp(out_param.toltype,'comb') )
    warning('MATLAB:cubLattice_g:nottoltype',['The error type can only be max or comb.' ...
            ' Using default toltype ' num2str(default.toltype)])
    out_param.toltype = default.toltype;
end

% Force theta to be in [0,1]
if (out_param.theta < 0) || (out_param.theta > 1)
    warning('MATLAB:cubLattice_g:thetanonunit',['Theta should be chosen in [0,1].' ...
            ' Using default theta ' num2str(default.theta)])
    out_param.theta = default.theta;
end
end