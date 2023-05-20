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
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'aasm' do
    let(:stock) { create(:stock) }

    it { expect(stock).to have_state(:available) }
    it { expect(stock).to transition_from(:available).to(:on_sale).on_event(:sale) }
    it { expect(stock).to transition_from(:on_sale).to(:available).on_event(:available) }
  end

  describe 'scopes' do
    let(:wallet) { create(:wallet) }

    before do
      create_list(:stock, 5, wallet: wallet)
      create_list(:stock, 5, wallet: wallet, status: :on_sale)
    end

    describe 'available' do
      it { expect(Stock.available.count).to eq(5) }
    end

    describe 'on_sale' do
      it { expect(Stock.on_sale.count).to eq(5) }
    end
  end
end
