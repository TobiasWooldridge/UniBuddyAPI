require 'spec_helper'

describe Api::V1::BuildingsController do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end


  describe "GET #index" do
    building = nil

    before :each do
      building = create(:building)
    end
    after :each do
      building.delete
    end

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end


    it "includes building we add" do
      get :index

      body = JSON.parse response.body

      expect(body.first["code"]).to eq("TEST");
      expect(body.first["name"]).to eq("Test Building");
    end

  end
end
