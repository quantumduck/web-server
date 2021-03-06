require 'pry'
require 'socket'                                    # Require socket from Ruby Standard Library (stdlib)

class MyServer < TCPServer

  attr_reader :host, :port

  def self.open(port)
    @host = 'localhost'
    @port = port
    super('localhost', port)
  end

  def log(string)
    logfile = File.new("log/server_log.log","a")
    if logfile
      time = Time.now.to_s + ":\n"
      logfile.syswrite(time)
      logfile.syswrite(string + "\n\n")
      logfile.close
    else
       puts "WARNING: Unable to open logfile!"
       puts string
    end
  end

end


class LogFile < File

  def initialize(name = "log.log")
    super("log.log", "a")
  end

end


server = MyServer.open(2000)                 # Socket to listen to defined host and port

server.log("Server started on #{server.host}:#{server.port} ...")        # Output to stdout that server started

      # binding.pry

loop do                                             # Server runs forever
  client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

  lines = []
  while (line = client.gets) && !line.chomp.empty?  # Read the request and collect it until it's empty
    lines << line.chomp
  end
  lines.each { |line| server.log(line) }                     # Output the full request to stdout

  # filename = "index.html"

  # Replace "/Get \//" and "/\ HTTP.*/" with empty strings
  filename = lines[0].gsub(/GET \//, '').gsub(/\ HTTP.*/, '')

    # binding.pry

  if File.exists?(filename)
    response_body = File.read(filename)
    success_header = []
    success_header << "HTTP/1.1 200 OK"
    success_header << "Content-Type: text/#{filename.split('.').last}" # should reflect the appropriate content type (HTML, CSS, text, etc)
    success_header << "Content-Length: #{response_body.length}" # should be the actual size of the response body
    success_header << "Connection: close"
    header = success_header.join("\r\n")
  else
    response_body = "File Not Found\n" # need to indicate end of the string with \n
    not_found_header = []
    not_found_header << "HTTP/1.1 404 Not Found"
    not_found_header << "Content-Type: text/plain" # is always text/plain
    not_found_header << "Content-Length: #{response_body.length}" # should the actual size of the response body
    not_found_header << "Connection: close"
    header = not_found_header.join("\r\n")
  end

  response = [header, response_body].join("\r\n\r\n")

  client.puts(response)

  # client.puts(Time.now.ctime)                       # Output the current time to the client
  client.close                                      # Disconnect from the client
end
