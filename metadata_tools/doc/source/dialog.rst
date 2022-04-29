Basic metadata dialog 
=====================

A basic dialog, *basicMetaDataDlg*, is included with the metadata tools package
in order to make it easy to add unified metalata entry to existing device
control software. This section describes how to use this basic dialog.

In what follows it is assumed that the metadata defaultsTree has already been
loaded into memory as *defaultsTree*.

The dialog provides a 'live' temperature and humidity display while the
metadata entry dialog is open. It what follows it is assumed that is the done
using a RS232 based sensor from Precon. Note, this sensor can easily be changed
as the dialog itself contains no acquisition code but rather obtains these
values via a listener. 

The following code sample show how to call start the basic dialog and set up
the temperature and humidity listener. It is assumed that this code is called
from a GUI callback function and the port, mode and defaultsTree are existing
fields of the handles structure.

.. code-block:: matlab

    % Create basic dialog and get its handle
    dialogHdl = basicMetaDataDlg(handles.defaultsTree,handles.mode);
    
    % Set up temperature and humidity sensing
    sampler = THSampler('precon',handles.port);
    
    % Set temperature and humidity even listener
    dialogHandles = guidata(dialogHdl);
    THListener = dialogHandles.THListener;
    sampler.addlistener('THSampleAcquired',@THListener.eventHandler);
    
    % Start temperature & humitidy sensor and wait for dialog to exit
    sampler.start();
    uiwait(dialogHdl);
    
    % Stop sensor and delete
    sampler.stop();
    delete(sampler);

