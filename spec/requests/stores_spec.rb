require 'rails_helper'

RSpec.describe "/stores", type: :request do
  

  context "admin" do
    let(:seller) { FactoryBot.create(:seller_user, email: "user@example.com")}
    let(:admin) {FactoryBot.create(:admin_user, email: "admin@example.com")}
    
    let(:valid_attributes) { {name: "Valid Restaurant Name", user: seller} }
    let(:invalid_attributes) { {name: ""} }

    before {
      Store.create(name: "Store 1", user: seller)
      Store.create(name: "Store 2", user: seller)
      sign_in(admin)
    }

    describe "belongs_to" do
      it "should not belong to admin users" do
        I18n.with_locale(:en) do
          store = Store.create(name: "store", user: admin)
          expect(store).not_to be_valid
          expect(store.valid?).to be_falsey
          expect(store.errors.full_messages).to eq (["User must exist"])
        end
      end
    end

    describe "GET /index" do
      it "renders a successful response" do
        get stores_url
        expect(response). to be_successful
        expect(response.body).to include "Store 1"
        expect(response.body).to include "Store 2"
      end
    end

    describe "POST /create" do
      it "NEW creates a new Store" do
        store_attributes = {
          name: "Store 3",
          user_id: seller.id
        }

        expect {
          post stores_url, params: {store: store_attributes } 
        }.to change(Store, :count).by(1)

        expect(Store.find_by(name: "Store 3").user).to eq seller
      end
    end
    
    describe "GET /edit" do
      context "when the store does exist" do
        it "renders a successful response for an existing store" do
          store = Store.create!(name: "Example Store", user: seller)
          get edit_store_url(store)
          expect(response).to be_successful
        end
      end
      
      context "when the store does not exist" do
        it "renders a not found response for a non-existent store" do
          get edit_store_url(id: "non-existent-id")
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {
          { name: "New Store Name" }
        }
    
        it "updates the requested store for admin" do
          store = Store.create!(name: "Example Store", user: seller)
          patch store_url(store), params: { store: new_attributes }
          store.reload
          expect(store.name).to eq(new_attributes[:name])
        end
      end

      context "with invalid parameters" do
        it "does not update the requested store" do
          store = Store.create!(name: "Example Store", user: seller)
          patch store_url(store), params: { store: invalid_attributes }
          store.reload
          expect(store.name).to eq("Example Store")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /destroy" do
      context "when the store does exist" do
        it "destroys the requested store for admin" do
          store = Store.create! valid_attributes

          expect {
            delete store_url(store)
          }.to change(Store, :count).by(-1)
        end
      end

      context "when the store does not exist" do
        it "returns a not found response" do
          delete store_url(id: "non-existent-id")
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include("Store not found")
        end
      end
    end
    
  end#context admin

  context "seller" do
    let(:seller) { FactoryBot.create(:seller_user, email: "user@example.com")}
    let(:non_owner_seller) { FactoryBot.create(:seller_user, email: "user2@example.com")}

    let(:valid_attributes) { {name: "Valid Restaurant Name", user: seller} }
    let(:invalid_attributes) { {name: ""} }
    
    context "as owner" do
      before { sign_in(seller) }
  
      describe "GET /index" do
        it "renders a successful response" do
          Store.create! valid_attributes
          get stores_url
          expect(response).to be_successful
        end
      end
  
      describe "GET /show" do
        it "renders a successful response" do
          store = Store.create! valid_attributes
          get store_url(store)
          expect(response).to be_successful
        end
      end
  
      describe "GET /new" do
        it "renders a successful response" do
          get new_store_url
          expect(response).to be_successful
        end
      end
  
      describe "GET /edit" do
        it "renders a successful response" do
          store = Store.create! valid_attributes
          get edit_store_url(store)
          expect(response).to be_successful
        end
      end
  
      describe "POST /create" do
        context "with valid parameters" do
          it "creates a new Store" do
            expect {
              post stores_url, params: { store: valid_attributes }
            }.to change(Store, :count).by(1)
          end
  
          it "redirects to the created store" do
            post stores_url, params: { store: valid_attributes }
            expect(response).to redirect_to(store_url(Store.last))
          end
        end
  
        context "with invalid parameters" do
          it "does not create a new Store" do
            expect {
              post stores_url, params: { store: invalid_attributes }
            }.to change(Store, :count).by(0)
          end
  
        
          it "renders a response with 422 status (i.e. to display the 'new' template)" do
            post stores_url, params: { store: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        
        end
      end
  
      describe "PATCH /update" do
        context "with valid parameters" do
          let(:new_attributes) {
            { name: "New Valid Restaurant Name" }
          }
  
          it "updates the requested store" do
            store = Store.create! valid_attributes
            patch store_url(store), params: { store: new_attributes }
            store.reload
            expect(store.name).to eq(new_attributes[:name])
          end
  
          it "redirects to the store" do
            store = Store.create! valid_attributes
            patch store_url(store), params: { store: new_attributes }
            store.reload
            expect(response).to redirect_to(store_url(store))
          end
        end
  
        context "with invalid parameters" do
          it "renders a response with 422 status (i.e. to display the 'edit' template)" do
            store = Store.create! valid_attributes
            patch store_url(store), params: { store: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end
    
        end
      end
  
      describe "DELETE /destroy" do
        it "destroys the requested store" do
          store = Store.create! valid_attributes
          expect {
            delete store_url(store)
          }.to change(Store, :count).by(-1)
        end
  
        it "redirects to the stores list" do
          store = Store.create! valid_attributes
          delete store_url(store)
          expect(response).to redirect_to(stores_url)
        end
      end
    end#context as owner
  
    context "as not owner" do
      let(:valid_attributes) { {name: "Valid Restaurant Name", user: seller} }
      before { sign_in(non_owner_seller) }

      describe "GET /index" do
        it "renders a successful response" do
          store = Store.create! valid_attributes
          get stores_url
          expect(response).to be_successful
          expect(response.body).not_to include("Valid Restaurant Name")
        end
      end

      describe "GET /show" do
        it "redirects to the stores list with alert" do
          store = Store.create! valid_attributes
          get store_url(store)
          expect(response).to redirect_to(stores_url)
          expect(flash[:alert]).to eq("User doesn't match with store Owner")
        end
      end

      describe "GET /new" do
        it "renders a successful response" do
          get new_store_url
          expect(response).to be_successful
        end
      end

      describe "GET /edit" do
        it "redirects to the stores list with alert" do
          store = Store.create! valid_attributes
          get edit_store_url(store)
          expect(response).to redirect_to(stores_url)
          expect(flash[:alert]).to eq("User doesn't match with store Owner")
        end
      end

      describe "POST /create" do
        context "with valid parameters" do
          it "fails to assign another owner when creating a store" do
            expect {
              post stores_url, params: { store: valid_attributes.merge(user: seller) }
            }.to change(Store, :count).by(1)
            expect(Store.last.user).to_not eq(seller)
            expect(Store.last.user).to eq(non_owner_seller)
          end
        end
      end

      describe "PATCH /update" do

        context "with valid parameters" do
          it "redirects to the stores list with alert" do
            store = Store.create! valid_attributes
            patch store_url(store), params: { store: valid_attributes }
            expect(response).to redirect_to(stores_url)
            expect(flash[:alert]).to eq("User doesn't match with store Owner")
          end
        end
      end

      describe "DELETE /destroy" do
        it "redirects to the stores list with alert" do
          store = Store.create! valid_attributes
          delete store_url(store)
          expect(response).to redirect_to(stores_url)
          expect(flash[:alert]).to eq("User doesn't match with store Owner")
        end

        it "returns a not found response when the store does not exist" do
          delete store_url(id: "non-existent-id")
          expect(response).to have_http_status(:not_found)
        end
      end
    end #context non-owner
  end #context seller
end#rspec
