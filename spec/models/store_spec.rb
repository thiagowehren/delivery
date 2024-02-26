require 'rails_helper'

RSpec.describe Store, type: :model do
  
  describe "validations" do
    it "should be valid with valid attributes" do
      store = Store.new(name: "templateTest Store")
      expect(store).to be_valid
    end

    it "should not be valid without a name" do
      store = Store.new(name: nil)
      expect(store).not_to be_valid
      expect(store.errors[:name]).to include("can't be blank")
    end

    it "is not valid with a name shorter than 3 characters" do
      store = Store.new(name: "te")
      expect(store).not_to be_valid
      expect(store.errors[:name]).to include("is too short (minimum is 3 characters)")
    end
  end
end
