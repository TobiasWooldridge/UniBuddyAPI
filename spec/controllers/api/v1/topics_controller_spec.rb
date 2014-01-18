require 'spec_helper'

describe Api::V2::TopicsController do
  topic = nil

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    topic = create(:topic)
  end

  after :each do
    topic.delete
  end



  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end
end
