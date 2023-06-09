require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:client)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to have_one(:wallet) }
    it { is_expected.to have_many(:stocks) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
