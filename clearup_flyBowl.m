function clearup_flyBowl(hComm)

%clearup the camera
try
    for i = 1:4
        if ~(hComm.flea3{i}==0)
            hComm.flea3{i}.stopCapture();
            hComm.flea3{i}.disableLogging();
            hComm.flea3{i}.disconnect();
            hComm.flea3{i}.closeWindow();
        end
    end
    
catch
%catch an error    
end

%clearup LED controller
hComm.LEDCtrl.setVisibleBacklightsOff();
hComm.LEDCtrl.setIrBacklightsOff();
hComm.LEDCtrl.delete();

if ~(hComm.THSensor == 0)
    hComm.THSensor.close();
end

