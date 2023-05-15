require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:stock)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:wallet) }
    it { is_expected.to have_one(:client) }
  end

  describe 'validations' do
    it { should validate_presence_of(:uuid) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:status) }
  end

  describe 'aasm' do
    let(:stock) { create(:stock) }

    it { expect(stock).to have_state(:available) }
    it { expect(stock).to transition_from(:available).to(:locked).on_event(:lock) }
    it { expect(stock).to transition_from(:locked).to(:available).on_event(:available) }
  end
end
