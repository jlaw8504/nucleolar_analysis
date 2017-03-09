%This script uses the mdx_multi_thresh.m to measure the intensity profile
%of cdc14-GFP images.  Images are scaled such that the min pixel of the
%maximum intensity projection is set 0 and the brightest pixel is set to 1.
%Method is derived from Maddox et al, 2006, PNAS.

%% Bloom server directories
%make the code compatible to with Mac and PC
if ispc == 1
    wt_split.dir = 'Z:\Alyssa\Split rDNA and WT Selected Images for Caitlin\Split rDNA';
    brn1d9_split_24c.dir = 'Z:\Alyssa\Split rDNA and WT with brn1-9\At 24\Split with brn1-9\Selcted G1 Cells';
    brn1d9_split_37c.dir = 'Z:\Alyssa\Split rDNA and WT with brn1-9\At 37\Split rDNA with brn1-9\G1 Selected regions\selected';
else
    wt_split.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT Selected Images for Caitlin/Split rDNA';
    brn1d9_split_24c.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT with brn1-9/At 24/Split with brn1-9\Selcted G1 Cells';
    brn1d9_split_37c.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT with brn1-9/At 37/Split rDNA with brn1-9\G1 Selected regions\selected';
end

%% Split rDNA loci, G1 cells
[wt_split.mean, wt_split.thresh, wt_split.var, wt_split.fraction,wt_split.area] = mdx_multi_thresh(wt_split.dir);
[brn1d9_split_24c.mean, brn1d9_split_24c.thresh, brn1d9_split_24c.var, brn1d9_split_24c.fraction,brn1d9_split_24c.area] = mdx_multi_thresh(brn1d9_split_24c.dir);
[brn1d9_split_37c.mean, brn1d9_split_37c.thresh, brn1d9_split_37c.var, brn1d9_split_37c.fraction,brn1d9_split_37c.area] = mdx_multi_thresh(brn1d9_split_37c.dir);

%% Plot the mean area vs threshold values with error bars
figure;
errorbar(wt_split.thresh,mean(wt_split.area),std(wt_split.area)/sqrt(size(wt_split.area,1)),'-o')
hold on;
errorbar(brn1d9_split_24c.thresh,mean(brn1d9_split_24c.area),std(brn1d9_split_24c.area)/sqrt(size(brn1d9_split_24c.area,1)),'-o')
errorbar(brn1d9_split_37c.thresh,mean(brn1d9_split_37c.area),std(brn1d9_split_37c.area)/sqrt(size(brn1d9_split_37c.area,1)),'-o')
hold off;
xlabel('Threshold of Intensity');
ylabel('Mean Normalized Area');
legend('WT','brn1-9 24 C', 'brn1-9 37 C');
title('G1, Split rDNA');

% %% Plot the mean fraction vs threshold values
% figure;
% plot(wt_split.thresh,wt_split.mean);
% hold on;
% plot(brn1d9_split_24c.thresh,brn1d9_split_24c.mean);
% plot(brn1d9_split_37c.thresh,brn1d9_split_37c.mean);
% hold off;
% xlabel('Threshold of Intensity');
% ylabel('Mean Fraction Pixels < Threshold');
% legend('WT','brn1-9 24 C', 'brn1-9 37 C');
% title('G1, Split rDNA');
% 
% %% Plot the mean variance of pixel above thresh vs threshold values
% figure;
% plot(wt_split.thresh,mean(wt_split.var,'omitnan'));
% hold on;
% plot(brn1d9_split_24c.thresh,mean(brn1d9_split_24c.var,'omitnan'));
% plot(brn1d9_split_37c.thresh,mean(brn1d9_split_37c.var,'omitnan'));
% hold off;
% xlabel('Threshold of Intensity');
% ylabel('Variance of pixels >= threshold');
% legend('WT','brn1-9 24 C', 'brn1-9 37 C');
% title('G1, Split rDNA');

%% Plot the mean fraction vs threshold values with error bars
figure;
errorbar(wt_split.thresh,wt_split.mean,std(wt_split.fraction)/sqrt(size(wt_split.fraction,1)),'-o')
hold on;
errorbar(brn1d9_split_24c.thresh,brn1d9_split_24c.mean,std(brn1d9_split_24c.fraction)/sqrt(size(brn1d9_split_24c.fraction,1)),'-o')
errorbar(brn1d9_split_37c.thresh,brn1d9_split_37c.mean,std(brn1d9_split_37c.fraction)/sqrt(size(brn1d9_split_37c.fraction,1)),'-o')
hold off;
xlabel('Threshold of Intensity');
ylabel('Mean Fraction Pixels < Threshold');
legend('WT','brn1-9 24 C', 'brn1-9 37 C');
title('G1, Split rDNA');

%% Plot the mean variance of pixel above thresh vs threshold values with error bars
figure;
errorbar(wt_split.thresh,mean(wt_split.var,'omitnan'),std(wt_split.var,'omitnan')/sqrt(size(wt_split.var,1)),'-o')
hold on;
errorbar(brn1d9_split_24c.thresh,mean(brn1d9_split_24c.var,'omitnan'),std(brn1d9_split_24c.var)/sqrt(size(brn1d9_split_24c.var,1)),'-o')
errorbar(brn1d9_split_37c.thresh,mean(brn1d9_split_37c.var,'omitnan'),std(brn1d9_split_37c.var)/sqrt(size(brn1d9_split_37c.var,1)),'-o')
hold off;
xlabel('Threshold of Intensity');
ylabel('Variance of pixels >= threshold');
legend('WT','brn1-9 24 C', 'brn1-9 37 C');
title('G1, Split rDNA');

%% Subplot of WT vs brn1d9 normalized images
%loop through the directories
dir_cell = {wt_split.dir,brn1d9_split_24c.dir,brn1d9_split_37c.dir};
for j = 1:length(dir_cell)
    cd(dir_cell{j});
    gfp_files = dir('*GFP.tif');
    for i = 1:5
        filename = gfp_files(i).name;
        %open image with tif3dread
        im = tif3Dread(filename);
        %convert image to double
        imdbl = double(im);
        %% Generate MIP
        %create a max-projection of the image (mip)
        mip = max(imdbl,[],3);
        %% Normalize image
        %set min pixel to zero
        sub_mip = mip - min(mip(:));
        %set max pixel to one
        norm_mip = sub_mip/max(sub_mip(:));
        %subplot the image
        if j == 1 && i == 1
            figure;
            jet = colormap('jet');
        end
        subplot(3,5,i+((j-1)*5))
        imshow(norm_mip,[],'Colormap',jet)
        if j == 1
            title('WT')
        elseif j == 2
            title('brn1-9 24C')
        elseif j == 3
            title('brn1-9 37C')
        end
    end
end
