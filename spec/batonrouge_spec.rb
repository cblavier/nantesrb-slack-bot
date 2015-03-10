require File.expand_path "../spec_helper.rb", __FILE__

describe "Baton Rouge" do

  let(:redis_scores_key)    { "test_scores" }
  let(:redis)               { app.send(:redis) }

  before do
    app.set :redis_scores_key,     redis_scores_key
    app.set :slack_outgoing_token, nil
    redis.del(redis_scores_key)
  end

  describe "help" do

    it "says help" do
      post "/", text: "help"
      expect(last_response).to be_ok
      expect(last_response.body).to_not be_empty
    end

  end

  describe "invalid command" do

    it "shows invalid command" do
      post "/", text: "invalid command"
      expect(last_response).to be_ok
      expect(last_response.body).to eq("Commande invalide")
    end

  end

  describe "authorization" do

    let(:token) { "ACTUAL_TOKEN" }

    before do
      app.set :slack_outgoing_token, token
    end

    it "returns 200 if correct token" do
      post "/", token: token
      expect(last_response).to be_ok
    end

    it "returns 403 if wrong token", check_response_ok: false do
      post "/", token: "WRONG_TOKEN"
      expect(last_response.status).to be(403)
    end

  end

  describe "give batonrouge" do

    let(:current_user) { "dhh" }
    let(:user)         { "yehuda" }

    it "gives 1 baton rouge" do
      expects_say("Oh! #{current_user} a donné 1 baton à #{user}. #{user} a maintenant 1 baton rouge")
      post "/", text: "#{user}", user_name: current_user
      expect(last_response.body).to be_empty
    end

    it "gives 2 batons rouges" do
      expects_say("Oh! #{current_user} a donné 1 baton à #{user}. #{user} a maintenant 1 baton rouge")
      expects_say("Oh! #{current_user} a donné 1 baton à #{user}. #{user} a maintenant 2 batons rouges")
      2.times do
        post "/", text: "#{user}", user_name: current_user
        expect(last_response.body).to be_empty
      end
    end

  end

  def expects_say(text)
    Slackbotsy::Bot.any_instance.expects(:say).with(text).at_least_once
  end

end