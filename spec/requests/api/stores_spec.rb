require "rails_helper"

RSpec.describe "/stores", type: :request do
    
    let(:seller) { FactoryBot.create(:seller_user, email: "seller@example.com") }
    let(:seller_not_owner) { FactoryBot.create(:seller_user, email: "seller_not_owner@example.com") }
    let(:buyer) { FactoryBot.create(:buyer_user, email: "buyer@example.com") }

    let(:credential_seller){ Credential.create_access(:seller) }
    let(:credential_buyer){ Credential.create_access(:buyer) }

    let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
    let(:signed_in_non_owner) { api_sign_in(seller_not_owner, credential_seller) }
    let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }

    context "store CRUD" do

        let(:valid_store_attributes){ {name: "Example Store"} }
        let(:invalid_store_attributes){ {name: ""} }

        describe "GET /show" do
            it "renders a succesful response with stores data" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                get(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                json = JSON.parse(response.body)

                expect(response).to have_http_status(:success)
                expect(json["name"]).to eq "Example Store"
            end

            it "renders a successful response for buyer accessing store1 data" do
                store = Store.create! valid_store_attributes.merge(user: seller)
    
                get(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )
                json = JSON.parse(response.body)
    
                expect(response).to have_http_status(:success)
                expect(json["name"]).to eq "Example Store"
            end

            it "renders an unsuccessful response for seller non-owner accessing seller store data" do
                store = Store.create! valid_store_attributes.merge(user: seller)
    
                get(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_non_owner["token"]}"
                    }
                )
                expect(response).to have_http_status(:unauthorized)
            end

            it "renders an unsuccessful response for unauthenticated user accessing store data" do
                store = FactoryBot.create(:store)

                get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
                json = JSON.parse(response.body)

                expect(response).to have_http_status(:unauthorized)
            end
        end
        
        describe "POST /create" do
            it "creates a store for seller" do
                expect {
                  post(
                    "/stores",
                    params: { store: valid_store_attributes },
                    headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                  )
                }.to change(Store, :count).by(1)

                store_id = JSON.parse(response.body)['id']
                owner = Store.find(store_id).user
                
                expect(owner.id).to eq(seller.id)
                expect(response).to have_http_status(:created)
            end

            it "fails to create a store while logged in as buyer" do
                expect {
                  post(
                    "/stores",
                    params: { store: valid_store_attributes },
                    headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                  )
                }.to change(Store, :count).by(0)
                
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end

        describe "PATCH /update" do
            let(:new_attributes) { { name: "Updated Store Name" } }

            it "updates a store for seller" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                patch(
                    "/stores/#{store.id}",
                    params: { store: new_attributes },
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                store.reload
                expect(store.name).to eq("Updated Store Name")
                expect(response).to have_http_status(:ok)
            end

            it "fails to update a store for non owner" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                patch(
                    "/stores/#{store.id}",
                    params: { store: new_attributes },
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_non_owner["token"]}"
                    }
                )
                expect(response).to have_http_status(:unauthorized)
            end

            it "fails to update a store for buyer" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                patch(
                    "/stores/#{store.id}",
                    params: { store: new_attributes },
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )
                expect(response).to have_http_status(:unauthorized)
            end
        end

        describe "DELETE /destroy" do
            it "destroys a store for seller" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                expect {
                    delete(
                        "/stores/#{store.id}",
                        headers: {
                            "Accept" => "application/json",
                            "Authorization" => "Bearer #{signed_in_seller["token"]}"
                        }
                    )
                }.to change(Store, :count).by(-1)
                expect(response).to have_http_status(:no_content)
            end
    
            it "fails to destroy a store for non owner" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                expect {
                    delete(
                        "/stores/#{store.id}",
                        headers: {
                            "Accept" => "application/json",
                            "Authorization" => "Bearer #{signed_in_non_owner["token"]}"
                        }
                    )
                }.to change(Store, :count).by(0)
                expect(response).to have_http_status(:unauthorized)
            end
    
            it "fails to destroy a store for buyer" do
                store = Store.create! valid_store_attributes.merge(user: seller)
                expect {
                    delete(
                        "/stores/#{store.id}",
                        headers: {
                            "Accept" => "application/json",
                            "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                        }
                    )
                }.to change(Store, :count).by(0)
                expect(response).to have_http_status(:unauthorized)
            end
        end

        describe "GET /index" do
            it "renders a successful response with their stores for the seller" do
                Store.create! valid_store_attributes.merge(user: seller)
                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                json = JSON.parse(response.body)
                expect(json["stores"].length).to eq(1)
                expect(response).to have_http_status(:success)
            end
    
            it "renders a successful response with zero store for non owner seller" do
                Store.create! valid_store_attributes.merge(user: seller)
                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_non_owner["token"]}"
                    }
                )
                json = JSON.parse(response.body)
                expect(json["stores"].length).to eq(0)
                expect(response).to have_http_status(:success)
            end
    
            it "renders a successful response with all stores for the buyer" do
                Store.create! valid_store_attributes.merge(user: seller)
                Store.create! valid_store_attributes.merge(user: seller_not_owner)
                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )
                json = JSON.parse(response.body)
                expect(json.length).to eq(2)
                expect(response).to have_http_status(:success)
            end
        end
    end#context store CRUD

end#rspec