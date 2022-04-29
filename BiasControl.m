classdef BiasControl < handle
    % BiasControl:  implements the http based control interface used to
    % control the BIAS (Basic Image Acquisition Software). 
    %
    
    properties
        address = '';
        port = [];
    end
    
    properties (Dependent)
        baseUrl;
    end
    
    methods
        
        function self = BiasControl(address, port)
            self.address = address;
            self.port = port;
        end
        
        function rsp = connect(self)
            cmd = sprintf('%s/?connect',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = disconnect(self)
            cmd = sprintf('%s/?disconnect',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = startCapture(self)
            cmd = sprintf('%s/?start-capture',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = stopCapture(self)
            cmd = sprintf('%s/?stop-capture',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getConfiguration(self)
            cmd = sprintf('%s/?get-configuration', self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = setConfiguration(self,config)
            configJson = structToJson(config);
            cmd = sprintf('%s/?set-configuration=%s',self.baseUrl, configJson);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = enableLogging(self)
            cmd = sprintf('%s/?enable-logging',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = disableLogging(self)
            cmd = sprintf('%s/?disable-logging', self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = loadConfiguration(self,fileName)
            cmd = sprintf('%s/?load-configuration=%s',self.baseUrl,fileName);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = saveConfiguration(self,fileName)
            cmd = sprintf('%s/?save-configuration=%s',self.baseUrl,fileName);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getFrameCount(self)
            cmd = sprintf('%s/?get-frame-count',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getCameraGuid(self)
            cmd = sprintf('%s/?get-camera-guid',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getStatus(self)
            cmd = sprintf('%s/?get-status', self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = setVideoFile(self,fileName)
            cmd = sprintf('%s/?set-video-file=%s',self.baseUrl,fileName);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getVideoFile(self)
            cmd = sprintf('%s/?get-video-file',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getTimeStamp(self)
            cmd = sprintf('%s/?get-time-stamp', self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = getFramesPerSec(self)
            cmd = sprintf('%s/?get-frames-per-sec', self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = setCameraName(self,name)
            cmd = sprintf('%s/?set-camera-name=%s',self.baseUrl,name);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = setWindowGeometry(self, geom)
            geomJson = structToJson(geom);
            cmd = sprintf('%s/?set-window-geometry=%s',self.baseUrl,geomJson);
            cmd = cmd(find(~isspace(cmd))); %remove space from the commmand
            rsp = self.sendCmd(cmd);
        end

        function rsp = getWindowGeometry(self)
            cmd = sprintf('%s/?get-window-geometry',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
        
        function rsp = closeWindow(self)
            cmd = sprintf('%s/?close',self.baseUrl);
            rsp = self.sendCmd(cmd);
        end
       
        function baseUrl = get.baseUrl(self)
            baseUrl = sprintf('http://%s:%d',self.address,self.port);
        end
        
        function rsp = initializeCamera(self,varargin)
            %property list: frameRate, movieFormat, ROI, triggerMode
            nVarargs = length(varargin);
            
            switch nVarargs
                case 0
                    frameRate = 50;
                    movieFormat = 'ufmf';
                    ROI = varargin{3};
                    triggerMode = 'Internal';
                case 1
                    frameRate = varargin{1};
                    movieFormat = 'ufmf';
                    ROI = varargin{3};
                    triggerMode = 'Internal';
                case 2
                    frameRate = varargin{1};
                    movieFormat = varargin{2};
                    ROI = [0,0,1280,1024];
                    triggerMode = 'Internal';
                case 3
                    frameRate = varargin{1};
                    movieFormat = varargin{2};
                    ROI = varargin{3};
                    triggerMode = 'Internal';
                otherwise
                    frameRate = varargin{1};
                    movieFormat = varargin{2};
                    ROI = varargin{3};
                    triggerMode = varargin{4};
            end
            
            %connect to the server
            rsp = self.connect();
            
            % Get current configuration
            rsp = self.getConfiguration();
            config = rsp{1}.value;
                            
            % Set frame rate if configuration structure - note to use absolute value
            % asbolute control must be enabled (set to true).
            config.camera.properties.frameRate.absoluteControl = 1;
            config.camera.properties.frameRate.autoActive = 0;
            config.camera.properties.frameRate.absoluteValue = frameRate;
            

            %set movie format
            if strcmp(movieFormat, 'avi')
                config.logging.format = 'avi';
                config.logging.settings.avi.frameSkip = 1;
            elseif strcmp(movieFormat, 'ufmf')
            end
            
            % Set ROI in configuration
            config.camera.format7Settings.roi.offsetX = ROI(1)-rem(ROI(1),8);  %step 8
            config.camera.format7Settings.roi.offsetY = ROI(2)-rem(ROI(2),2);  %step 2
            config.camera.format7Settings.roi.width = ROI(3)-rem(ROI(3),16);   %step 16
            config.camera.format7Settings.roi.height = ROI(4)-rem(ROI(4),2);   %step 2
            
            %trigger mode is either internal or external
            if strncmpi(triggerMode, 'ex', 2)
                config.camera.triggerType = 'External';
            else
                config.camera.triggerType = 'Internal';
            end
            
            % Set new configuration
            rsp = self.setConfiguration(config);
            if rsp{1}.success
                fprintf('ROI set successfully\n');
            else
                fprintf('Error setting ROI %s\n',rsp.message);
            end
        end
        
    end
        
        methods (Access=protected)
            
            function rsp = sendCmd(self, cmd)
                rspString = urlread(cmd);
                rsp = loadjson(rspString);
            end
        end
        
end
    
    function valJson = structToJson(val)
    valJson = savejson('',val);
    valJson = strrep(valJson,sprintf('\n'), '');
    valJson = strrep(valJson,sprintf('\t'), '');
    end