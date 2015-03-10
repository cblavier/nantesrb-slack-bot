require 'sinatra'
require "sinatra/reloader" if development?
require 'slackbotsy'
require 'redis'

require_relative '../lib/slack_api.rb'

set :redis_url,                 ENV.fetch('REDIS_URL')               { 'redis://localhost'}
set :redis_scores_key,          'scores'

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
    when /^\s*ranking\s*$/
    slack_api.say(ranking)
  when /^\s*@?(\w+)\s*$/
    user_to_award = $1
    give_baton_rouge(current_user, user_to_award) do |output|
      slack_api.say output[:say] if output[:say]
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
  increment_user_score(user_to_award) do |new_score|
    output = {say: "Oh! #{current_user} a donné 1 baton à #{user_to_award}. #{user_to_award} a maintenant #{pluralize(new_score, "baton rouge")}"}
    yield(output) if block_given?
  end
end

def increment_user_score(user)
  new_score = (redis.zincrby settings.redis_scores_key, 1, user).to_i
  yield(new_score) if block_given?
end

def help_text
  <<-eos
/batonrouge [username] - Donne un batonrouge à un utilisateur
/batonrouge [username] -1 - Retire un batonrouge à un utilisateur
/batonrouge ranking - Affiche le classement
/batonrouge help - Affiche cette aide
eos
end

def ranking
  scores = redis.zscan(settings.redis_scores_key, 0)[1].reverse
  ranking_text = "Ok, voici le classement complet :\n"
  scores.each.with_index do |score, i|
    ranking_text.concat "#{i + 1} - #{score[0]}: #{pluralize(score[1].to_i, 'baton rouge')}"
    ranking_text.concat "\n"
  end
  ranking_text
end

def pluralize(n, singular, plural=nil)
  if (-1..1).include?(n)
    "#{n} #{singular}"
  elsif plural
    "#{n} #{plural}"
  else
    "#{n} #{singular.split(' ').join('s ')}s"
  end
end

def slack_api
  @slack_api ||= SlackApi.new(settings)
end

def redis
  @redis ||= Redis.new(url: settings.redis_url)
end