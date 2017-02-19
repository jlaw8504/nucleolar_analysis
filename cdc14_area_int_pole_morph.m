function [miparray, mipsub_int, mipsub_max,angle_mat,displacement_mat] = cdc14_area_int_pole_morph(directory)
%% Loop through all GFP files
returndir = pwd;
cd(directory);
gfp_files = dir('*GFP.tif');
rfp_files = dir('*RFP.tif');
% bipcount = 1;
mipcount = 1;
mkdir('selected');
for n = 1:size(gfp_files,1)
    filename = gfp_files(n).name;
    %open image with tif3dread
    im = tif3Dread(filename);
    %convert image to double
    imdbl = double(im);
    %create a max-projection of the image (mip)
    mip = max(imdbl,[],3);
    %select brightest intensity plane (bip)
    [~,idx] = max(imdbl(:));
    [~,~,plane] = ind2sub(size(imdbl),idx);
    bip = imdbl(:,:,plane);
    %% use median to bg subtract bip and mip
    %mip processing
    medmip = median(mip(:));
    mipsub = mip - medmip;
    % set negative numbers to zero
    mipidx = mipsub < 0;
    mipsub(mipidx) = 0;
    %bip processing
    medbip = median(bip(:));
    bipsub = bip - medbip;
    % set negative numbers to zero
    bipidx = bipsub < 0;
    bipsub(bipidx) = 0;
    %% create a binary mask using Otsu threshold (multithresh)
    %mip processing
    mipthresh = multithresh(mipsub);
    mipbin = mipsub > mipthresh;
    %Apply first threshold
    mip2 = mipsub .* mipbin;
    %set 0 values to nan
    mip2(mip2==0) = nan;
    mipthresh2 = multithresh(mip2);
    mipbin2 = mip2 > mipthresh2;
    mipbin2 = imclose(mipbin2,strel('disk',2));
    %bip processing
    bipthresh = multithresh(bipsub);
    bipbin = bipsub > bipthresh;
    %Apply first threshold
    bip2 = bipsub .* bipbin;
    %set 0 values to nan
    bip2(bip2==0) = nan;
    bipthresh2 = multithresh(bip2);
    bipbin2 = bip2 > bipthresh2;
    bipbin2 = imclose(bipbin2,strel('disk',2));
    figure;
    imshow(bip,[]);
    title('Brightest Pixel Plane');
    waitforbuttonpress;
    hold on;
    imshow(mip,[]);
    title('Max Intensity Projection');
    waitforbuttonpress;
    imshow(mipbin2,[]);
    title('Max Intensity Binary');
    prompt = 'Do you want approve? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'Y';
    end
    close;
    
    %% find the area of both binaries
    miparea = regionprops(mipbin2,'area');
    %     biparea = regionprops(bipbin2,'area');
    miparea = sum(cat(1,miparea.Area));
    %     biparea = sum(cat(1,biparea.Area));
    %% Find the orienation of mipbin2
    mipangle = regionprops(mipbin2,'Orientation');
    if strcmpi(str,'Y') == 1
        %% Run pole angle program
        [angle,stats] = pole_angles(rfp_files(n).name);
        %% Find smallest dist from binary to pole centroid
        %only do this if angle is not nan
        if isnan(angle) == 0
            disp('testing');
            inds = find(mipbin2);
            [I,J] = ind2sub(size(mipbin2),inds);
            coords = [I,J];
            disp1 = coords - stats(1).Centroid;
            disp2 = coords - stats(2).Centroid;
            min_disp(1)= min(arrayfun(@(x) norm(disp1(x,:)),1:size(disp1,1)));
            min_disp(2)= min(arrayfun(@(x) norm(disp2(x,:)),1:size(disp2,1)));
            displacement = min(min_disp);
        else
            displacement = nan;
        end
        displacement_mat(mipcount,1) = displacement;
        angle_mat(mipcount,1) = rad2deg(angle);
        angle_mat(mipcount,2) = mipangle.Orientation;
        miparray(mipcount,1) = miparea;
        %% find integrated intensity of the binary using mipsub
        %multiply mipbin2 with mipsub
        mipsub_select = mipbin2.*mipsub;
        mipsub_int(mipcount,1) = sum(mipsub_select(:));
        mipsub_max(mipcount,1) = max(mipsub_select(:));
        mipcount = mipcount + 1;
        display('Saving...');
        %set up variables for RFP and trans
        truncfile = filename(1:(end-7));
        RFP = strcat(truncfile,'RFP.tif');
        trans = strcat(truncfile,'trans.tif');
        copyfile(RFP,strcat('.\selected\',RFP));
        %         copyfile(trans,strcat('.\selected\',trans))
        copyfile(filename,strcat('.\selected\',filename));
    else
        display('Discarding...');
    end
end
%take me back to first directory
cd(returndir);