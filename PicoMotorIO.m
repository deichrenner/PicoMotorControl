%PicoMotorIO Abstract class definition for PicoMotor input output
%
% Methods::
%  open         Open the connection to the PicoMotor
%  close        Close the connection to the PicoMotor
%  read         Read data from the PicoMotor
%  write        Write data to the PicoMotor
%
% Notes::
% - handle is the connection object
% - The read function should return a uint8 datatype
% - The write function should be given a uint8 datatype as a parameter
% 
% Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
% Version: 0.0.1alpha
% Changes tracker:  28.01.2016  - First version
% License: GPL v3

classdef PicoMotorIO
    properties (Abstract)
        % connection handle
        handle
    end
    
    methods (Abstract)
        % open the PicoMotor connection
        open(PicoMotorIO)
        % close the PicoMotor connection
        close(PicoMotorIO)
        % read data from the PicoMotor
        read(PicoMotorIO)
        % write data to the PicoMotor
        write(PicoMotorIO)
    end
end