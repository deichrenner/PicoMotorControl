% PicoMotor interface to the New Focus Picomotor Ethernet Controller 8752
%
% Methods:
% PicoMotor         Constructor, establishes communications
% delete            Destructor, closes connection
% send              Send data to the PicoMotor
% receive           Receive data from the PicoMotor
% setResolution     Sets the resolution of the movement
% setDirection      Sets the direction for the next movement
% setController     Sets the controller to work on. Default: first
% setMotor          Sets the motor to use
% getStatus         Displays the hardware status of the controller
% fwVersion         Displays the firmware version of the controller
% stop              Stop motion
% go                Start configured motion
% rel               Moves the selected motor the specified number of steps
%
% Example::
%           PM = PicoMotor('debug', 1)
%
% Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
% Version: 0.0.1alpha
% Changes tracker:  28.01.2016  - First version
% License: GPL v3

classdef PicoMotor < handle
    
    properties
        % connection handle
        conn;
        % debug input
        debug;
    end
    
    methods
        function PM = PicoMotor(varargin)
            % PicoMotor.PicoMotor Create a PicoMotor object
            %
            % PM = PicoMotor(OPTIONS) is an object that represents a connection
            % interface to a New Focus Picomotor Ethernet Controller 8752.
            %
            % Options:
            %  'debug',D       Debug level, show communications packet
            
            % make all helper functions known to PicoMotor()
            libDir = strsplit(mfilename('fullpath'), filesep);
            % fix fullfile file separation for linux systems
            firstsep = '';
            if (isunix == 1)
                firstsep = '/';
            end
            addpath(fullfile(firstsep, libDir{1:end-1}, 'helperFunctions'));
            
            % init the properties
            opt.debug = 0;
            % read in the options
            opt = tb_optparse(opt, varargin);
            
            % connect via ethernet
            PM.debug = opt.debug;
            if PM.debug <= 1
                PM.conn = ethPicoMotorIO;
            elseif PM.debug == 2
                PM.conn = ethPicoMotorIO(PM.debug);
            elseif PM.debug == 3
                disp('Dummy mode. Didn''t connect to PicoMotor!');
            end
            connect = 1;
            
            % error
            if(~connect)
                fprintf('Add error handling here!\n');
            end
        end
        
        function delete(PM)
            % PicoMotor.delete Delete the PicoMotor object
            %
            % delete(PM) closes the connection to the PicoMotor
            
            PM.conn.close();
        end
        
        function send(PM, cmd)
            % PicoMotor.send Send data to the PicoMotor
            %
            % PicoMotor.send(cmd) sends a command to the PicoMotor through the
            % connection handle.
            %
            % Notes::
            % - cmd is a command object.
            %
            % Example::
            %           d.send(cmd)
            
            % send the message through the PicoMotorIO write function
            PM.conn.write(cmd);
            
            if PM.debug > 0
                disp(['sent: [' cmd ']']);
            end
        end
        
        function rmsg = receive(PM)
            % PicoMotor.receive Receive data from the PM
            %
            % rmsg = PicoMotor.receive() receives data from the PM through
            % the connection handle.
            %
            % Example::
            %           rmsg = d.receive()
            
            % read the message through the PicoMotorIO read function
            if ~(PM.debug == 3)
                rmsg = PM.conn.read();
                if PM.debug > 0
                    disp(['received: [' rmsg ']']);
                end
            else
                rmsg = zeros(20);
            end
        end
        
        
        function rel(PM, steps)
            % PicoMotor.rel sets the numer of steps to move in the
            % comfigured direction, with the configured speed and the motor
            % activated
            %
            % Notes:: 
            %           - steps is the desired number of steps.
            %
            % Example::
            %           PM.rel(10)
            
            
            cmd = ['REL a1=' num2str(steps)];
            PM.send(cmd);
            PM.receive();
            
        end
        
        
        function go(PM)
            % PicoMotor.go starts the configured motion
            %
            % Example::
            %           PM.go    
            
            cmd = 'GO a1';
            PM.send(cmd);
            
        end

                
        function stop(PM)
            % PicoMotor.stop stops the configured motion
            %
            % Example::
            %           PM.stop
            
            
            cmd = 'STO a1';
            PM.send(cmd);
            PM.receive();
            
        end
        
        function setResolution(PM, res)
            % PicoMotor.setResolution sets the resolution of the motor
            % movement
            %
            % Notes:: 
            %           - res is the desired resolution. Valid values are
            %               'fine' and 'coarse'
            %
            % Example::
            %           PM.setResolution('fine')
            
            
            cmd = ['RES ' upper(res)];
            PM.send(cmd);
            PM.receive();
            
        end
        
        function setDirection(PM, d)
            % PicoMotor.setDirection sets the direction of the motor
            % movement
            %
            % Notes:: 
            %           - d is the desired direction. Valid values are
            %               'f' (forwards) and 'b' (backwards)
            %
            % Example::
            %           PM.setDirection('f')
            
            if d == 'f'
                cmd = 'FOR a1';
                PM.send(cmd);
                rmsg = PM.receive();
                disp(rmsg);
            elseif d == 'b'
                cmd = 'REV a1';
                PM.send(cmd);
                rmsg = PM.receive();
                disp(rmsg);
            else
                disp('Invalid input argument, f and r are allowed');
            end
            
        end        
        
        function setMotor(PM, mot)
            % PicoMotor.setMotor sets the motor to use
            %
            % Notes:: 
            %           - mot is the desired motor. Valid values are
            %             0, 1 and 2
            %             So far, the code assumes, that there is only one
            %             driver connected to the 8572 network controller
            %
            % Example::
            %           PM.setMotor(1)
            
            cmd = ['CHL a1=' num2str(mot, 1)];
            PM.send(cmd);
            
        end
        
        function fwVersion(PM)
            % PicoMotor.fwversion Return firmware version
            %
            % fwversion returns firmware version.
            %
            % Example::
            %           d.fwversion()
            
            cmd = 'VER';
            PM.send(cmd);
            
            % receive the command
            msg = PM.receive()';
            ver = msg; 
            disp(ver{1,:});
        end
        
        
        function stat = getStatus(PM)
            % PicoMotor.getStatus Returns the main status of the PicoMotor
            %
            % status returns the main status of the PM 
            %
            % Example::
            %           PM.status()
            
            cmd = 'STA';
            PM.send(cmd);
            
            % receive the command
            msg = PM.receive()';
            stat = msg; 
            disp(stat{1,:});
            disp(stat{2,:});
            disp(stat{3,:});
        end
    end
end
