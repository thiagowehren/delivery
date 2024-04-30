require 'rails_helper'

RSpec.describe "post /sign_in", type: :request do
    let(:credential) {
        Credential.create_access(:buyer)
    }

    describe "POST /sign_in" do
        before do
            User.create!(
                email: "seller_user@example.com",
                password: "123456",
                password_confirmation: "123456",
                role: :seller
            )

            User.create!(
                email: "buyer_user@example.com",
                password: "123456",
                password_confirmation: "123456",
                role: :buyer
            )
        end

        it "prevents user with seller credentials to sign_in as buyer" do
            post(
                "/sign_in",
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => credential.key
                },
                params: {
                    login: {email: "seller_user@example.com",password: "123456"}
                }
           )
           expect(response).to be_unauthorized
        end

        it "lets user with buyer credentials to sign_in as buyer" do
            post(
                "/sign_in",
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => credential.key
                },
                params: {
                    login: {email: "buyer_user@example.com",password: "123456"}
                }
           )
           expect(response).to be_ok
        end
    end
end