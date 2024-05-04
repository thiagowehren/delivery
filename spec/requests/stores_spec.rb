require 'rails_helper'

RSpec.describe "/stores", type: :request do
  let(:user) {
    user = User.new(
      email: "user@example.com", 
      password: "123456", 
      password_confirmation: "123456",
      role: :seller
    )
    user.save!
    user
  }

  let(:valid_attributes) {
    # skip("Add a hash of attributes valid for your model")
    {name: "Valid Restaurant Name", user: user}
  }

  let(:invalid_attributes) {
    # skip("Add a hash of attributes invalid for your model")
    {name: ""}
  }

  before {
    sign_in(user)
  }

  context "admin" do

    let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
    }

    before {
      Store.create(name: "Store 1", user: user)
      Store.create(name: "Store 2", user: user)

      sign_in(admin)
    }

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
          user_id: user.id
        }

        expect {
          post stores_url, params: {store: store_attributes } 
        }.to change(Store, :count).by(1)

        
        expect(Store.find_by(name: "Store 3").user).to eq user
      end
    end

    describe "belongs_to" do
      it "should not belong to admin users" do
        store = Store.create(name: "store", user: admin)
        expect(store).not_to be_valid
        expect(store.valid?).to be_falsey
        expect(store.errors.full_messages).to eq (["User must exist"])
      end
    end
  end

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
        # skip("Add a hash of attributes valid for your model")
        { name: "New Valid Restaurant Name" }
      }

      it "updates the requested store" do
        store = Store.create! valid_attributes
        patch store_url(store), params: { store: new_attributes }
        store.reload
        # skip("Add assertions for updated state")
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
end
