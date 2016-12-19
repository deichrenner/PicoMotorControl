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
        % debug input
        debug = 0;
        % IP
        IP = '192.168.2.2';
        % port
        port = 23;
        % read buffer size
        nReadBuffer = 1024;
        % write buffer size
        nWriteBuffer = 1024;
        % report state
        isOpen = 0;
    end
    
    methods
        
        function JS = JavaSocket(debug,IP,port,nReadBuffer,nWriteBuffer)
            %JavaSocket.JavaSocket Create a Java socket stack interface object
            % 
            % JS = JavaSocket(debug,IP,port,nReadBuffer,nWriteBuffer)
            % is an object which initialises the JavaSocket from the corresponding
            % Java library. Other parameters are also initialised. 
            %
            % Notes::
            % - debug is a flag specifying output printing (0 or 1).
            % - IP is the IP of the network device.
            % - port is the port of the network device.
            % - nReadBuffer is the length of the read buffer.
            % - nWriteBuffer is the length of the write buffer.
            
            JS.debug = debug;
            if JS.debug > 0
                fprintf('JavaSocket init\n');
            end
            if nargin > 1
                JS.IP = IP;
                JS.port = port;
                JS.nReadBuffer = nReadBuffer;
                JS.nWriteBuffer = nWriteBuffer;
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
            
            % import relevant java stack
            import java.net.*;
            import java.io.*;
            
            % write the message
            out = JS.handle.getOutputStream;
            out.write(wmsg);
            out.close();
        end


        function rmsg = read(JS)
            %JavaSocket.rmsg Read from network object
            %
            % rmsg = JS.read() reads from a network device and returns the
            % read bytes. Will print an error if no data was read.
 
            if JS.debug > 0
                fprintf('JavaSocket read\n');
            end
            
            % import relevant java stack
            import java.net.*;
            import java.io.*;
            
            % read message
            in = BufferedReader(InputStreamReader(JS.handle.getInputStream));
            rmsg = in.readLine();
            
            % check the response
            if rmsg == ''
               fprintf('JavaStack read returned no data\n');
            end
            % close Reader
            in.close();
        end

        
    end 
end