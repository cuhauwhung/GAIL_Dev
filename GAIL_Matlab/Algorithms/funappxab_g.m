function [fappx,out_param]=funappxab_g(varargin)
%FUNAPPXAB_G One-dimensional guaranteed function recovery on interval [a,b]
%
%   fappx = FUNAPPXAB_G(f) recovers function f on the default interval
%   [a,b] by a piecewise linear interpolant fappx to within a guaranteed
%   absolute error of 1e-6. Default initial number of points is 52 and
%   default cost budget is 1e7.  Input f is a function handle. The
%   statement y=f(x) should accept a vector argument x and return a vector
%   y of function values that is the same size as x. 
%   
%   fappx = FUNAPPXAB_G(f,a,b,abstol,nlo,nhi,nmax) for given function f and
%   the ordered input parameters with the interval a, b, guaranteed
%   absolute error abstol, lower bound of initial number of points nlo,
%   higher bound of initial number of points nhi and cost budget nmax. nlo
%   and nhi can be inputed as a vector or just one value as initial number
%   of points.
%
%   fappx =
%   FUNAPPXAB_G(f,'a',a,'b',b,'abstol',abstol,'nlo',nlo,'nhi',nhi,'nmax',nmax)
%   recovers function f with the interval a, b, guaranteed
%   absolute error abstol, lower bound of initial number of points nlo,
%   higher bound of initial number of points nhi and cost budget nmax. All
%   six field-value pairs are optional and can be supplied in different
%   order.
%
%   fappx = FUNAPPXAB_G(f,in_param) recovers function f with the interval
%   in_param.a, in_param.b, guaranteed absolute error in_param.abstol,
%   lower bound of initial number of points in_param.nlo, higher bound of
%   initial number of points in_param.nhi and cost budget in_param.nmax. If
%   a field is not specified, the default value is used.
%
%   in_param.a --- left end point of interval, default value is 0
%
%   in_param.b --- right end point of interval, default value is 1
%
%   in_param.abstol --- guaranteed absolute error, default value is 1e-6
%
%   in_param.nlo --- lower bound of initial number of points we used,
%   default value is 52
%
%   in_param.nhi --- higher bound of initial number of points we used,
%   default value is 52
%
%   in_param.nmax --- cost budget, default value is 1e7
%
%   [fappx, out_param] = FUNAPPXAB_G(f,...) returns a function
%   approximation fappx and an output structure out_param, which has the
%   following fields.
%
%
%   out_param.nmax --- cost budget
%
%   out_param.exceedbudget --- it is 0 if the number of points used in the
%   construction of fappx is less than cost budget, 1 otherwise.
%
%   out_param.ninit --- initial number of points we used
%
%   out_param.npoints --- number of points we need to reach the guaranteed
%   absolute error
%
%   out_param.errorbound --- estimation of the approximation absolute error
%   bound
%
%   out_param.nstar --- final value of the parameter defining the cone of
%   function for which this algorithm is guaranteed, nstar = ninit -2
%   initially and is increased as necessary
%
%   out_param.a --- left end point of interval
%
%   out_param.b --- right end point of interval
%
%   out_param.abstol --- guaranteed absolute error
%
%   out_param.nlo --- lower bound of initial number of points we used,
%   default value is 52
%
%   out_param.nhi --- higher bound of initial number of points we used,
%   default value is 52
%
%  Guarantee
%    
%  If the function to be approximated, f satisfies the cone condition
%  \|f''\|_\infty <=
%  \frac{out_param.nstar}{b-a}\|f'-\frac{f(b)-f(a)}{b-a}\|_\infty, then the
%  fappx output by this algorithm is guaranteed to satisfy \| f-fappx
%  \|_{\infty} <= out_param.abstol, provided the flag
%  out_param.exceedbudget = 0. And the upper bound of the cost is \sqrt{
%  \frac{out_param.n^* (out_param.b-out_param.a)^2 \|f''\|_\infty}{2
%  out\_param.abstol}}+2 out_param.n^*+4.
%   
%
%   Examples
%
%   Example 1:
%
%
%   >> f = @(x) x.^2; [fappx, out_param] = funappxab_g(f)
%
%   fappx =
%
%       @(x)interp1(x1,y1,x,'linear')
%
%   out_param = 
% 
%                a: 0
%                b: 1
%           abstol: 1.0000e-06
%              nlo: 52
%              nhi: 52
%             nmax: 10000000
%            ninit: 52
%            nstar: 50
%     exceedbudget: 0
%          npoints: 7039
%       errorbound: 5.0471e-09
%
%
%   Example 2:
%
%   >> f = @(x) x.^2;
%   >> [fappx, out_param] = funappxab_g(f,-2,2,1e-7,10,10,1000000)
% 
%   fappx = 
% 
%         @(x)interp1(x1,y1,x,'linear')
% 
% out_param = 
% 
%                a: -2
%           abstol: 1.0000e-07
%                b: 2
%                f: @(x)x.^2
%              nhi: 10
%              nlo: 10
%             nmax: 1000000
%            ninit: 10
%            nstar: 8
%     exceedbudget: 0
%          npoints: 33733
%       errorbound: 3.5154e-09
%
%
%   Example 3:
%
%   >> f = @(x) x.^2;
%   >> [fappx, out_param] = funappxab_g(f,'a',-2,'b',2,'nhi',100,'nlo',10)
%
%   fappx =
%   
%        @(x)interp1(x1,y1,x,'linear')
% 
%   out_param = 
% 
%                a: -2
%           abstol: 1.0000e-06
%                b: 2
%                f: @(x)x.^2
%              nhi: 100
%              nlo: 10
%             nmax: 10000000
%            ninit: 64
%            nstar: 62
%     exceedbudget: 0
%          npoints: 31249
%       errorbound: 4.0965e-09
%
%
%   Example 4:
%
%   >> clear in_param; in_param.a = -10; in_param.b = 10; 
%   >> in_param.abstol = 10^(-7); in_param.nlo = 10; in_param.nhi = 100;
%   >> in_param.nmax = 10^6; f = @(x) x.^2;
%   >> [fappx, out_param] = funappxab_g(f,in_param)
%
%   fappx =
%   
%        @(x)interp1(x1,y1,x,'linear')
% 
%   out_param = 
% 
%                a: -10
%           abstol: 1.0000e-07
%                b: 10
%                f: @(x)x.^2
%              nhi: 100
%              nlo: 10
%             nmax: 1000000
%            ninit: 90
%            nstar: 88
%     exceedbudget: 0
%          npoints: 590071
%       errorbound: 2.8721e-10
%
%
%   See also INTEGRAL_G, MEANMC_G
%
%   Reference
%   [1]  N. Clancy, Y. Ding, C. Hamilton, F. J. Hickernell, and Y. Zhang,
%        The Cost of Deterministic, Adaptive, Automatic Algorithms:  Cones,
%        Not Balls, Journal of Complexity 30 (2014) 21�45
%

