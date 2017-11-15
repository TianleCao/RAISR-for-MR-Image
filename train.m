% used for training phase
clear;
tic
% undersampling rate
R=2;
% patch parameters
patchSize=11;
forwardSize=floor(patchSize/2);
backSize=patchSize-forwardSize-1;
% Hashtable parameters
Qangle=24;
Qstrength=3;
Qcoherence=3;
% Q for storing patch, V for storing ground truth
Q = zeros(patchSize*patchSize,patchSize*patchSize,R*R,Qangle*Qstrength*Qcoherence);
V = zeros(patchSize*patchSize,R*R,Qangle*Qstrength*Qcoherence);
% filter h
h = zeros(patchSize*patchSize,Qangle*Qstrength*Qcoherence);
% load the training data here as image_HR, shape(sx,sy,samples)
% load('image_HR.mat');
for k=1:size(train_HR,3)
 HR=train_HR(:,:,k);
 [H,W]=size(HR);
 LR=imresize(imfilter(HR,fspecial('gaussian'),'same','replicate'),1/R,'bicubic');
 LR=imresize(LR,R);
 % normalization
 HR=HR/max(max(HR));
 LR=LR/max(max(LR));
  for xP = forwardSize+1:H-backSize
    for yP = forwardSize+1:W-backSize
        % fetch a patch
        patch = LR(xP-forwardSize:xP+backSize,yP-forwardSize:yP+backSize);
        % get the features
        [angle,strength,coherence] = HashTable(patch,Qangle,Qstrength,Qcoherence);
        j = angle*Qstrength*Qcoherence+strength*Qcoherence+coherence+1;
        % flatten the patch
        A = reshape(patch,1,size(patch,1)*size(patch,2));
        x = HR(xP,yP);
        % categorize pixel
        t = mod(xP,R)*R+mod(yP,R)+1; 
        % save into the corresponding location of Q and V
        Q(:,:,t,j) = Q(:,:,t,j)+A'*A;
        V(:,t,j) = V(:,t,j)+A'*x;
    end
  end
end
% solve the (ill-conditioned) equation
 for t=1:R*R
    for j=1:Qangle*Qstrength*Qcoherence
        erro=0;
        while(true)
            if(sum(sum(Q(:,:,t,j)))<100)
                break;
            end
            if(det(Q(:,:,t,j))<1)
                erro=erro+1;
                Q(:,:,t,j)=Q(:,:,t,j)+eye(patchSize^2)*sum(sum(Q(:,:,t,j)))*0.000000005;
            else
                 h(:,t,j)=Q(:,:,t,j)\V(:,t,j);
                break;
            end
        end
    end
 end
toc
save('filter.mat','h','patchSize','Qangle','Qstrength','Qcoherence','R');