function [output_folder, output_file] = run_tesseract(input_img_folder, imgname, out_filename, issegmented, reverse)

%  ex: configfile = 'alphanumeric'; % 'allcharconfig';
%  ex: input_img_folder = 'imgs/output_May17/2277';
%  ex: out_filename = 'out.txt'; % 'out_raw';

if nargin < 5
    reverse = 0;
end
% Set tesseract setup and file/folder structure
configdir = 'configs/'; % located in /opt/local/share/tessdata/tessconfigs
configfile = 'alphanumeric'; % located in configdir
tmpbase = 'tmp';

output_folder = input_img_folder;

% Run Tesseract
output_file = [output_folder, '/', out_filename];
system(['rm -f ', output_file]);

if issegmented
    D = dir(input_img_folder);
    n = numel(D);
    nums = zeros(1,n);
    for i = 1:n
        name = lower(D(i).name);
        if numel(name) >= 4 && strcmp(name(end-3:end),'.png')
            nums(i) = str2double(name(1:end-4));
        end
    end
    nums(nums == 0) = [];
    if reverse
        nums = sort(nums, 'descend');
    else
        nums = sort(nums);
    end
    for n = nums
        imgname = [input_img_folder, num2str(n), '.png'];
        system(['tesseract ', imgname, ' ', tmpbase, ' ', ...
            configdir, configfile, ' quiet']);
        
        system(['cat ', tmpbase, '.txt >> ', output_file]);
        system(['echo ', stopgap(), ' >> ', output_file]);
    end
else
    system(['tesseract ', input_img_folder, imgname, ' ', tmpbase, ' ', ...
        configdir, configfile, ' quiet']);
    system(['cat ', tmpbase, '.txt >> ', output_file]);
    system(['echo ', stopgap(), ' >> ', output_file]);
end
