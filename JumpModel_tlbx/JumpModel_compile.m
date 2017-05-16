%% Run to compile the functions of the toolbox 

fun='solve_analit';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
p = coder.typeof(0,[1,1]);
m = coder.typeof(0,[1,1]);
y= coder.typeof(0,[inf,inf]);
X= coder.typeof(0,[inf,inf]);
K= coder.typeof(0,[1,1]);
s= coder.typeof(0,[inf,inf]);
gamma = coder.typeof(0,[1,1]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{p, m, y, X, K, s, gamma},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='filling_graph3';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
T = coder.typeof(0,[1,1]);
y= coder.typeof(0,[inf,inf]);
X= coder.typeof(0,[inf,inf]);
K= coder.typeof(0,[1,1]);
theta= coder.typeof(0,[inf,inf,inf]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, y, X, K, theta},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='costEvaluation2';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
T = coder.typeof(0,[1,1]);
K = coder.typeof(0,[1,1]);
y= coder.typeof(0,[inf,inf]);
X= coder.typeof(0,[inf,inf]);
theta= coder.typeof(0,[inf,inf,inf]);
s= coder.typeof(0,[inf,inf]);
lambda = coder.typeof(0,[inf,1]);
gamma = coder.typeof(0,[1,1]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, K, y, X, theta, s, lambda, gamma},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='dp_path';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
T = coder.typeof(0,[1,1]);
K = coder.typeof(0,[1,1]);
l = coder.typeof(0,[inf,inf]);
lambda = coder.typeof(0,[inf,inf]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{T, K, l, lambda},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='probabilistic_clusteringRec';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
Y = coder.typeof(0,[inf,inf]);
X = coder.typeof(0,[inf,inf]);
s = coder.typeof(0,[1,1]);
w = coder.typeof(0,[inf,inf,inf]);
variance = coder.typeof(0,[inf,inf]);
invS = coder.typeof(0,[inf,inf]);
alpha_update =coder.typeof(0,[inf,inf]);
Pi = coder.typeof(0,[inf,inf]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, w, variance,invS,alpha_update, Pi},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='probabilistic_clustering';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
Y = coder.typeof(0,[inf,inf]);
X = coder.typeof(0,[inf,inf]);
s = coder.typeof(0,[1,1]);
w = coder.typeof(0,[inf,inf,inf]);
variance = coder.typeof(0,[inf,inf]);
alpha_update =coder.typeof(0,[inf,inf]);
Pi = coder.typeof(0,[inf,inf]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, w, variance, alpha_update, Pi},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='multi_rlsRec';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
Y = coder.typeof(0,[inf,inf]);
X = coder.typeof(0,[inf,inf]);
s = coder.typeof(0,[1,1]);
lambda = coder.typeof(0,[1,1]);
w0 = coder.typeof(0,[inf,inf,inf]);
iR = coder.typeof(0,[inf,inf,inf,inf]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, lambda,w0,iR},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

fun='multi_rls';
Cfg = coder.config('mex');
Cfg.DynamicMemoryAllocation='AllVariableSizeArrays';
Cfg.IntegrityChecks = false;
Cfg.ResponsivenessChecks = false;
Cfg.SaturateOnIntegerOverflow = false;
Y = coder.typeof(0,[inf,inf]);
X = coder.typeof(0,[inf,inf]);
s = coder.typeof(0,[1,1]);
lambda = coder.typeof(0,[1,1]);
init = coder.typeof(0,[1,1]);
outputFileName = [fun '_mex'];
codegen('-config',Cfg,fun,'-o',outputFileName,'-args',{Y, X, s, lambda, init},...
    '-d', fullfile(tempdir,'mpc','mex',fun,computer('arch')));

clear all