% check parameter satisfy conditions or not
[f, out_param] = funappx_g_param(varargin{:});

%% main algorithm

% initialize number of points
n = out_param.ninit;
% initialize tau
out_param.nstar = n - 2;
% cost budget flag
out_param.exceedbudget = 1;
% tau change flag
tauchange = 0;

while n < out_param.nmax;
    % Stage 1: estimate weaker and stronger norm
    len = out_param.b-out_param.a;
    x = out_param.a:len/(n-1):out_param.b;
    y = f(x);
    diff_y = diff(y);
    %approximate the weaker norm of input function
    gn = (n-1)/len*max(abs(diff_y-(y(n)-y(1))/(n-1)));
    %approximate the stronger norm of input function
    fn = (n-1)^2/len^2*max(abs(diff(diff_y)));
    
    % Stage 2: satisfy necessary condition
    if out_param.nstar*(2*gn+fn*len/(n-1)) >= fn*len;
        % Stage 3: check for convergence
        errbound = 4*out_param.abstol*(n-1)*(n-1-out_param.nstar)...
            /out_param.nstar/len;
        % satisfy convergence
        if errbound >= gn;
            out_param.exceedbudget = 0; break;
        end;
        % otherwise increase number of points
        m = max(ceil(1/(n-1)*sqrt(gn*out_param.nstar*...
            len/4/out_param.abstol)),2);
        n = m*(n-1)+1;
        % Stage2: do not satisfy necessary condition
    else
        % increase tau
        out_param.nstar = fn/(2*gn/len+fn/(n-1));
        % change tau change flag
        tauchange = 1;
        % check if number of points large enough
        if n >= out_param.nstar+2;
            % true, go to Stage 3
            errbound = 4*out_param.abstol*(n-1)*(n-1-out_param.nstar)...
                /out_param.nstar/len;
            if errbound >= gn;
                out_param.exceedbudget = 0; break;
            end;
            m = max(ceil(1/(n-1)*sqrt(gn*out_param.nstar*...
                len/4/out_param.abstol)),2);
            n = m*(n-1)+1;
        else
            % otherwise increase number of points, go to Stage 1
            n = 2 + ceil(out_param.nstar);
        end;
    end;
end;

% Check cost budget flag
if out_param.exceedbudget == 1;
    n = 1 + (n-1)/m*floor((out_param.nmax-1)*m/(n-1));
    warning('MATLAB:funappx_g:exceedbudget','funappx_g attemped to exceed the cost bugdet. The answer may be unreliable.')
end;

if tauchange == 1;
    warning('MATLAB:funappx_g:peaky','This function is peaky relative to nlo and nhi. You may wish to increase nlo and nhi for similiar functions.')
end;
%out_param.ballradius = 2*out_param.abstol*(out_param.nmax-2)*(out_param.nmax...
%    -2-out_param.tau)/out_param.tau;
out_param.npoints = n;
out_param.errorbound = fn*len^2/(8*(n-1)^2);
%out_param.errbound = fn/(8*(n-1)^2);
x1 = out_param.a:len/(out_param.npoints-1):out_param.b;
y1 = f(x1);
fappx = @(x) interp1(x1,y1,x,'linear');

function [f, out_param] = funappx_g_param(varargin)
% parse the input to the funappx_g function

