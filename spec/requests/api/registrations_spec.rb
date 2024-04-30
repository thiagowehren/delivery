require 'rails_helper'

RSpec.describe "/stores", type: :request do
    let(:credential) {
        Credential.create_access(:buyer)
    }

    describe "POST /new" do

        it "creates a buyer user" do
            post(
                create_registration_url,
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => credential.key
                },
                params: {
                    user: {
                        email: "buyer_user@example.com",
                        password: "123456",
                        password_confirmation: "123456"
                    }
                }
           )
            user = User.find_by(email: "buyer_user@example.com")

            expect(response).to be_successful
            expect(user).to be_buyer
        end

        it "fails to create user without credentials" do
            post(
                create_registration_url,
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => ''
                },
                params: {
                    user: {
                    email: "admin_user@example.com",
                    password: "123456",
                    password_confirmation: "123456"
                    }
                }
           )
                
           expect(response).to be_unprocessable
        end
        
        it "fails when trying to create admin user on /new" do
            post(
                create_registration_url,
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => ''
                },
                params: {
                    user: {
                    email: "admin_user@example.com",
                    password: "123456",
                    password_confirmation: "123456",
                    role: :admin
                    }
                }
           )
                
           expect(response).to be_unprocessable
        end
    end
end