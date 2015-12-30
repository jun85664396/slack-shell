class Slack
  attr_accessor :users
  attr_accessor :channels

  def self.request(key)
    uri = URI.parse("https://slack.com/api/#{key}?token=#{ENV['TOKEN']}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    JSON.parse(response.body)
  end

  def self.synchronizing(data)
    user_file = File.new("./data/users.json", "w")
    data["users"].each do |user|
      user_file.syswrite(user.to_json)
      user_file.syswrite("\n")
    end

    channel_file = File.new("./data/channels.json", "w")
    data["channels"].each do |channel|
      channel_file.syswrite(channel.to_json)
      channel_file.syswrite("\n")
    end

    group_file = File.new("./data/groups.json", "w")
    data["groups"].each do |group|
      group_file.syswrite(group.to_json)
      group_file.syswrite("\n")
    end

    im_file = File.new("./data/ims.json", "w")
    data["ims"].each do |im|
      im_file.syswrite(im.to_json)
      im_file.syswrite("\n")
    end
  end

  def self.parse_channel(channel)
    channel = @channels.reject{|c| c != channel}
    if channel.nil?
      nil
    else
      channel.first
    end
  end

  def self.parse_user(user)
    user = @users.reject{|u| u["id"] != user}
    if user.nil?
      nil
    else
      user.first
    end
  end

  def self.data_load
    @users = []
    @channels = []

    users = File.read('./data/users.json')
    users.split("\n").each do |user|
      @users.push(JSON.parse(user))
    end

    channel_file = File.read("./data/channels.json")
    group_file = File.read("./data/groups.json")
    im_file = File.read("./data/ims.json")

    channel_file.split("\n").each do |channel|
      @channels.push(JSON.parse(channel))
    end
    group_file.split("\n").each do |group|
      @channels.push(JSON.parse(group))
    end
    im_file.split("\n").each do |im|
      im = JSON.parse(im)
      im["user"] = parse_user(im["user"])
      im["name"] = im["user"]["name"]
      @channels.push(im)
    end
  end

  def self.message(msg)

  end

  def self.channel_list
    channels = "Channel list\n"
    @channels.each_with_index do |x, i|
      channels += "##{i} #{x["name"]}\n"
    end
    channels
  end

  def self.channels
    @channels
  end
end
