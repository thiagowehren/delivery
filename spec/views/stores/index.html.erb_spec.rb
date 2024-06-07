require 'rails_helper'

RSpec.describe "stores/index", type: :view do
  before(:each) do
    stores = Kaminari.paginate_array([
      FactoryBot.create(:store, name: "Example Store"),
      FactoryBot.create(:store, name: "Example Store")
    ]).page(1).per(25)
    assign(:stores, stores)
  end

  it "renders a list of stores" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Example Store".to_s), count: 2
  end
end
