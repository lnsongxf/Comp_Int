function R = Rdy(phi)
  R = [-sin(phi) 0 cos(phi)  0;
          0     1     0     0;
       -cos(phi) 0 -sin(phi) 0;
       0 0 0 1];
end