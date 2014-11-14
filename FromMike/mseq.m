function y=mseq(m);

% m: register length
% one period of m-sequence
% siege auch: http://www.iiit.uni-karlsruhe.de/download/ISVS_M_SEQUENZ.pdf

switch m
  case 2
     gD=[1 1 1]; %primitives Polynom 
  case 3
     gD=[1 0 1 1]; %primitives Polynom 
  case 4
     gD=[1 0 0 1 1];
  case 5
     gD=[1 0 0 1 0 1];
  case 6
     gD=[1 1 0 0 0 0 1];
  case 7
     gD=[1 0 0 1 0 0 0 1];
  case 8 
     gD=[1 0 0 0 1 1 1 0 1];
  case 9
     gD=[1 0 0 0 0 1 0 0 0 1];
  case 10
     gD=[1 0 0 1 0 0 0 0 0 0 1];        %primitive polynom for m=10
  case 11
     gD=[1 0 0 0 0 0 0 0 0 1 0 1];      
  case 12 
     gD=[1 0 0 0 0 0 1 0 1 0 0 1 1];      
  case 13 
     gD=[1 0 0 0 0 0 0 0 0 1 1 0 1 1];      
  case 14
     gD=[1 0 1 0 0 0 0 0 0 0 0 0 1 1 1]; 
  case 15
     gD=[1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1]; %for m=15
  case 16
     gD=[1 0 0 0 1 0 0 0 0 0 0 0 0 1 0 1 1]; 
  case 17
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1];
  case 18
     gD=[1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1];
  case 19
     gD=[1 0 0 0 0 0 1 0 0 0 0 1 0 0 1 1 1 0 0 1];
  case 20
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1];
  case 21
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1];
  case 22
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
  case 23
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1];
  case 24
     gD=[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 1];
end

s=zeros(m,1); % register outputs
s(1)=1;

N=2^m-1;        % Code length
y=zeros(N,1); 

gD(1)=[];

for lf=1:N
  s0=mod(gD*s,2);
  y(lf)=s(m);
  s(2:m)=s(1:m-1);
  s(1)=s0;
end


