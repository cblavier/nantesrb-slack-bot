require File.expand_path "../spec_helper.rb", __FILE__

describe "Baton Rouge" do

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

end