%JavaSocket Interface to the Java socket stack
%
% Methods::
%  JavaSocket               Constructor, loads the JavaSocket library
%  delete                   Destructor, closes any open hid connection
%
%  open                     Open the hid device with vendor and product ID
%  close                    Close the hid device connection
%  read                     Read data from the hid device
%  write                    Write data to the hid device
%
%
% Example::
%           JS = JavaSocket(1,'192.168.2.2',23,1024,1024)
%
% Notes::
% - Code still untested on Mac and Linux
% 
% 
% Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
% Version: 0.0.1alpha
% Changes tracker:  28.01.2016  - First version
% License: GPL v3

classdef JavaSocket < handle
    properties
        % connection handle
        handle
        % output stream 
        out
        % input stream 
        in
        % buffered input stream 
        din
        % debug input
        debug = 0;
        % IP
        IP = '192.168.2.2';
        % port
        port = 23;
        % report state
        isOpen = 0;
    end
    
    methods
        
        function JS = JavaSocket(debug,IP,port)
            %JavaSocket.JavaSocket Create a Java socket stack interface object
            % 
            % JS = JavaSocket(debug,IP,port)
            % is an object which initialises the JavaSocket from the corresponding
            % Java library. Other parameters are also initialised. 
            %
            % Notes::
            % - debug is a flag specifying output printing (0 or 1).
            % - IP is the IP of the network device.
            % - port is the port of the network device.
            
            JS.debug = debug;
            if JS.debug > 0
                fprintf('JavaSocket init\n');
            end
            if nargin > 1
                JS.IP = IP;
                JS.port = port;
            end
        end
        
        function delete(JS)
            %JavaSocket.delete Delete JS object
            %
            % delete(JS) closes an open JS device connection. 
            %
            % Notes::
            
            if JS.debug > 0
                fprintf('JavaSocket delete\n');
            end
            if JS.isOpen == 1
                % close the open connection
                JS.close();
            end
        end

        function open(JS)
            %JavaSocket.open Open a JS object
            %
            % JS.open() opens a connection with a JS device with the
            % initialised values of IP and port from the JavaSocket
            % constructor.
            %
            % Notes::
            
            if JS.debug > 0
                fprintf('JavaSocket open\n');
            end
            % import relevant java stack
            import java.net.*;
            import java.io.*;

            % open the JS interface
            try 
                JS.handle = Socket(JS.IP, JS.port);
                JS.out = PrintWriter(JS.handle.getOutputStream, true);
                JS.in = JS.handle.getInputStream;
                JS.din = DataInputStream(JS.in);
            catch ME
                error(ME.identifier, 'JavaSocket: Connection Error: %s', ME.message);
            end
            % set open flag
            JS.isOpen = 1;
        end
        
        function close(JS)
            %JavaSocket.close Close JS object
            %
            % JS.close() closes the connection to a JS device.
            
            if JS.debug > 0
                fprintf('JavaSocket close\n');
            end
            if JS.isOpen == 1
                % close the connect
                close(JS.in);
                close(JS.out);
                close(JS.handle);
                % clear open flag
                JS.isOpen = 0;
            end
        end
        

        function write(JS,wmsg)
            %JavaSocket.write Write to network object
            %
            % JavaSocket.write() writes to a network device. Will print an error if
            % there is a mismach between the buffer size and the reported
            % number of bytes written.
            
            if JS.debug > 0
                fprintf('JavaSocket write\n');
            end
            
            % write the message
            JS.out.println(wmsg);
        end


        function rmsg = read(JS)
            %JavaSocket.rmsg Read from network object
            %
            % rmsg = JS.read() reads from a network device and returns the
            % read bytes. Will print an error if no data was read.
 
            if JS.debug > 0
                fprintf('JavaSocket read\n');
            end
            
            % read data from the socket - wait a short time first
            pause(0.1);
            bytes_available = JS.in.available;
            if JS.debug > 0
                fprintf(1, 'Reading %str    d bytes\n', bytes_available);
            end
            
            message = zeros(1, bytes_available, 'uint8');
            for i = 1:bytes_available
                message(i) = JS.din.readByte;
            end    
            
            rmsg = message;
            
            % check the response
            if isempty(rmsg)
                fprintf('JavaStack read returned no data\n');
            end
        end
        
    end 
end