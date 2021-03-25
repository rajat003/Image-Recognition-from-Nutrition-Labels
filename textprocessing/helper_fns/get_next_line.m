
function line = get_next_line(fid)

    line = '';
    stopgap_reached = 0;
    while ~stopgap_reached || isempty(line) || sum(isletter(line)) == 0
        newline = fgets(fid);
        while isempty(newline(1:end-1))
            newline = fgets(fid);
            if ~ischar(newline), return; end;
        end
        if strcmp(newline(1:end-1), stopgap())
            stopgap_reached = 1;
        else
            stopgap_reached = 0;
            line = [line newline];
            if length(line) > 30, return; end;
        end
    end