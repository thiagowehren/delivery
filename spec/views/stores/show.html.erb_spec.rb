require 'rails_helper'

RSpec.describe "stores/show", type: :view do
  before(:each) do
    assign( :store, FactoryBot.create(:store) )
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match("Example Store")
  end
end
