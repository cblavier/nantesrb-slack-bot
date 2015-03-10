require 'sinatra'
require "sinatra/reloader" if development?
require 'slackbotsy'

set :slack_channel,             ENV.fetch('SLACK_CHANNEL')           { 'test'}
set :slack_bot_name,            ENV.fetch('BOT_NAME')                { 'Baton Rouge' }
set :slack_incoming_webhook,    ENV.fetch('SLACK_INCOMING_WEBHOOK')  { :missing_slack_incoming_webhook }
set :slack_outgoing_token,      ENV.fetch('SLACK_OUTGOING_TOKEN')    { :missing_slack_outgoing_token }

post "/" do
  check_authorization(params['token'])
  case params['text']
  when /^\s*help\s*$/
    help_text
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