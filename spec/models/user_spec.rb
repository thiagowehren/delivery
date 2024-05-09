require 'rails_helper'

RSpec.describe User, type: :model do  
  describe "validations" do
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }
  end

  describe "associations" do
    it { should have_many(:stores) }
    it { should have_many(:orders) }
  end
end
