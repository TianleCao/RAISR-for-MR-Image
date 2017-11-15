% used for testing phase
clear;
load('filter.mat');
% load the testing data here as image_Test, shape(sx,sy)
% load('image_Test.mat')
ref = image_Test;
[H,W]=size(ref);
LR=imresize(imfilter(ref,fspecial('gaussian'),'same','replicate'),1/R,'bicubic');
LR=imresize(LR,R);
LR=LR/max(max(LR));
forwardSize=floor(patchSize/2);
backSize=patchSize-forwardSize-1;
HR=LR;
for xP = forwardSize+1:H-backSize
    for yP = forwardSize+1:W-backSize
        %ȡpatch
        patch = LR(xP-forwardSize:xP+backSize,yP-forwardSize:yP+backSize);
        % get the features
        [angle,strength,coherence] = HashTable(patch,Qangle,Qstrength,Qcoherence);
        j = angle*Qstrength*Qcoherence+strength*Qcoherence+coherence+1;
        % flatten the patch
        A = reshape(patch,1,size(patch,1)*size(patch,2));
        x = HR(xP,yP);
        % categorize pixel
        t = mod(xP,R)*R+mod(yP,R)+1;
        %get HR
        HR(xP,yP)=A*h(:,t,j);
    end
end
figure;
subplot(1,3,1);imshow(LR,[]);title(sprintf('LR image, RMSE=%f',RMSE(LR,ref)));
subplot(1,3,2);imshow(ref,[]);title('HR image');
subplot(1,3,3);imshow(HR,[]);title(sprintf('RAISR image, RMSE=%f',RMSE(HR,ref)));
% end