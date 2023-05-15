require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:order)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to have_many(:stocks) }
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    it { should validate_presence_of(:uuid) }
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:quantity) }
  end

  describe 'aasm' do
    let(:order) { create(:order) }

    it { expect(order).to have_state(:pending) }
    it { expect(order).to transition_from(:pending).to(:processing).on_event(:process) }
    it { expect(order).to transition_from(:processing).to(:completed).on_event(:complete) }
    it { expect(order).to transition_from(:processing).to(:partial_completed).on_event(:partial_complete) }
    it { expect(order).to transition_from(:processing).to(:failed).on_event(:fail) }
  end
end
