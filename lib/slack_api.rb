require 'slackbotsy'

class SlackApi

  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def say(text)
    if settings.development?
      puts text
    elsif settings.production?
      bot.say text
    end
    nil
  end

  def bot
    @bot ||= Slackbotsy::Bot.new({
      'channel'          => settings.slack_channel,
      'name'             => settings.slack_bot_name,
      'incoming_webhook' => settings.slack_incoming_webhook,
      'outgoing_token'   => settings.slack_outgoing_token
    })
  end

end