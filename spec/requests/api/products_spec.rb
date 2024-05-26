require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:seller) { FactoryBot.create(:seller_user, email: "seller@example.com") }
  let(:seller_not_owner) { FactoryBot.create(:seller_user, email: "seller2@example.com") }
  let(:buyer) { FactoryBot.create(:buyer_user, email: "buyer@example.com") }

  let(:credential_seller) { Credential.create_access(:seller) }
  let(:credential_buyer) { Credential.create_access(:buyer) }


  let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
  let(:signed_in_non_owner) { api_sign_in(seller_not_owner, credential_seller) }
  let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }

  let(:valid_product_attributes) { { title: "Valid Product Name", price: 9.99 } }
  let(:invalid_product_attributes) { { title: "", price: 9.99 } }

  def api_headers(signed_in_user)
    {
      "Accept" => "application/json",
      "Authorization" => "Bearer #{signed_in_user['token']}"
    }
  end

  describe "GET #index /stores/:id/products/" do

    let(:store) { FactoryBot.create(:store, user: seller) }

    context "when logged in as store owner" do
      it "renders a successful response and lists products from store" do
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])

        get store_products_path(store), headers: api_headers(signed_in_seller)
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["products"].any? { |p| p["title"] == valid_product_attributes[:title] }).to be true
      end

      it "renders a successful response and lists products from empty store" do
        get store_products_path(store), headers: api_headers(signed_in_seller)
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["products"].empty?).to eq true
      end
    end

    context "when logged in as non-owner" do
      it "renders an unauthorized response" do
        get store_products_path(store), headers: api_headers(signed_in_non_owner)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when logged in as buyer" do
      it "renders a successful response and lists products from store" do
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])

        get store_products_path(store), headers: api_headers(signed_in_buyer)
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["products"].any? { |p| p["title"] == valid_product_attributes[:title] }).to be true
      end
    end
  end

  describe "GET #show /stores/:store_id/products/:id" do

    let(:store) { FactoryBot.create(:store, user: seller) }

    context "when logged in as store owner" do
      it "renders a successful response" do
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title], price: valid_product_attributes[:price])
        
        get store_product_path(store, product), headers: api_headers(signed_in_seller)
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["title"]).to eq(valid_product_attributes[:title])
        expect(json["price"].to_f).to eq(valid_product_attributes[:price])
      end
    end

    context "when logged in as non-owner" do
      it "renders an unauthorized response" do
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title], price: valid_product_attributes[:price])

        get store_products_path(store, product), headers: api_headers(signed_in_non_owner)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when logged in as buyer" do
      it "renders a successful response and lists products from store" do
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title], price: valid_product_attributes[:price])
        
        get store_product_path(store, product), headers: api_headers(signed_in_buyer)
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["title"]).to eq(valid_product_attributes[:title])
        expect(json["price"].to_f).to eq(valid_product_attributes[:price])
      end
    end

    context "when the product does not belong to the store" do
      let(:store2) { FactoryBot.create(:store, user: seller_not_owner) }
      let(:product2) { FactoryBot.create(:product, store: store2) }

      context "when owner search the product on his store/:id" do
        it "renders a unprocessable entity response" do
          get store_product_path(store, product2), headers: api_headers(signed_in_seller)
          
          json = JSON.parse(response.body)
          error_message = json["error"]["message"]

          expect(error_message).to eq("Product is not from this store.")

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when a seller searches the product on a non owned store" do
        it "renders a unauthorized response" do
          get store_product_path(store, product2), headers: api_headers(signed_in_non_owner)
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when a buyer searches the product" do
        it "renders a unprocessable entity response" do
          get store_product_path(store, product2), headers: api_headers(signed_in_buyer)
          
          json = JSON.parse(response.body)
          error_message = json["error"]["message"]

          expect(error_message).to eq("Product is not from this store.")

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when product doesn't exist" do
      it "renders a not_found response" do
        get store_product_path(store, "non_existent_product_id"), headers: api_headers(signed_in_buyer)
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #listing /listing" do
    context "when the user is not an admin" do
      
      it "renders an unauthorized response" do
        sign_in_ways = [signed_in_seller, signed_in_buyer]
        sign_in_ways.each do |sign_in_user|
          get listing_url, headers: api_headers(sign_in_user)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe "GET /products/:id" do
    let(:store) { FactoryBot.create(:store) }
    
    context "when the product exists" do
      let(:product) { FactoryBot.create(:product, store: store) }

      it "redirects to the store's product page" do
        sign_in_ways = [signed_in_seller, signed_in_buyer]
        sign_in_ways.each do |sign_in_user|
          get "/products/#{product.id}", headers: api_headers(sign_in_user)
          expect(response).to redirect_to(store_product_path(store, product))
        end
      end
    end

    context "when the product doesn't exists" do
      it "renders a not found response" do
        sign_in_ways = [signed_in_seller, signed_in_buyer]
        sign_in_ways.each do |sign_in_user|
          get "/products/non_existent_product_id", headers: api_headers(sign_in_user)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "POST #create /stores/:store_id/products" do
    let(:store) { FactoryBot.create(:store, user: seller) }
    
    context "when logged in as store owner" do
      it "creates a new product with valid attributes" do
        expect {
          post store_products_path(store), params: { product: valid_product_attributes }, headers: api_headers(signed_in_seller)
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "does not create a new product with invalid attributes" do
        expect {
          post store_products_path(store), params: { product: invalid_product_attributes }, headers: api_headers(signed_in_seller)
        }.not_to change(Product, :count)

        expect(response).to have_http_status(:unprocessable_entity) || have_http_status(:unprocessable_content)
      end
    end

    context "when is not logged in as owner" do
      it "renders an unauthorized response" do
        sign_in_ways = [signed_in_non_owner, signed_in_buyer]

        sign_in_ways.each do |sign_in_user|
          post store_products_path(store), params: { product: valid_product_attributes }, headers: api_headers(sign_in_user)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe "PATCH/PUT #update /stores/:store_id/products/:id" do
    let(:store) { FactoryBot.create(:store, user: seller) }
    let(:product) { FactoryBot.create(:product, store: store) }
    
    context "when logged in as store owner" do
      it "updates the product with valid attributes" do
        patch store_product_path(store, product), params: { product: valid_product_attributes }, headers: api_headers(signed_in_seller)
        product.reload

        expect(product.title).to eq("Valid Product Name")
        expect(product.price).to eq(9.99)
        expect(response).to have_http_status(:ok)
      end

      it "does not update the product with invalid attributes" do
        patch store_product_path(store, product), params: { product: invalid_product_attributes }, headers: api_headers(signed_in_seller)
        product.reload

        expect(product.title).not_to eq(invalid_product_attributes["title"])
        expect(response).to have_http_status(:unprocessable_entity) || have_http_status(:unprocessable_content)
      end
    end

    context "when is not logged in as owner" do
      it "renders an unauthorized response" do
        sign_in_ways = [signed_in_non_owner, signed_in_buyer]

        sign_in_ways.each do |sign_in_user|
          patch store_product_path(store, product), params: { product: valid_product_attributes }, headers: api_headers(sign_in_user)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe "DELETE destroy: /stores/:store_id/products/:id" do
    let(:store) { FactoryBot.create(:store, user: seller) }
    let(:product) { FactoryBot.create(:product, store: store) }

    context "when logged in as store owner" do
      it "updates the product with valid attributes" do
        delete store_product_path(store, product), headers: api_headers(signed_in_seller)
        
        expect(response).to have_http_status(:no_content)
        expect(Product.exists?(product.id)).to be(false)
      end
    end

    context "when is not logged in as owner" do
      it "renders an unauthorized response" do
        sign_in_ways = [signed_in_non_owner, signed_in_buyer]

        sign_in_ways.each do |sign_in_user|
          delete store_product_path(store, product), headers: api_headers(sign_in_user)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
