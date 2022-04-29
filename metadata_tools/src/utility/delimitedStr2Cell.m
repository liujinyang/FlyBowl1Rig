function outCell = delimitedStr2Cell(inStr, delimiter)
% delimitedStr2Cell: Converts a string with the given delimiter into a cell 
% array
if ~ischar(inStr)
    error('input string, inStr, must be a character array')
end
inStrSize = size(inStr);
if length(inStr) > 0 && inStrSize(1) ~= 1 
    error('input string, inStr, must be 1xN array');
end
remain = inStr;
cnt = 0;
outCell = {};
while ~isempty(remain)
    [token, remain] = strtok(remain, delimiter);
    token = strtrim(token);
    if ~isempty(token)
        cnt = cnt + 1;
        outCell{cnt} = token;
    end
end


