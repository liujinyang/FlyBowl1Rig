function outStr = cell2delimitedStr(cellArray, delimiter)
% cell2delimitedStr: converts a cell array to a string with the given
% delimiter. 

cellSize = size(cellArray);
if isempty(cellArray)
    outStr = '';
else
    if cellSize(1) ~= 1 && cellSize(2) ~= 1
        error('cell array must be either 1xN or Nx1');
    end
    
    outStr = '';
    for i = 1:length(cellArray)
        value = cellArray{i};
        if ~ischar(value)
            error('cell array values must be strings');
        end
        value = strtrim(value);
        if i == 1
            outStr = sprintf('%s', value);
        else
            outStr = sprintf('%s%s %s', outStr, delimiter, value);
        end
    end
end