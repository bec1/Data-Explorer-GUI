function [ absimg ] = load_img( file_path, replace_bad_pixels )

%% Description
% file_path -- a complete path to the image, ex: 'H:\user4\matlab\myfile.txt'
% OPTIONAL remove_bad_pixels -- should it replace bad pixels? By default, it is yes (= 1).
% absimg -- log(I_0,I_atoms).

%% Procedure
% Temporarly copy the file to desktop. Figure out is it is .aia or .fits.
% Load the data and compute (I_0 - I_dark) ./ (I_atom - I_dark). Find bad
% pixels (value = 0, nan, inf) and replace with average of surrounding.
% Take the log and delete temporary file. 

%% Set default values
if nargin < 2
    replace_bad_pixels = 1;
end

%% Copy file to desktop
temp_path = fileparts(userpath);
copyfile(file_path,temp_path,'f');
[~,filename,format] = fileparts(file_path); filename = [filename,format]; format = format(2:end);

%% Load .aia image
if (strcmp(format, 'aia'))
    fid=fopen(fullfile(temp_path,filename),'r');
    header=fread(fid,5,'uint8');
    sizes=fread(fid,3,'uint16');
    rows=sizes(1);
    columns=sizes(2);
    I_fin=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_init=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_dark=reshape(fread(fid,rows*columns,'uint16'),columns,rows);
    I_fin=1.0*(I_fin-I_dark);
    I_init=1.0*(I_init-I_dark);
    fclose(fid);
    absimg = I_init ./ I_fin;
end

%% Load .fits image
if (strcmp(format, 'fits'))
    data=fitsread(fullfile(temp_path,filename));
    absimg=(data(:,:,2)-data(:,:,3))./(data(:,:,1)-data(:,:,3));
end

%% Delete the temporary desktop file
delete(fullfile(temp_path,filename));

%% Replace "bad" pixels with the average of surrounding
if replace_bad_pixels
    ny=size(absimg,1); nx=size(absimg,2);
    burnedpoints = absimg <= 0;
    infpoints = abs(absimg) == Inf;
    nanpoints = isnan(absimg);
    Change=or(or(burnedpoints,infpoints),nanpoints);
    NChange=not(Change);
    for i=2:(ny-1)
        for j=2:(nx-1)
            if Change(i,j)
                n=0;
                rp=0;
                if NChange(i-1,j)
                    rp=rp+absimg(i-1,j);
                    n=n+1;
                end
                if NChange(i+1,j)
                    rp=rp+absimg(i+1,j);
                    n=n+1;
                end
                if NChange(i,j-1)
                    rp=rp+absimg(i,j-1);
                    n=n+1;
                end
                if NChange(i,j+1)
                    rp=rp+absimg(i,j+1);
                    n=n+1;
                end
                if (n>0)
                    absimg(i,j)=(rp/n);
                    Change(i,j)=0;
                end
            end
        end
    end
    absimg(Change)=1;
end

%% Compute the absimg
absimg = log(absimg);

end

