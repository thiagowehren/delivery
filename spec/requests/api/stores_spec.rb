require "rails_helper"

RSpec.describe "/stores", type: :request do
    
    let(:user){
        user = User.new(
            email: "seller_user@exmaple.com",
            password: "123456",
            password_confirmation: "123456",
            role: :seller
        )
    }

    let(:valid_store_attributes){
        {name: "Example Store", user: user}
    }

    let(:credential){
        Credential.create_access(:seller)
    }

    let(:signed_in) { api_sign_in(user, credential)}


    describe "GET /show" do

        it "renders a succesful response with stores data" do
            store = Store.create! valid_store_attributes
            get(
                "/stores/#{store.id}",
                headers: {
                    "Accept" => "application/json",
                    "Authorization" => "Bearer #{signed_in["token"]}"
                }
            )
            json = JSON.parse(response.body)

            expect(response).to have_http_status(:success)
            expect(json["name"]).to eq "Example Store"
        end

        it "renders an unsuccessful response for unauthenticated user accessing store data" do
            store = FactoryBot.create(:store)

            get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
            json = JSON.parse(response.body)

            expect(response).to have_http_status(:unauthorized)
        end
    end
end