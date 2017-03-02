%This script uses the mdx_multi_thresh.m to measure the intensity profile
%of cdc14-GFP images.  Images are scaled such that the min pixel of the
%maximum intensity projection is set 0 and the brightest pixel is set to 1.
%Method is derived from Maddox et al, 2006, PNAS.

%% Bloom server directories
%make the code compatible to with Mac and PC
if ispc == 1
    wt_intact.dir = 'Z:\Alyssa\Split rDNA and WT Selected Images for Caitlin\WT';
    brn1d9_intact_24c.dir = 'Z:\Alyssa\Split rDNA and WT with brn1-9\At 24\Background with brn1-9\Images\Selected G1 Cells';
    brn1d9_intact_37c.dir = 'Z:\Alyssa\Split rDNA and WT with brn1-9\At 37\Background with brn1-9\G1 Selected Regions\selected';
else
    wt_intact.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT Selected Images for Caitlin/WT';
    brn1d9_intact_24c.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT with brn1-9/At 24/Background with brn1-9/Images/Selected G1 Cells';
    brn1d9_intact_37c.dir = '/Volumes/BloomLab/Alyssa/Split rDNA and WT with brn1-9/At 37/Background with brn1-9/G1 Selected Regions/selected';
end

%% Intact rDNA loci, G1 cells
