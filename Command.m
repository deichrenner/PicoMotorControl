% 8752 command construction
%
% Methods::
% Command                   Constructor, creates an empty command object
% delete                    Destructor, clears the command object
%
% addCommand                Add a command directly to the command object
%
% clear                     Clear the command msg
% display                   Display the command msg (decimal)
%
% Notes::
% - Refer to the NewFocus 8752 manual for a more detailed
% description of the commands.
%
% Example::
%                   cmd = Command();
%                   cmd.addLength();
%
% Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
% Version: 0.0.1alpha
% Changes tracker:  28.01.2016  - First version
% License: GPL v3

classdef Command < handle
    
    properties
        msg             % message to be sent
        Mode = 'r';     % mode of this command ('r' (read) / 'w' (write)) initialize to read
        Reply = true;   % is a reply requestes (true / false) initialize to true
        Sequence = 1;   % rolling counter for the sequence byte
    end
    
    methods
        function cmd = Command(varargin)
            % Command.cmd Create an empty command
            %
            % c = Command(OPTIONS) is an object that represents an C900 command
            %
            % Example::
            %           c = Command();
            
            cmd.msg = uint8([]);
        end
        
        function delete(cmd)
            %Command.delete Clear command
            %
            % delete(c) clears the command
            
            cmd.msg = '';
        end
        
        function addCommand(cmd,c,d)
            %Command.addCommand Add a command
            %
            % Command.addCommand(v) adds a command to the
            % command object.
            %
            % Notes::
            % - c   is a 2x1 cell which holds the usb command which can be 
            %       found in DLPC900 Programmer's guide
            % - d   is the usb payload 
            %
            % Example::
            %       cmd.addCommand({'0x02', '0x05'}, data)
            
            cmd.msg(5) = uint8(sscanf(c{2}, '%x'));
            cmd.msg(6) = uint8(sscanf(c{1}, '%x'));
            cmd.addData(d);
            cmd.addLength;
            cmd.addSequence
            cmd.addFlagByte;
        end
        
        function addData(cmd, d)
            %Command.addData Adds data to the command string
            % 
            % Command.addData(d) adds data to the command string this has
            % to match the usb command. See DLPC900 Programmer's guide.
            %
            % Example::
            %       cmd.addData(d)
            
            d = uint8(bin2dec(d));
            cmd.msg(7:7+length(d)-1) = d;
        end
        
        function addLength(cmd)
            % Command.addLength Add the length
            %
            % Command.addLength adds the length of the command string set
            % via Command.addCommand to the bytes 4 and 4
            %
            % Example::
            %       cmd.addLength
            
            len = uint16(length(cmd.msg)-4);
            cmd.msg(3:4) = typecast(len, 'uint8');
        end
        
        function addFlagByte(cmd)
            % Command.addFlagByte Add the flagbyte
            %
            % Command.addFlagByte adds the flagbyte of the command to be 
            % executed
            %
            % Example::
            %       cmd.addFlagByte
            
            flagstring = '';
            switch cmd.Mode
                case 'r'
                    flagstring = [flagstring, '1'];
                case 'w'
                    flagstring = [flagstring, '0'];
                otherwise
                    error(['The mode specified is not valid! Only ''r'' for read operation ', ...
                        'or ''w'' for write operation is allowed.']);
            end
            switch cmd.Reply
                case true
                    flagstring = [flagstring, '1'];
                case false
                    flagstring = [flagstring, '0'];
                otherwise
                    error('The reply flag can only be true or false!');
            end
            flagstring = [flagstring, '000000'];
            cmd.msg(1) = bin2dec(flagstring);
        end
        
        function addSequence(cmd)
            % Command.addSequence Insert the sequence counter
            %
            % Command.addSequence insert a sequence counter which can be a
            % rolling counter and will be set by the C900 identical in the
            % response.
            %
            % Example::
            %       cmd.addSequence()
            
            cmd.msg(2) = uint8(cmd.Sequence); 
        end
        
        function clear(cmd)
            % Command.clear Clear command
            %
            % Commad.clear clears the message
            %
            % Example::
            %           cmd.clear()
            
            cmd.msg = '';
        end
        
        function s = char(cmd)
            s = '';
            for i=1:length(cmd.msg)
                s = [s sprintf(' %d', cmd.msg(i))];
            end
        end
        
        function s = hex(cmd)
            s = '';
            for i=1:length(cmd.msg)
                s = [s sprintf(' %x', cmd.msg(i))];
            end
        end
        
        function display(cmd)
            % Command.display Display the command message (decimal)
            %
            % Command.display() prints the command message to the MATALB
            % command window in decimal format.
            %
            % Example::
            %           cmd.display()
            
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(cmd) );
        end
        
        function displayHex(cmd)
            % Command.displayHex Display the command message (hex)
            %
            % Command.displayHex() prints the command message to the MATLAB
            % command window in hexadecimal format.
            %
            % Example::
            %           cmd.displayHex()
            
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( hex(cmd) );
        end
        
        
    end
end
