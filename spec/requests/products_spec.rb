require 'rails_helper'

RSpec.describe "/stores/:store_id/products", type: :request do
  let(:seller) { FactoryBot.create(:seller_user, email: "seller@example.com") }
  let(:seller_not_owner) { FactoryBot.create(:seller_user, email: "seller2@example.com") }
  let(:buyer) { FactoryBot.create(:buyer_user, email: "buyer@example.com") }
  let(:admin) { FactoryBot.create(:admin_user, email: "admin@example.com") }
  
  let(:valid_product_attributes) { { title: "Valid Product Name", price: 9.99 } }
  let(:invalid_product_attributes) { { title: "", price: 9.99 } }


  describe "GET #index /stores/:id/products/" do
    
    context "as store owner" do
      
      before { sign_in(seller) }

      it "renders a successful response and lists products from store" do
        store = FactoryBot.create(:store, user: seller)
        FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])
  
        get store_products_url(store)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
      end
      
    end

    context "as non owner" do
      
      before { sign_in(seller_not_owner) }

      it "redirects sellers from seeing products from non owned stores" do
        store = FactoryBot.create(:store, user: seller)
        FactoryBot.create(:product, store: store)
  
        get store_products_url(store)
        expect(response).to redirect_to(stores_url)
        expect(flash[:alert]).to eq("User doesn't match with store Owner.")
      end
      
    end

    context "as admin" do
      before { sign_in(admin) }

      it "renders a successful response and lists products from store" do
        store = FactoryBot.create(:store, user: seller)
        FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])
  
        get store_products_url(store)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
      end
    end

    context "as buyer" do
      before { sign_in(buyer) }

      it "renders a successful response and lists products from store" do
        store = FactoryBot.create(:store, user: seller)
        FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])
  
        get store_products_url(store)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
      end
    end

    context "when there's no products" do
      before { sign_in(admin) }

      it "renders response with 'empty'" do
        store = FactoryBot.create(:store, user: seller)
  
        get store_products_url(store)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Empty")
      end
    end
  end

  describe "GET #show /stores/:id/products/:id" do
  include ActionView::Helpers::NumberHelper
    context "as store owner" do
      before { sign_in(seller) }

      it "renders a successful response" do
        store = FactoryBot.create(:store, user: seller)
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title], price: valid_product_attributes[:price])

        get store_product_url(store, product)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
        
        formatted_price = case I18n.locale
        when :'pt-BR'
          number_with_precision(valid_product_attributes[:price], precision: 2, separator: ',')
        when :'en'
          number_with_precision(valid_product_attributes[:price], precision: 2)
        else
          number_with_precision(valid_product_attributes[:price], precision: 2)
        end
        expect(response.body).to include(formatted_price)

      end
    end

    context "as non-owner" do
      before { sign_in(seller_not_owner) }

      it "redirects seller if product is not from their store" do
        store = FactoryBot.create(:store, user: seller)
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])

        get store_product_url(store, product)
        expect(response).to redirect_to(stores_url)
        expect(flash[:alert]).to eq("User doesn't match with store Owner.")
      end
    end

    context "as admin" do
      before { sign_in(admin) }

      it "renders a successful response" do
        store = FactoryBot.create(:store, user: seller)
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])

        get store_product_url(store, product)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
      end
    end

    context "as buyer" do
      before { sign_in(buyer) }

      it "renders a successful response" do
        store = FactoryBot.create(:store, user: seller)
        product = FactoryBot.create(:product, store: store, title: valid_product_attributes[:title])

        get store_product_url(store, product)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(valid_product_attributes[:title])
      end
    end

    context "when the store does not exist" do
      before { sign_in(admin) }
  
      it "renders a 404 not found response" do
        get store_product_url(store_id: "nonexistent", id: "any")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the product exists but does not belong to the store/:id/products" do

      let(:store) { FactoryBot.create(:store, user: seller) }

      let(:store2) { FactoryBot.create(:store, user: seller_not_owner) }
      let(:product2) { FactoryBot.create(:product, store: store2, title: valid_product_attributes[:title]) }

      context "while logged in as the owner of store/:id/products/" do
        before { sign_in(seller) }
    
        it "redirects to the store's products page with an error message" do
          get store_product_url(store, product2)
    
          expect(response).to redirect_to(store_products_path(store))
          expect(flash[:alert]).to eq("Product is not from this store.")
        end
      end
    
      context "while logged in as a seller who is not the owner of store/:id/products/" do
        before { sign_in(seller_not_owner) }
    
        it "redirects to the stores index with an error message" do
          get store_product_url(store, product2)
    
          expect(response).to redirect_to(stores_path)
          expect(flash[:alert]).to eq("User doesn't match with store Owner.")
        end
      end
    
      context "while logged in as a buyer" do
        before { sign_in(buyer) }
    
        it "redirects to the store's products page with an error message" do
          get store_product_url(store, product2)
    
          expect(response).to redirect_to(store_products_path(store))
          expect(flash[:alert]).to eq("Product is not from this store.")
        end
      end
    
      context "while logged in as an admin" do
        before { sign_in(admin) }
    
        it "redirects to the store's products page with an error message" do
          get store_product_url(store, product2)
    
          expect(response).to redirect_to(store_products_path(store))
          expect(flash[:alert]).to eq("Product is not from this store.")
        end
      end
    end

  end

  context "GET #listing /listing" do
    context "when the user is an admin" do
      before { sign_in(admin) }
  
      it "allows access to the listing page" do
        get listing_url
  
        expect(response).to have_http_status(:ok)
      end
    end
  
    context "when the user is not an admin" do

      context "as seller" do

        before { sign_in(seller) }
  
        it "redirects to the stores page with an unauthorized message" do
          get listing_url
    
          expect(response).to redirect_to(stores_path)
          expect(flash[:alert]).to eq("Unauthorized.")
        end
      end

      context "as buyer" do
        before { sign_in(buyer) }
  
        it "redirects to the stores page with an unauthorized message" do
          get listing_url
    
          expect(response).to redirect_to(stores_path)
          expect(flash[:alert]).to eq("Unauthorized.")
        end
      end
    end

  end

  context "GET /products/:id" do
    let(:store) { FactoryBot.create(:store) }
    let(:product) { FactoryBot.create(:product, store: store) }
    before{sign_in(buyer)}
  
    context "when the product exists" do
      it "redirects to the store's product page" do
        get "/products/#{product.id}"
  
        expect(response).to redirect_to(store_product_path(store, product))
      end
    end
  
    context "when the product does not exist" do
      it "returns a 404 not found response" do
        get "/products/nonexistent"
  
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create /stores/:store_id/products" do
    let(:store) { FactoryBot.create(:store, user: seller) }

    context "when logged in as store owner" do
      before { sign_in(seller) }

      context "with valid attributes" do
        it "creates a new product" do
          expect {
            post store_products_path(store), params: { product: valid_product_attributes }
          }.to change(Product, :count).by(1)

          expect(response).to redirect_to(store_products_path(store))
        end
      end

      context "with invalid attributes" do
        it "does not create a new product" do
          expect {
            post store_products_path(store), params: { product: invalid_product_attributes }
          }.not_to change(Product, :count)

        expect(response).not_to be_successful
        end
      end
    end

    context "when logged in as admin" do
      before { sign_in(admin) }

      it "creates a new product" do
        expect {
          post store_products_path(store), params: { product: valid_product_attributes }
        }.to change(Product, :count).by(1)

        expect(response).to redirect_to(store_products_path(store))
      end
    end

    context "when logged in as non owner" do
      before { sign_in(seller_not_owner) }

      it "does not create a new product" do
        expect {
          post store_products_path(store), params: { product: valid_product_attributes }
        }.to_not change(Product, :count)

        expect(response).to_not be_successful
      end
    end
  end

  describe "PATCH #update /stores/:store_id/products/:id" do
    let(:store) { FactoryBot.create(:store, user: seller) }
    let(:product) { FactoryBot.create(:product, store: store ) }

    context "when logged in as store owner" do
      before { sign_in(seller) }

      context "with valid attributes" do
        it "updates the product" do
          patch store_product_path(store, product), params: { product: valid_product_attributes }

          product.reload
          expect(product.title).to eq('Valid Product Name')
          expect(product.price).to eq(9.99)
          expect(response).to redirect_to(store_products_path(store))
        end
      end

      context "with invalid attributes" do
        it "does not update the product" do
          patch store_product_path(store, product), params: { product: invalid_product_attributes }

          product.reload
          expect(product.title).not_to eq('')
          expect(response).not_to be_successful
        end
      end
    end

    context "when logged in as admin" do
      before { sign_in(admin) }

      it "updates the product" do
        patch store_product_path(store, product), params: { product: valid_product_attributes }

        product.reload
        expect(product.title).to eq('Valid Product Name')
        expect(product.price).to eq(9.99)
        expect(response).to redirect_to(store_products_path(store))
      end
    end

    context "when logged in as non owner" do
      before { sign_in(seller_not_owner) }

      it "does not update the product" do
        patch store_product_path(store, product), params: { product: valid_product_attributes }

        product.reload
        expect(product.title).not_to eq('Valid Product Name')
        expect(product.price).not_to eq(9.99)
        expect(response).to_not be_successful
      end
    end
  end

  describe "DELETE #destroy /stores/:store_id/products/:id" do
    #let! forces block execution before each test also p reventing lazy loading
    let!(:store) { FactoryBot.create(:store, user: seller) }
    let!(:product) { FactoryBot.create(:product, store: store ) }

    context "when logged in as store owner" do
      before { sign_in(seller) }

      it "deletes the product" do
        expect {
          delete store_product_path(store, product)
        }.to change(Product, :count).by(-1)

        expect(response).to redirect_to(store_products_path(store))
      end
    end

    context "when logged in as admin" do
      before { sign_in(admin) }

      it "deletes the product" do
        expect {
          delete store_product_path(store, product)
        }.to change(Product, :count).by(-1)

        expect(response).to redirect_to(store_products_path(store))
      end
    end

    context "when logged in as non owner" do
      before { sign_in(seller_not_owner) }

      it "does not delete the product" do
        expect {
          delete store_product_path(store, product)
        }.not_to change(Product, :count)

        expect(response).to_not be_successful
      end
    end
  end
end
