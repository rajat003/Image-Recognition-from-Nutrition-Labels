
% Displays input and writes to file
function display_and_output(input, output, resultsfile, spacer, confidence)

    DISPLAY_OUTPUT = false; % true;
    
    if nargin < 3
        spacer = '..........';
    end
    
    if nargin > 4 && DISPLAY_OUTPUT
        output = [output, ' [', confidence, ' confidence] '];
    end
    
    if DISPLAY_OUTPUT
        disp(['Tesseract Input: ', input(1:end-1)]);
        disp(['Rectified Output: ', output]);
        disp(spacer)
    end
        
    if nargin > 2
        system(['echo ', output, ' >> ', resultsfile]);
        system(['echo ', spacer, ' >> ', resultsfile]);
    end