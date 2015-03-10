require File.expand_path "../spec_helper.rb", __FILE__

describe "Baton Rouge" do

  before do
    app.set :slack_outgoing_token, nil
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
      post "/", text: "anything"
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


end