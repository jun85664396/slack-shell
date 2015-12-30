class App

  attr_accessor :url
  attr_accessor :ws
  attr_accessor :location
  attr_accessor :me

  def initialize
    data = Slack.request("rtm.start")
    if data["ok"]
      @url = data["url"]
      Slack.synchronizing(data)
      @me = data["self"]["id"]
      t = Thread.new{run()}
      loop do
        line = Readline::readline(">")
        read_line(line)
      end

    else
      p data["error"]
    end
  end

  def run
    EM.run {
      @ws = Faye::WebSocket::Client.new(@url)
      @ws.on :message do |event|
        msg = JSON.parse(event.data)
        if msg["type"] == "hello"
          Slack.data_load
          @me = Slack.parse_user(@me.to_s)
          @location = "main"
          print "connected!\n"
        elsif msg["type"] == "error"
          p msg.error
        elsif msg["type"] == "message"
          if @location == msg["channel"]
            print "#{Slack.parse_user(msg["user"])["name"]} : #{msg["text"]}\n"
          end
        end
      end

      @ws.on :error do |event|
        p event
      end
      @ws.on :close do |event|
        @ws = Faye::WebSocket::Client.new(@url)
      end
    }
  end

  def read_line(line)
    exit if line == "\\exit" || line == '\\quit' 
    if line.strip.length > 0 && line != "nil"
      if line == "help"
        print "\\leave - main\n"
        print "\\join :channel_index - join channel\n"
        print "\\channels - channel list\n"
        print "\\exit\n"
      else
        case line
        when "\\channels"
          print Slack.channel_list
        when /^\\join.*/
          idx = line.split(" ")[1].to_i
          if idx.class == Fixnum
            channel = Slack.channels[idx]
            @location = channel["id"].to_s
            print "moved channel #{channel["name"]}\n"
          else
            print "channel idx error.\n"
          end
        when "\\leave"
          @location = "main"
          print "Main\n"
        else
          if @location == "main"
            print "Please select the channel.\n"
            print Slack.channel_list
          else
            @ws.send({
              type: "message",
              channel: @location,
              text: line.to_s.force_encoding("UTF-8")
            }.to_json)
          end
        end
      end
    end
  end
end