%% Default parameter values

default.abstol = 1e-6;
default.a = 0;
default.b = 1;
default.nlo = 52;
default.nhi = 52;
default.nmax  = 1e7;


if isempty(varargin)
    help funappx_g
    warning('Function f must be specified. Now GAIL is using f(x)=x^2.')
    f = @(x) x.^2;
else
    f = varargin{1};
end;

validvarargin=numel(varargin)>1;
if validvarargin
    in2=varargin{2};
    validvarargin=(isnumeric(in2) || isstruct(in2) ...
        || ischar(in2));
end

if ~validvarargin
    %if only one input f, use all the default parameters
    out_param.a = default.a;
    out_param.b = default.b;
    out_param.abstol = default.abstol;
    out_param.nlo = default.nlo;
    out_param.nhi = default.nhi;
    out_param.nmax = default.nmax;
else
    p = inputParser;
    addRequired(p,'f',@isfcn);
    if isnumeric(in2)%if there are multiple inputs with
        %only numeric, they should be put in order.
        addOptional(p,'a',default.a,@isnumeric);
        addOptional(p,'b',default.b,@isnumeric);
        addOptional(p,'abstol',default.abstol,@isnumeric);
        addOptional(p,'nlo',default.nlo,@isnumeric);
        addOptional(p,'nhi',default.nhi,@isnumeric);
        addOptional(p,'nmax',default.nmax,@isnumeric);
    else
        if isstruct(in2) %parse input structure
            p.StructExpand = true;
            p.KeepUnmatched = true;
        end
        addParamValue(p,'a',default.a,@isnumeric);
        addParamValue(p,'b',default.b,@isnumeric);
        addParamValue(p,'abstol',default.abstol,@isnumeric);
        addParamValue(p,'nlo',default.nlo,@isnumeric);
        addParamValue(p,'nhi',default.nhi,@isnumeric);
        addParamValue(p,'nmax',default.nmax,@isnumeric);
    end
    parse(p,f,varargin{2:end})
    out_param = p.Results;
end;

% let end point of interval not be infinity
if (out_param.a == inf||out_param.a == -inf)
    warning(['a can not be infinity. Use default a = ' num2str(default.a)])
    out_param.a = default.a;
end;
if (out_param.b == inf||out_param.b == -inf)
    warning(['b can not be infinity. Use default b = ' num2str(default.b)])
    out_param.b = default.b;
end;

% let error tolerance greater than 0
if (out_param.abstol <= 0 )
    warning(['Error tolerance should be greater than 0.' ...
        ' Using default error tolerance ' num2str(default.abstol)])
    out_param.abstol = default.abstol;
end
% let initial number of points be a positive integer
if (length(out_param.nlo) == 2)
    out_param.nmax = out_param.nhi;
    out_param.nhi = out_param.nlo(2);
    out_param.nlo = out_param.nlo(1);
elseif (length(varargin) == 6)
    out_param.nmax = out_param.nhi;
    out_param.nhi = out_param.nlo;
end;

if (out_param.nlo > out_param.nhi)
    warning(['Lower bound of initial number of points is larger than upper'...
        ' bound of initial number of points, exchange these two' ])
    temp = out_param.nlo;
    out_param.nlo = out_param.nhi;
    out_param.nhi = temp;
end;
if (~isposint(out_param.nlo))
    if isposge3(out_param.nlo)
        warning('MATLAB:funappx_g:lowinitnotint',['Lower bound of initial number of points should be a positive integer.' ...
            ' Using ', num2str(ceil(out_param.nlo))])
        out_param.nlo = ceil(out_param.nlo);
    else
        warning('MATLAB:funappx_g:lowinitlt3',['Lower bound of initial number of points should be a positive integer.' ...
            ' Using default number of points ' int2str(default.nlo)])
        out_param.nlo = default.nlo;
    end
end
if (~isposint(out_param.nhi))
    if isposge3(out_param.nhi)
        warning('MATLAB:funappx_g:hiinitnotint',['Higher bound of initial number of points should be a positive integer.' ...
            ' Using ', num2str(ceil(out_param.nhi))])
        out_param.nhi = ceil(out_param.nhi);
    else
        warning('MATLAB:funappx_g:hiinitlt3',['Higher bound of points should be a positive integer.' ...
            ' Using default number of points ' int2str(default.nhi)])
        out_param.nhi = default.nhi;
    end
end

h = out_param.b - out_param.a;
out_param.ninit = ceil(out_param.nhi*(out_param.nlo/out_param.nhi)^(1/(1+h)));
% let cost budget be a positive integer
if (~isposint(out_param.nmax))
    if ispositive(out_param.nmax)
        warning('MATLAB:funappx_g:budgetnotint',['Cost budget should be a positive integer.' ...
            ' Using cost budget ', num2str(ceil(out_param.nmax))])
        out_param.nmax = ceil(out_param.nmax);
    else
        warning('MATLAB:funappx_g:budgetisneg',['Cost budget should be a positive integer.' ...
            ' Using default cost budget ' int2str(default.nmax)])
        out_param.nmax = default.nmax;
    end;
end
