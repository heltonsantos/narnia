require 'rails_helper'

RSpec.describe PurchaseOrder, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:purchase_order)).to be_valid }
    it { expect(build(:purchase_order).type).to eq('PurchaseOrder') }
  end

  context 'with relationships' do
    it { is_expected.to have_many(:stocks) }
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:stock_kind) }
    it { is_expected.to validate_presence_of(:expired_at) }
  end
end
