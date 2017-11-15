function r= RMSE( test,ref )
% calculate RMSE for image, given image should be same in size
% test      image to be evaluated
% ref       reference image
diff=test/max(max(abs(test)))-ref/max(max(abs(ref)));
r=sqrt(sum(sum(diff.^2))/size(ref,1)/size(ref,2));
end