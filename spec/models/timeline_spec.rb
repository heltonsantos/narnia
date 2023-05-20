require 'rails_helper'

RSpec.describe Timeline, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:timeline)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:timelineref) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_inclusion_of(:action).in_array(Timeline::ORDER_ACTIONS + Timeline::STOCK_ACTIONS) }
  end
end
