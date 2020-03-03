clc
clear all
close all

% SOLVING ODE

optns = odeset('RelTol',1e-4,'AbsTol',1e-4,'NormControl','on');
tspan = [0, 1];
x_0 = [0; 0; 0.015; 0]; % don't change
[t,x] = ode45( @(t,x)dynamics(t,x),tspan,x_0,optns);


% x3max = ;
x1max = 0.02;
tau = 0.4;
% R = diag([inf; inf; 1/x3max^2; inf]);
x1const = zeros(length(t),1);
SWN = zeros(length(t),1);
Energy = zeros(length(t),1);
for i=1:length(t)
    G = diag([1/(x1max*exp(-t(i,1)/tau))^2; 0; 0; 0]);
    x1const(i,1) = x1max*exp(-t(i,1)/tau);
    SWN(i,1) = x(i,:)*G*(x(i,:)');
end

f1 = figure();
plot(t,SWN);

f2 = figure();
plot(t, x(:,1));
hold on;
plot(t,x(:,3), 'g--');
plot(t, x1const,'r-.', t, -x1const, 'r-.');
legend('x1', 'x3', 'x1_{constr.}')
hold off;


Ks = 50000;
Ku = 200000;
Ms = 320;
Mu = 40;
Bs = 2000;

A = [0 1 0 -1
    -Ks/Ms -Bs/Ms 0 Bs/Ms
     0 0 0 1
     Ks/Mu Bs/Mu -Ku/Mu -Bs/Mu];

x1max = 0.02;
tau = 0.4;
x3max = 0.012;
eps = 1e-6;
N = length(t);

R = diag([1/eps; 1/eps; 1/x3max^2; 1/eps]);
G = diag([1/(x1max*exp(-t(1,1)/tau))^2; eps; eps; eps]);
P_q = zeros(4,4);
G_check = zeros(4*N, 4);
G_check(1:4, 1:4) = G;

cvx_begin sdp
cvx_solver sedumi
cvx_precision best
    variable P(4,4) symmetric
    variable Q(4*N,4)
    subject to
        R - P > 0;
        P - G > 0;
        -Q(1:4,:) - A'*P - P*A > 0;
        P_q = P;
        for i=2:N
            G = diag([1/(x1max*exp(-t(i,1)/tau))^2; eps; eps; eps]);
            G_check(4*(i-1)+1:4*i,:) = G;
            -Q(4*(i-1)+1:4*i,:) - A'*P_q - P_q*A > 0;
            P_q = P_q + (t(i,1)-t(i-1,1))*Q(4*(i-2)+1:4*(i-1),:);
            P_q - G > 0;
            -Q(4*(i-1)+1:4*i,:) - A'*P_q - P_q*A > 0;
            Q(4*(i-1)+1:4*i,:) == Q(4*(i-1)+1:4*i,:)';
        end
        Q(1:4,:) == Q(1:4,:)';
cvx_end

check_DLMI(P, Q, R, G_check, A);