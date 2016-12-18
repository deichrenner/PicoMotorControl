% PicoMotor interface to the New Focus Picomotor Ethernet Controller 8752
%
% Methods:
% PicoMotor         Constructor, establishes communications
% delete            Destructor, closes connection
% send              Send data to the PicoMotor
% receive           Receive data from the PicoMotor
% setResolution
% setDirection
% setIP
% setController
% setMotor
% getInfo
% stop
% go
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
            
            % make chunks of 64 byte and send via loop
            if ~(PM.debug == 3)
                chunkSize = 64;
                numOfTransfers = ceil(length(cmd.msg)/chunkSize);
                for i = 1:numOfTransfers
                    % add data to packet
                    if i == numOfTransfers
                        data = cmd.msg((i-1)*chunkSize+1:end);
                    else
                        data = cmd.msg((i-1)*chunkSize+1:i*chunkSize);
                    end
                    % send the message through the PicoMotorIO write function
                    PM.conn.write(data);
                end
            end
            
            if PM.debug > 0
                fprintf('sent:    [ ');
                for ii=1:length(cmd.msg)
                    fprintf('%s ',dec2hex(cmd.msg(ii)))
                end
                fprintf(']\n');
            end
        end
        
        function setMode(PM,m) % 0x1A1B
            %PicoMotor.setMode Sets PicoMotor to the selected mode
            %
            % setMode puts the PM to the selected mode. Possible modes m
            % are:
            %   0 = Normal video mode
            %   1 = Pre-stored pattern mode (Images from flash)
            %   2 = Video pattern mode
            %   3 = Pattern On-The-Fly mode (Images loaded through USB)
            %
            % Note:
            % - m is the mode. The default mode is 3.
            %
            % Example::
            %           d.setMode(2)
            
            if nargin == 1
                m = 3;
                if PM.debug
                    disp('setMode: Use default mode 3');
                end
            elseif nargin > 2
                disp(['setMode: Please only specify the PM to work on and ' ...
                    'the required operation mode']);
            end
            
            if any(m > 3) || any(m < 0)
                disp('setMode: Only modes [0-3] are allowed, use default mode 3.');
                m = 3;
            end
            
            % make new display mode known the PM object
            PM.displayMode = m;
            
            cmd = Command();
            cmd.Mode = 'w';                     % set to write mode
            cmd.Reply = true;                  % we want no reply
            cmd.Sequence = PM.getCount;        % set the rolling counter of the sequence byte
            data = dec2bin(m, 8);                  % usb payload
            cmd.addCommand({'0x1A', '0x1B'}, data);   % set the usb command
            PM.send(cmd)
            PM.receive;
            
            % set additional parameters depending on the chosen display
            % mode
            if PM.displayMode == 0 || PM.displayMode == 2
                % set it6535 receiver to display port &0x1A01
                cmd = Command();
                cmd.Mode = 'w';                     % set to write mode
                cmd.Reply = true;                  % we want no reply
                cmd.Sequence = PM.getCount;        % set the rolling counter of the sequence byte
                data = dec2bin(2, 8);                  % usb payload
                cmd.addCommand({'0x1A', '0x01'}, data);   % set the usb command
                PM.send(cmd)
                PM.receive;
                PM.display(zeros(1080,1920));
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
                    fprintf('received:    [ ');
                    for ii=1:length(rmsg)
                        fprintf('%d ',rmsg(ii))
                    end
                    fprintf(']\n');
                end
            else
                rmsg = zeros(20);
            end
        end
        
        
        function fwVersion(PM)
            % PicoMotor.fwversion Return firmware version
            %
            % fwversion returns firmware version.
            %
            % Example::
            %           d.fwversion()
            
            cmd = Command();
            cmd.Mode = 'r';         % set to read mode
            cmd.Reply = true;       % we want a reply!
            cmd.Sequence = PM.getCount;     % set the rolling counter of the sequence byte
            cmd.addCommand({'0x02', '0x05'}, '');
            PM.send(cmd);
            
            % receive the command
            msg = PM.receive()';
            
            % parse firmware version
            rpatch = typecast(uint8(msg(5:6)),'uint16');
            rminor = uint8(msg(7));
            rmajor = uint8(msg(8));
            APIpatch = typecast(uint8(msg(9:10)),'uint16');
            APIminor = uint8(msg(11));
            APImajor = uint8(msg(12));
            v = [num2str(rmajor) '.' num2str(rminor) '.' num2str(rpatch)];
            
            % display the result
            disp(['I am a ' deblank(PM.conn.handle.getProductString) ...
                '. My personal details are:']);
            disp([blanks(5) 'Application Software Version: v' v]);
            disp([blanks(5) 'API Software Version: ' num2str(APImajor) '.' ...
                num2str(APIminor) '.' num2str(APIpatch)]);
            disp(['If I don''t work complain to my manufacturer ' ...
                PM.conn.handle.getManufacturersString]);
        end
        
        
        function hwstat = hwstatus(PM) % 0x1A0A
            % PicoMotor.hwstatus Returns the hardware status of the PicoMotor
            %
            % hwstatus returns the hardware status of the PM as described
            % in the DLPC900 programmers guide on page 15.
            % Meaning of the different bits see manual.
            %
            % Example::
            %           d.hwstatus()
            
            cmd = Command();
            cmd.Mode = 'r';         % set to read mode
            cmd.Reply = true;       % we want a reply!
            cmd.Sequence = PM.getCount;     % set the rolling counter of the sequence byte
            cmd.addCommand({'0x1A', '0x0A'}, '');
            PM.send(cmd);
            
            % receive the command
            msg = PM.receive()';
            
            % parse hardware status
            hwstat = dec2bin(msg(5),8);
        end
        
        function [stat, statbin] = status(PM) % 0x1A0C
            % PicoMotor.status Returns the main status of the PicoMotor
            %
            % status returns the main status of the PM as described
            % in the DLPC900 programmers guide on page 16.
            % The first output returns a cell array with a human readable
            % status message. The second one just returns the bits as
            % listed in the developer manual.
            %
            % Example::
            %           d.status()
            
            cmd = Command();
            cmd.Mode = 'r';         % set to read mode
            cmd.Reply = true;       % we want a reply!
            cmd.Sequence = PM.getCount;     % set the rolling counter of the sequence byte
            cmd.addCommand({'0x1A', '0x0C'}, '');
            PM.send(cmd);
            
            % receive the command
            msg = PM.receive()';
            
            % parse hardware status
            statbin = dec2bin(msg(5),8);
            statbin = str2num(fliplr(statbin(3:end))');
            
            % 0 status
            stat0 = {'Mirrors not parked | '; ...
                'Sequencer stopped | '; ...
                'Video is running | '; ...
                'External source not locked | '; ...
                'Port 1 sync not valid | '; ...
                'Port 2 sync not valid';};
            % 1 status
            stat1 = {'Mirrors parked | '; ...
                'Sequencer running | '; ...
                'Video is frozen | '; ...
                'External source locked | '; ...
                'Port 1 sync valid | '; ...
                'Port 2 sync valid';};
            stat = stat0;
            stat(statbin == 1) = stat1(statbin == 1);
        end
    end
end
