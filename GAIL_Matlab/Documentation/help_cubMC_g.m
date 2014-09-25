%% cubMC_g
% |Monte Carlo method to evaluate a multidimensional integral to
% within a specified generalized error tolerance 
% tolfun = max(abstol, reltol|I|) with guaranteed confidence level 1-alpha.|
%% Syntax
% [Q,out_param] = *cubMC_g*(f,hyperbox)
%
% Q = *cubMC_g*(f,hyperbox,measure,abstol,reltol,alpha,fudge,nSig,n1,
%
% Q = *cubMC_g*(f,hyperbox,'measure','uniform','abstol',abstol,'reltol',
%
% [Q out_param] = *cubMC_g*(f,hyperbox,in_param)
%% Description
%
% [Q,out_param] = *cubMC_g*(f,hyperbox) estimates the integral of f over
%  hyperbox to within a specified generalized error tolerance tolfun =
%  max(abstol, reltol|I|) with guaranteed confidence level 99%. Input
%  f is a function handle. The function f should accept an n x d matrix
%  input, where d is the dimension of the hyperbox, and n is the number of
%  points being evaluated simultaneously. The input hyperbox is a 2 x d
%  matrix, where the first row corresponds to the lower limits and the
%  second row corresponds to the upper limits.
% 
% Q = *cubMC_g*(f,hyperbox,measure,abstol,reltol,alpha,fudge,nSig,n1,
%  tbudget,nbudget,checked) estimates the integral of function f over
%  hyperbox to within a specified generalized error tolerance tolfun with
%  guaranteed confidence level 1-alpha using all ordered parsing inputs f,
%  hyperbox, measure, abstol, reltol, alpha, fudge, nSig, n1, tbudget,
%  nbudget, checked. The input f and hyperbox are required and others are
%  optional.
% 
% Q = *cubMC_g*(f,hyperbox,'measure','uniform','abstol',abstol,'reltol',
%  reltol,'alpha',alpha,'fudge',fudge,'nSig',nSig,'n1',n1,'tbudget',
%  tbudget,'nbudget',nbudget,'checked',checked) estimates the integral of
%  f over hyperbox to within a specified generalized error tolerance
%  tolfun with guaranteed confidence level 1-alpha. All the field-value
%  pairs are optional and can be supplied in different order. If an input
%  is not specified, the default value is used.
% 
% [Q out_param] = *cubMC_g*(f,hyperbox,in_param) estimates the integral of
%  f over hyperbox to within a specified generalized error tolerance
%  tolfun with the given parameters in_param and produce output parameters
%  out_param and the integral Q.
% 
% *Input Arguments*
%
% * f --- |the integrand.|
% 
% * hyperbox --- |the integration hyperbox. The default value is
%  [zeros(1,d); ones(1,d)], the default d is 1.|
% 
% * in_param.measure --- |the measure for generating the random variable,
%  the default is uniform. The other measure could be handled is
%  normal/Gaussian.|
% 
% * in_param.abstol --- |the absolute error tolerance, the default value
%  is 1e-2.|
%
% * in_param.reltol --- |the relative error tolerance, the default value
%  is 1e-1.|
% 
% * in_param.alpha --- |the uncertainty, the default value is 1%.|
% 
% * in_param.fudge --- |the standard deviation inflation factor, the
%  default value is 1.2.|
%
% * in_param.nSig --- |initial sample size for estimating the sample
%  variance, the default value is 1e4.|
% 
% * in_param.n1 --- |initial sample size for estimating the sample mean,
%  the default value is 1e4.|
% 
% * in_param.tbudget --- |the time budget to do the estimation, the
%  default value is 100 seconds.|
% 
% * in_param.nbudget --- |the sample budget to do the estimation, the
%  default value is 1e9.|
% 
% * in_param.checked --- |the value corresponds to parameter checking
% status.|
%   
%                      0   not checked
%   
%                      1   checked by meanMC_g
%   
%                      2   checked by cubMC_g
%
% *Output Arguments*
%
% * Q --- |the estimated value of the integral.|
% 
% * out_param.n --- |sample used in each iteration.|
%
% * out_param.ntot --- |total sample used.|
%
% * out_param.tau --- |the iteration step.|
%
% * out_param.mu --- |estimated mean in each iteration|
%
% * out_param.tol --- |the tolerance for each iteration|
%  
% * out_param.kurtmax --- |the upper bound on modified kurtosis.|
% 
% * out_param.time --- |the time elapsed.|
%
% * out_param.exit --- |the state of program when exiting.|
%   
%                    0   success
%   
%                    1   Not enough samples to estimate the mean
%   
%                    2   Initial try out time costs more than
%                        10% of time budget
%   
%                    3   The estimated time for estimating variance 
%                        is bigger than half of the time budget
%   
%                    10  hyperbox does not contain numbers
%   
%                    11  hyperbox not 2 x d
%   
%                    12  hyperbox is only a point in one direction
%   
%                    13  hyperbox is infinite when measure is uniform
%   
%                    14  hyperbox is not doubly infinite when measure
%                        is normal
% 
%  Guarantee
% This algorithm attempts to calculate the integral of function f over a
% hyperbox to a prescribed error tolerance with guaranteed confidence level
% 1-alpha. If the algorithm terminated without showing any warning messages
% and provide an answer Q, then the follow inequality would be satisfied:
% 
% Pr(|Q-I| <= max(abstol,reltol|I|)) >= 1-alpha
%
% where abstol is the absolute error tolerance and reltol is the relative
% error tolerance, if the true integral I is rather small as well as the
% reltol, then the abstol would be satisfied, and vice versa. 
%
% The cost of the algorithm is also bounded above by N_up, which is
% function in terms of abstol, reltol, nSig, n1, fudge, kurtmax, beta. And
% the following inequality holds:
% 
% Pr (N_tot <= N_up) >= 1-beta
%
% Please refer to our paper for detailed arguments and proofs.
% 
%%  Examples
% *Example 1*

% Estimate the integral with integrand f(x) = sin(x) over the interval [1;2]
% 

 f=@(x) sin(x);interval = [1;2];
 Q = cubMC_g(f,interval,'uniform',1e-3,1e-2)
 
%% 
% *Example 2*
% Estimate the integral with integrand f(x) = exp(-x1^2-x2^2) over the
% hyperbox [0 0;1 1], where x is a vector x = [x1 x2].
% 

 f=@(x) exp(-x(:,1).^2-x(:,2).^2);hyperbox = [0 0;1 1];
 Q = cubMC_g(f,hyperbox,'measure','uniform','abstol',1e-3,'reltol',1e-13)

%%
% *Example 3*

% Estimate the integral with integrand f(x) = 2^d*prod(x1*x2*...*xd)+0.555
% over the hyperbox [zeros(1,d);ones(1,d)], where x is a vector 
% x = [x1 x2... xd].
% 

  d=3;f=@(x) 2^d*prod(x,2)+0.555;hyperbox =[zeros(1,d);ones(1,d)];
  in_param.abstol = 1e-3;in_param.reltol=1e-3;
  Q = cubMC_g(f,hyperbox,in_param)

%%
% *Example 4* 

% Estimate the integral with integrand f(x) = exp(-x1^2-x2^2) in the
% hyperbox [-inf -inf;inf inf], where x is a vector x = [x1 x2].
% 

 f=@(x) exp(-x(:,1).^2-x(:,2).^2);hyperbox = [-inf -inf;inf inf];
 Q = cubMC_g(f,hyperbox,'normal',0,1e-2)
%% See Also
%
% <html>
% <a href="help_funappx_g.html">funappx_g</a>
% </html>
%
% <html>
% <a href="help_integral_g.html">integral_g</a>
% </html>
%
% <html>
% <a href="help_meanMC_g.html">meanMC_g</a>
% </html>
%
% <html>
% <a href="help_meanMCBernoulli_g.html">meanMCBernoulli_g</a>
% </html>
%
%% References
%
% [1]  F. J. Hickernell, L. Jiang, Y. Liu, and A. B. Owen, Guaranteed
% conservative fixed width confidence intervals via Monte Carlo sampling,
% Monte Carlo and Quasi-Monte Carlo Methods 2012 (J. Dick, F. Y. Kuo, G. W.
% Peters, and I. H. Sloan, eds.), Springer-Verlag, Berlin, 2014, to appear,
% arXiv:1208.4318 [math.ST]
%
% [2] Sou-Cheng T. Choi, Yuhan Ding, Fred J. Hickernell, Lan Jiang, and
% Yizhi Zhang, "GAIL: Guaranteed Automatic Integration Library (Version
% 1.3.0)" [MATLAB Software], 2014. Available from
% http://code.google.com/p/gail/
%
% If you find GAIL helpful in your work, please support us by citing the
% above paper and software.