function n_vctr = n_vctr(in1,in2)
%N_VCTR
%    N_VCTR = N_VCTR(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    28-Nov-2019 15:41:33

thta = in1(2,:);
thta_d = in2(2,:);
t2 = sin(thta);
n_vctr = [t2.*thta_d.^2.*(-3.0./2.0e1);t2.*(-1.4715)];
