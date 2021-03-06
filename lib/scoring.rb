class Scoring

  attr_accessor :settings, :redis

  def initialize(settings, redis)
    @settings = settings
    @redis = redis
  end

  def increment_user_score(user)
    new_score = (redis.zincrby settings.redis_scores_key, 1, user).to_i
    yield(new_score) if block_given?
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


end