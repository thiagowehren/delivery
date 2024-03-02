require "rails_helper"

RSpec.describe "/stores", type: :request do
    describe "GET /show" do
        it "renders a successful response with stores" do
            store = Store.create! name: "STORE-00X"
            get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
            json = JSON.parse(response.body)

            expect(json["name"]).to eq "STORE-00X"
        end
    end
end