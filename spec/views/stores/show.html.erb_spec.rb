require 'rails_helper'

RSpec.describe "stores/show", type: :view do
  include Devise::Test::ControllerHelpers

  let(:store){
    FactoryBot.create(:store)
  }

  before(:each) do
    assign(:store, store)
    sign_in store.user
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match("Example Store")
  end
end
