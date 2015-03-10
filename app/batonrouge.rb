require 'sinatra'
require "sinatra/reloader" if development?
require 'slackbotsy'

set :slack_channel,             ENV.fetch('SLACK_CHANNEL')           { 'test'}
set :slack_bot_name,            ENV.fetch('BOT_NAME')                { 'Baton Rouge' }
set :slack_incoming_webhook,    ENV.fetch('SLACK_INCOMING_WEBHOOK')  { :missing_slack_incoming_webhook }
set :slack_outgoing_token,      ENV.fetch('SLACK_OUTGOING_TOKEN')    { :missing_slack_outgoing_token }

post "/" do
  check_authorization(params['token'])
  current_user = params['user_name']
  case params['text']
  when /^\s*help\s*$/
    help_text
  when /^\s*@?(\w+)\s*$/
    user_to_award = $1
    give_baton_rouge(current_user, user_to_award) do |output|
      bot.say output[:say] if output[:say]
      output[:return]
    end
  else
    "Commande invalide"
  end
end

def check_authorization(token)
  if token != settings.slack_outgoing_token
    error 403 do
      'Invalid token'
    end
  end
end

def give_baton_rouge(current_user, user_to_award)
  output = {say: "Oh! #{current_user} a donné 1 baton à #{user_to_award}. #{user_to_award} a maintenant 1 baton rouge"}
  yield(output) if block_given?
end

def help_text
  <<-eos
/batonrouge [username] - Donne un batonrouge à un utilisateur
/batonrouge [username] -1 - Retire un batonrouge à un utilisateur
/batonrouge ranking - Affiche le classement
/batonrouge help - Affiche cette aide
eos
end

def bot
  @bot ||= Slackbotsy::Bot.new({
    'channel'          => settings.slack_channel,
    'name'             => settings.slack_bot_name,
    'incoming_webhook' => settings.slack_incoming_webhook,
    'outgoing_token'   => settings.slack_outgoing_token
  })
end
