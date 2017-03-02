function [mean_array, thresh_array, fraction_array] = mdx_multi_thresh(directory)
%% Read in image
cd(directory);
gfp_files = dir('*GFP.tif');
for n = 1:size(gfp_files,1)
    filename = gfp_files(n).name;
    %open image with tif3dread
    im = tif3Dread(filename);
    %convert image to double
    imdbl = double(im);
    %% Generate MIP
    %create a max-projection of the image (mip)
    mip = max(imdbl,[],3);
    %% Normalize image
    %set min pixel to zero
    norm_mip = mip - min(mip(:));    
    %set max pixel to one
    norm_mip = norm_mip/max(mip(:));
    %% Calc %pixel below threshold at multiple thresholds
    %thresh array
    thresh_array = 0:0.01:1;
    for i = 1:size(thresh_array,2)
        %get binary image BELOW threshold
        im_bin = norm_mip < thresh_array(i);
        fraction_array(n,i) = sum(im_bin(:))/length(im_bin(:)); 
    end
end
%calculate mean of fraction_array by row
mean_array = mean(fraction_array);
%plot the mean_array vs thresh_array
plot(thresh_array, mean_array);
xlabel('Threshold of Intensity');
ylabel('Fraction Pixels < Threshold');
