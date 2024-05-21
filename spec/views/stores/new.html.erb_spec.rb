require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  include Devise::Test::ControllerHelpers
  
  let(:store){
    Store.new(name: "MyString")
  }
  
  let(:user) {
    FactoryBot.create(:seller_user)
  }
  
  before(:each) do
    sign_in user
    assign(:store, store)
  end
  it "renders new store form" do
    render

    assert_select "form[action=?][method=?]", stores_path, "post" do

      assert_select "input[name=?]", "store[name]"
    end
  end
end
