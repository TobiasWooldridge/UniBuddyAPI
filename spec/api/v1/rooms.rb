require "spec_helper"

describe "/api/v1/buildings/:building_id/rooms", :type => :api do
  let(:response){ post("/users", test_data.to_json) }

  it "creates a new user" do
    response.code.should == 201
  end

  it "returned some location header" do
    response.headers[:location].should_not be_blank
  end

  it "returned the correct id" do
    u = get("/users/#{response[:id]}")
    u[:name].should == test_data[:name]
  end

  it "deletes the user correctl" do
    delete("/users/#{response[:id]}")
    get("/users/#{response[:id]}").code.should == 404
  end
end