require "rails_helper"

RSpec.describe "/stores", type: :request do
    describe "GET /show" do
        it "renders a successful response with stores" do
            store = FactoryBot.create(:store)
            sign_in store.user

            get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
            json = JSON.parse(response.body)

            expect(response).to have_http_status(:success)
            
            expect(json["name"]).to eq "Example Store"
        end

        it "renders an unsuccessful response" do
            store = FactoryBot.create(:store)

            get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
            json = JSON.parse(response.body)

            expect(response).to have_http_status(:unauthorized)
        end
    end
end