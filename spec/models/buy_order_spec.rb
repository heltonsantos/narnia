require 'rails_helper'

RSpec.describe BuyOrder, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:buy_order)).to be_valid }
    it { expect(build(:buy_order).type).to eq('BuyOrder') }
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

  describe 'aasm' do
    let(:order) { create(:buy_order) }

    it { expect(order).to have_state(:pending) }
    it { expect(order).to transition_from(:pending).to(:processing).on_event(:process) }
    it { expect(order).to transition_from(:processing).to(:completed).on_event(:complete) }
    it { expect(order).to transition_from(:processing).to(:partial_completed).on_event(:partial_complete) }
    it { expect(order).to transition_from(:processing).to(:failed).on_event(:fail) }
    it { expect(order).to transition_from(:processing).to(:expired).on_event(:expire) }
    it { expect(order).to transition_from(:processing).to(:retrying).on_event(:retry) }
  end
end
