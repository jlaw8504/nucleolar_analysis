function [angle,stats] = pole_angles(filename, phase)
%This function will take a tif stack of a cropped pole images, create a max
%intensity projection, and calculate the angle of the pole to the image
%plane
%Phase is either 'g1' or 'meta'. 'g1' has one pole and will retrun NAN for
%angle, 'meta' will have two poles and return angle between -90 and 90
%degrees using regionporps 'Orientation' property

%% Parse image with tif3Dread
%this program used tif3Dread.m from MBL CIAN course
im = tif3Dread(filename);
%convert image to double
im_dbl = double(im);
%% Max intensity projections
im_mip = max(im_dbl,[],3);
% figure;
% imshow(im_mip,[]);
% title('RFP MIP');
%% use median to bg subtract mip
med_mip = median(im_mip(:));
mip_sub = im_mip - med_mip;
% set negative numbers to zero
mip_idx = mip_sub < 0;
mip_sub(mip_idx) = 0;
%% Threshold for binary
%use Otsu
thresh = multithresh(mip_sub);
im_bin = mip_sub > thresh;
% prompt = 'Do you want to fit poles? Y/N [Y]: ';
% str = input(prompt,'s');
% close;
% if isempty(str)
%     str = 'Y';
% end
% if strcmp(str,'Y') == 1
    stats = regionprops(im_bin,'Centroid');
    %if there are 2 objects in stats calculate the angle between their
    %centroids
    %set limit of 10 iterations
    limit = 10;
    i = 1;
    if strcmpi(phase,'g1') == 1
        pole_num = 1;
    elseif strcmpi(phase,'meta') == 1
        pole_num = 2;
    end
    while size(stats,1) ~= pole_num
        mip_redo = im_mip .* im_bin;
        mip_redo(mip_redo == 0) = nan;
        thresh_redo = multithresh(mip_redo);
        im_bin = mip_redo > thresh_redo;
        stats = regionprops(im_bin,'Centroid');
        i = i + 1;
        if limit == i
            disp('Cannot find correct number of objects');
            break;
        end
    end
    %Assign nan to angle if limit was reached
    if i < limit && strcmpi(phase,'meta') == 1
%     figure;
%     imshow(im_bin);
%     title('RFP Binary');
    coord_sub = stats(1).Centroid - stats(2).Centroid;
    angle = atan(coord_sub(1)/coord_sub(2));
    stats = regionprops(im_bin,'Centroid');
    else
        angle = nan;
    end
% else
%     angle = nan;
% end