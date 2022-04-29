function flyBowl_camera_control(flea3, token, param)

switch token    
    
    case 'preview'
        flea3.disableLogging();
        flea3.startCapture();
        
    case 'start'
        flea3.setVideoFile(param);
        flea3.enableLogging();
        flea3.startCapture();
        
    case 'saveconfig'
        flea3.saveConfiguration(param);
        
    case 'stop'
        flea3.stopCapture(); %camera should be stop before stop the controller.
        
    case 'disconnect'
        flea3.disconnect();
        flea3.closeWindow();
        %delete flea3;
        
    otherwise
        disp('Unknown command for the camera control.')        

end

      


