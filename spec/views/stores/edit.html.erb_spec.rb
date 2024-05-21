require 'rails_helper'

RSpec.describe "stores/edit", type: :view do
  include Devise::Test::ControllerHelpers

  let(:store) {
    FactoryBot.create(:store)
  }

  before(:each) do
    assign(:store, store)
    sign_in store.user
  end
  
  it "renders the edit store form" do
    render

    assert_select "form[action=?][method=?]", store_path(store), "post" do

      assert_select "input[name=?]", "store[name]"
    end
  end
end
