classdef MultiSelectValidator < BaseValidator
    % Used for validating multiselect strings. The list of allowed strings is set
    % using the rangeString which can be a comma separated list of names or
    % a speccial symbol such as $NOTES_KEYWORDS 
   
    properties 
       allowedStrings = '';
    end
    
    properties (Constant)
        delimiter = ',';
    end
    
    methods
        function self = MultiSelectValidator(rangeString)
            if nargin > 0
                self.setRange(rangeString);
            end
        end
        
        function setRange(self,rangeString)   
            % Set the range string for the validator.
            if isempty(rangeString)
                error('multiSelectValidator cannot have empty range string');
            end
            try
                self.checkRangeString(rangeString);
            catch ME
                error('multiSelectValidator: range string format incorrect: %s', ME.message);
            end
          
            rangeString = strtrim(rangeString);
            firstChar = rangeString(1);
            switch firstChar
                case '$'
                    self.setRangeSpecialCase(rangeString);
                otherwise
                    self.allowedStrings = delimitedStr2Cell(rangeString,self.delimiter);
            end
        end
        
        function setRangeSpecialCase(self, rangeString)
            % Set the range string for the validator - handles special
            % cases where the first char is '$'. 
            switch rangeString
                case '$NOTES_KEYWORDS'
                    self.allowedStrings = self.getNotesKeywords();
                otherwise
                    error('multiselectValidator unknown special case string');
            end
        end
        
        function validValue = getValidValue(self)
            % Return a valid value
            validValue = self.allowedStrings{1};
        end
        
        function [value, flag, msg] = validationFunc(self,value)
            % Apply validation function to given value.
            msg = '';
            try
                valueCell = delimitedStr2Cell(value, self.delimiter);
            catch ME
                flag = false;
                msg = ME.message;
                return;
            end
                     
            % Test if all items in valueCell are also in self.allowedValues
            flag = true;
            for i = 1:length(valueCell)
                itemTest = false;
                for j = 1:length(self.allowedStrings)
                    if strcmp(valueCell{i}, self.allowedStrings{j})
                        itemTest = true;
                    end
                end
                if itemTest == false;
                    flag = false;
                    msg = 'multiSelectValidator - item not found in list of allowed values';
                end
            end
        end
        
        function logicalVector = getLogicalVector(self, value)
            % Return logical vector indicating which elements in value are
            % in the list of allowed strings. Note, value is a delimited
            % string of the "values" in allowedValues or possibly empty.
            logicalVector = false(1,length(self.allowedStrings));
            valueCell = delimitedStr2Cell(value,self.delimiter);
            for i = 1:length(self.allowedStrings)
                present = false;
                for j = 1:length(valueCell)
                    if strcmp(self.allowedStrings{i},valueCell{j})
                        present = true;
                    end
                end
                logicalVector(i) = present;
            end
        end
        
        function valueArray = getValues(self)
            % Return cell array of all allowed values. 
            valueArray = self.allowedStrings;
        end
        
        function numValues = getNumValues(self)
            % Returns the number of allowed values. 
            numValues = length(self.allowedStrings);
        end
        
        function checkRangeString(self, rangeString)
            % Try converting the rangeString to a cell ar
            delimitedStr2Cell(rangeString, self.delimiter);
        end
        
        function notesKeywords = getNotesKeywords(self)
            cacher = SAGEDataCacher();
            try
                notesKeywords = cacher.readNotesKeywordsFile();
            catch ME
                warning( ...
                    'MultiSelectValidator unable to read notes_keywords file %s', ...
                    ME.message ...
                    );
                notesKeywords = dummyNotesKeywords();
            end
        end
        
    end
    
end

% -------------------------------------------------------------------------
function notesKeywords = dummyNotesKeywords()
% Generate dummy notes keywords
notesKeywords = {};
for i = 1:20
    notesKeywords{i} = sprintf('notes_keywords_%d', i);
end
end


