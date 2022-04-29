classdef StringValidator < BaseValidator
    % Used for validating input strings. The list of allowed strings is set
    % using the rangeString which can be a comma separated list of names or
    % a speccial symbol such ass %LDAP, %LINENAME, $EFFECTOR. 
    
    properties
        allowedStrings = '';
        rangeType = 'none';
        autoSelect = false;
    end
   
    methods
        
        function self = StringValidator(rangeString,autoSelect)
            % Class constructor.
            if nargin > 0
                self.setRange(rangeString);
            end
            if nargin > 1
                self.autoSelect = autoSelect;
            else
                self.autoSelect = false;
            end
        end
        
        function set.autoSelect(self,value)
            %fprintf('setting autoSelect, old %d, new %d, %s\n',self.autoSelect, value, self.rangeType); 
            self.autoSelect = value;
        end
        
        function setRange(self,rangeString)
            % Parse range string to get cell array of allowed strings.
            if isempty(rangeString)
                % Range String is empty - this means allow anything.
                self.allowedStrings = '';   
                self.rangeType = 'none';
            else
                % Based on first character of range string determine is this is
                % a list of stings or a special case
                rangeString = strtrim(rangeString);
                firstChar = rangeString(1);
                switch firstChar
                    case '$'
                        self.setRangeSpecialCase(rangeString);
                    otherwise
                        self.setRangeSelectList(rangeString);
                end
            end
        end
        
        function setRangeSelectList(self,rangeString)
            % Parse range string for assuming it is a list of strings 
            % speparated by commas.
            self.rangeType = 'selectList';
            if isempty(rangeString)
                self.allowedStrings = '';
            end
            
            % Parse range string
            commaPos = findstr(rangeString,',');
            stringPos = [0, commaPos, length(rangeString)+1];
            self.allowedStrings = {};
            for i = 1:(length(stringPos)-1)
                n1 = stringPos(i) + 1;
                n2 = stringPos(i+1) - 1;
                if (n1 > n2) 
                    if (i==length(stringPos)-1)
                        % Allow trailing comma in list.
                        continue
                    else
                        error('unable to parse range string');
                    end
                end
                word = rangeString(n1:n2);
                word = strtrim(word);
                self.allowedStrings{i} = word;
            end
        end
        
        function setRangeSpecialCase(self,rangeString)
            % Parse range srting for special cases.
            switch upper(rangeString)
                case '$LDAP'
                    LDAPNames = StringValidator.LDAPNamesCache('get');
                    if isempty(LDAPNames)
                        self.setLDAPNames();
                        LDAPNames = StringValidator.LDAPNamesCache('get');
                    end
                    self.allowedStrings = LDAPNames;
                    
                case '$LINENAME'
                    lineNames = StringValidator.lineNamesCache('get');
                    if isempty(lineNames)
                        self.setLineNames();
                        lineNames = StringValidator.lineNamesCache('get');
                    end
                    self.allowedStrings = lineNames;
                          
                case '$LINENAME_MONTHLY'
                    lineNamesMonthly = StringValidator.lineNamesMonthlyCache('get');
                    if isempty(lineNamesMonthly)
                       self.setLineNamesMonthly();
                       lineNamesMonthly = StringValidator.lineNamesMonthlyCache('get');
                    end
                    self.allowedStrings = lineNamesMonthly;
                    
                case '$EFFECTOR'
                    effectorNames = StringValidator.effectorNamesCache('get');
                    if isempty(effectorNames)
                        self.setEffectorNames();
                        effectorNames = StringValidator.effectorNamesCache('get');
                    end
                    self.allowedStrings = effectorNames;
                    
                case '$FLYPARENT'
                    flyParentNames = StringValidator.flyParentNamesCache('get');
                    if isempty(flyParentNames)
                        self.setFlyParentNames();
                        flyParentNames = StringValidator.flyParentNamesCache('get');
                    end
                    self.allowedStrings = flyParentNames;                    
                    
                otherwise
                    error('unknown special case range string');
            end 
            self.rangeType = rangeString;
        end
        
        function [value, flag, msg] = validationFunc(self,value)
            % Apply validation function to given value.
            
            if isempty(value)
                % Value is empty - return true. Only apply validatation if
                % the user actually sets a value.
                flag = true;
                msg = '';
                return;
            end
            
            if isempty(self.allowedStrings)
                % Empty allowed strings means we allow anything.
                flag = true;
                msg = '';
                return;
            end
            
            % Check that value is in allow strings.
            flag = false;
            msg = 'validation error: sting not found';
            for i = 1:length(self.allowedStrings)
                if strcmp(value,self.allowedStrings{i})
                    flag = true;
                end
            end
        end
        
        function value = getValidValue(self)
            % Return a valid value. If allowedStrings is empty any string
            % is allowed so we just return the empty string. Otherwise the
            % first string in the list of allowed values is returned.
            if isempty(self.allowedStrings)
                value = '';
            else
                value = self.allowedStrings{1};
            end
        end
        
        function numValues = getNumValues(self)
            % Return number of possible values
           if self.isFiniteRange() == true
               numValues = length(self.allowedStrings);
           else
               numValues = Inf;
           end
        end
        
        function valueArray = getValues(self)
            % Returns valid values or empty array 
            if self.isFiniteRange() == true
                valueArray = self.allowedStrings;
            else
                valueArray = {};
            end
        end
        
        function test = isFiniteRange(self)
            % Returns true if there is finite list of allowed strings.
            if isempty(self.allowedStrings)
                test = false;
            else
                test = true;
            end
        end
        
        function setLineNames(self)
            cacher = SAGEDataCacher();
            try
                lineNames = cacher.readLineNamesFile();  
            catch ME
                warning( ...
                    'StringValidator unable to read linenames file: %s', ...
                    ME.message ...
                    );
                lineNames = dummyGetLineNames();
            end
            StringValidator.lineNamesCache('set', lineNames);
        end
        
        function setLineNamesMonthly(self)
            cacher = SAGEDataCacher();
            try
                lineNamesMonthly = cacher.readLineNamesMonthlyFile();
            catch ME
                warning( ...
                    'StringValidator unable to read monthly linenames file: %s', ...
                    ME.message ...
                    );
                lineNamesMonthly = dummyGetLineNames();
            end
            StringValidator.lineNamesMonthlyCache('set', lineNamesMonthly);   
        end
        
        function setEffectorNames(self)
            cacher = SAGEDataCacher();
            try
                effectorNames = cacher.readEffectorsFile();     
            catch ME
                warning( ...
                    'StringValidator unable to read effectors file: %s', ...
                    ME.message ...
                    );
                effectorNames = dummyGetEffectors();
            end   
            StringValidator.effectorNamesCache('set', effectorNames);
        end
        
        function setFlyParentNames(self)
            cacher = SAGEDataCacher();
            try
                flyParentNames = cacher.readFlyParentFile();     
            catch ME
                warning( ...
                    'StringValidator unable to read effectors file: %s', ...
                    ME.message ...
                    );
                flyParentNames = dummyGetLineNames();
            end   
            StringValidator.flyParentNamesCache('set', flyParentNames);
        end        
        
        function setLDAPNames(self)
            cacher = SAGEDataCacher();
            try
                LDAPNames = cacher.readLDAPFile();     
            catch ME
                warning( ...
                    'StringValidator unable to read ldap file: %s', ...
                    ME.message ...
                    );
                LDAPNames = dummyGetLDAP();
            end   
            StringValidator.LDAPNamesCache('set', LDAPNames);
        end
            
    end
    
    methods (Static)
        
        function rval = lineNamesCache(cmd, newLineNames)
            % Provides a cache for the linenames
            persistent lineNames;
            rval = [];
            switch lower(cmd)
                case 'get'
                    rval = lineNames;
                case 'set'
                    lineNames = newLineNames;
            end
        end
        
        function rval = lineNamesMonthlyCache(cmd, newLineNamesMonthly)
           % Provides a cache for monthly line names
           persistent lineNamesMonthly;
           rval = [];
           switch lower(cmd)
               case 'get'
                   rval = lineNamesMonthly;
               case 'set'
                   lineNamesMonthly = newLineNamesMonthly;
           end
        end
        
        function rval = effectorNamesCache(cmd, newEffectorNames)
            % Provides a cache for the effector names
            persistent effectorNames;
            rval = [];
            switch lower(cmd)
                case 'get'
                    rval = effectorNames;
                case 'set'
                    effectorNames = newEffectorNames;
            end
        end
        
        function rval = flyParentNamesCache(cmd, newFlyParentNames)
            % Provides a cache for the effector names
            persistent flyParentNames;
            rval = [];
            switch lower(cmd)
                case 'get'
                    rval = flyParentNames;
                case 'set'
                    flyParentNames = newFlyParentNames;
            end
        end
        
        function rval = LDAPNamesCache(cmd, newLDAPNames)
           % Provides a cache for the ldap names
           persistent LDAPNames;
           rval = [];
           switch lower(cmd)
                case 'get'
                    rval = LDAPNames;
                case 'set'
                    LDAPNames = newLDAPNames;
           end     
        end
        
    end
end

% Dummy functions for development -----------------------------------------
function names = dummyGetLDAP()
% Dummy function for getting LDAP names.
names = {};
N = 10;
for i = 1:N
    names{i} = sprintf('ldap_user_%d', i);
end
end

% -------------------------------------------------------------------------
function names = dummyGetLineNames()
% Dummy function for getting line names
names = {};
N = 20;
for i = 1:N
    names{i} = sprintf('line_%d', i);
end
names{N+1} = 'dummyline';

end

% -------------------------------------------------------------------------
function names = dummyGetEffectors()
% Dummy function for getting line names
names = {};
N = 20;
for i = 1:N
    names{i} = sprintf('effector_%d', i);
end
names{N+1} = 'dummyeffector';
end


