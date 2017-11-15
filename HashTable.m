function [angle,strength,coherence] = HashTable(patch,Qangle,Qstrength,Qcoherence)
%  match the patch with its HashTable
%  patch       input image patch to be classsfied
%  Qangle      number of classifications for angle
%  Qstrength   number of classifications for strength
%  Qcoherence  number of classifications for coherence
%  angle       classification for angle, range:0 to Qangle-1
%  strength    classification for strngth, range:0 to Qstrength-1
%  coherence   classification for coherence, range:0 to Qcoherence-1
[q1,q2]=gradient(patch);
q1=q1(:);
q2=q2(:);
G=[q1,q2];
G(:,1)=zscore(G(:,1));
G(:,2)=zscore(G(:,2));
GG=G'*G;
[eigenvectors,eigenvalues] = eig(GG);
eigenvalues=diag(eigenvalues);
% angle
angle=atan2(eigenvectors(1,1),eigenvectors(2,1));
if (angle<0) angle=angle+pi;
end
% strength
strength = max(eigenvalues)/(sum(eigenvalues)+0.0001);
% coherence
lambda1=sqrt(max(eigenvalues));
lambda2=sqrt(min(eigenvalues));
coherence = abs((lambda1-lambda2)/(lambda1+lambda2+0.0001));
% quantization
angle = floor(angle/((pi+0.0001)/Qangle));
strength = floor(strength/(1/Qstrength));
coherence = floor(coherence/(1/Qcoherence));    
end