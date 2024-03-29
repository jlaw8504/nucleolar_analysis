function [miparray, mipsub_int, mipsub_max,angle_mat,displacement_mat,morph_cell] = cdc14_area_int_pole_morph(directory, phase)
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
    
    %% find the area of both binaries
    miparea = regionprops(mipbin2,'area');
    %     biparea = regionprops(bipbin2,'area');
    miparea = sum(cat(1,miparea.Area));
    %     biparea = sum(cat(1,biparea.Area));
    %% Find the orienation of mipbin2
    mipangle = regionprops(mipbin2,'Orientation');
    if strcmpi(str,'Y') == 1
        %prompt user to define shape
        prompt_morph = 'Classify shape [arch/bar/2spots/other]:';
        str_morph = input(prompt_morph,'s');
        morph_cell{mipcount,1} = str_morph;
        morph_cell{mipcount,2} = mip;
        close;
        %% Run pole angle program
        [angle,stats] = pole_angles(rfp_files(n).name, phase);
        %% Find smallest dist from binary to pole centroid
        %only do this if angle is not nan, meaning the funciton
        %pole_angle.m was able to find two objects
        if isnan(angle) == 0
            %find all the 1's in the binary mipbin2
            inds = find(mipbin2);
            %convert the linear index to a coordinate index
            [I,J] = ind2sub(size(mipbin2),inds);
            coords = [I,J];
            %parse the centroid information from the two poles
            disp1(:,1) = coords(:,1) - stats(1).Centroid(:,1);
            disp1(:,2) = coords(:,2) - stats(1).Centroid(:,2);
            disp2(:,1) = coords(:,1) - stats(2).Centroid(:,1);
            disp2(:,2) = coords(:,2) - stats(2).Centroid(:,2);
            %find the minimum distance of the rDNA binary to each of the
            %centroid binaries
            min_disp(1)= min(arrayfun(@(x) norm(disp1(x,:)),1:size(disp1,1)));
            min_disp(2)= min(arrayfun(@(x) norm(disp2(x,:)),1:size(disp2,1)));
            %find the smaller of the two displacements
            displacement = min(min_disp);
            clear disp1 disp2 min_disp
        elseif strcmpi(phase,'g1') == 1 && size(stats,1) == 1
            %find all the 1's in the binary mipbin2
            inds = find(mipbin2);
            %convert the linear index to a coordinate index
            [I,J] = ind2sub(size(mipbin2),inds);
            coords = [I,J];
            %parse the centroid information from the single pole
            disp(:,1) = coords(:,1) - stats(1).Centroid(:,1);
            disp(:,2) = coords(:,2) - stats(1).Centroid(:,2);
            displacement= min(arrayfun(@(x) norm(disp(x,:)),1:size(disp,1)));
            clear disp
        else
            displacement = nan;
        end
        %put the measurements into an array indexed by the mipcount counter
        displacement_mat(mipcount,1) = displacement;
        clear displacement
        %Angle of the poles is in the first column
        %Angle of the spherical fit of the rDNA is in the second column
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
        copyfile(RFP,strcat('.',filesep,'selected',filesep,RFP));
        %         copyfile(trans,strcat('.\selected\',trans))
        copyfile(filename,strcat('.',filesep,'selected',filesep,filename));
    else
        display('Discarding...');
    end
end
%take me back to first directory
cd(returndir);