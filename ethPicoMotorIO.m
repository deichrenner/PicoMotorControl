%ethPicoMotorIO ethernet interface between MATLAB and the NewFocus
%Picomotor Ethernet Controller 8752
%
% Methods::
%
%  ethPicoMotorIO    Constructor, initialises and opens the ethernet connection
%  delete       Destructor, closes the ethernet connection
%
%  open         Open a ethernet connection to the PicoMotor
%  close        Close the ethernet connection to the PicoMotor
%  read         Read data from the PicoMotor through ethernet
%  write        Write data to the PicoMotor through ethernet
%
% Example::
%           ethPM = ethPicoMotorIO()
%
% Notes::
% - Uses the Java Socket stack 
%
% Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
% Version: 0.0.1alpha
% Changes tracker:  28.01.2016  - First version
% License: GPL v3

classdef ethPicoMotorIO < PicoMotorIO
    properties
        % connection handle
        handle
        % debug input
        debug = 0;
        % IP
        IP = '192.168.2.2';
        % port 
        port = 23;
    end
    
    methods
        function PMIO = ethPicoMotorIO(varargin)
            %ethPicoMotorIO.ethPicoMotorIO Create a ethPicoMotorIO object
            %
            % PMIO = ethPicoMotorIO(varargin) is an object which
            % initialises a ethernet connection between MATLAB and the
            % PicoMotor using the Java socket stack.
            % 
            % Notes::
            % - Can take one parameter debug which is a flag specifying
            % output printing (0 or 1).
            
            if nargin == 0
                PMIO.debug = 0;
            end
            if nargin > 0
                PMIO.debug = varargin{1}; 
            end
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO init\n');
            end
            % create the eth handle 
            PMIO.handle = JavaSocket(PMIO.debug, PMIO.IP, PMIO.port);
            % open the PicoMotorIO connection
            PMIO.open;
        end
        
        function delete(PMIO)
            %ethPicoMotorIO.delete Delete the ethPicoMotorIO object
            %
            % delete(PMIO) closes the ethernet connection handle
            
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO delete\n');
            end
            % delete the ethernet handle 
            delete(PMIO.handle)
        end
        
        % open the PicoMotorIO connection
        function open(PMIO)
            %ethPicoMotorIO.open Open the ethPicoMotorIO object
            %
            % ethPicoMotorIO.open() opens the ethernet handle through the
            % Java socket stack
            
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO open\n');
            end
            % open the ethernet handle
            PMIO.handle.open;
        end
        
        function close(PMIO)
            %ethPicoMotorIO.close Close the ethPicoMotorIO object
            %
            % ethPicoMotorIO.close() closes the ethernet handle through
            % Java socket stack
            
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO close\n');
            end 
            % close the ethernet handle
            PMIO.handle.close;
        end
        
        function rmsg = read(PMIO)
            %ethPicoMotorIO.read Read data from the ethPicoMotorIO object
            %
            % rmsg = ethPicoMotorIO.read() reads data from the PicoMotor through
            % ethernet and returns the data in uint8 format.
            %
            
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO read\n');
            end 
            % read from the ethernet handle
            rmsg = PMIO.handle.read;
            % cast to char and replace '>' by ''
            rmsg = strrep(char(rmsg), '>', '');
            % split by line
            rmsg = strsplit(rmsg, '\n');
        end
        
        function write(PMIO,wmsg)
            %ethPicoMotorIO.write Write data to the ethPicoMotorIO object
            %
            % ethPicoMotorIO.write(wmsg) writes data to the PicoMotor 
            % through ethernet.
            %
            % Notes::
            % - wmsg is the data to be written to the PicoMotor via 
            % ethernet in char format.
            
            if PMIO.debug > 0
                fprintf('ethPicoMotorIO write\n');
            end 
            % write to the ethernet handle
            PMIO.handle.write(wmsg);
        end
    end 
end