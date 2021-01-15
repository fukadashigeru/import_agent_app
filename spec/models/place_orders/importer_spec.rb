require 'rails_helper'

RSpec.describe PlaceOrders::Importer do
  describe '#call' do
    subject { importer.call }
    let(:importer) do
      described_class.new(
        io: io
      )
    end

    let(:io) { File.open('spec/fixtures/models/place_orders/order_template.csv') }

    context 'Orderの生成数' do
      it 'Orderレコードが10個生成されているはず' do
        expect { subject }.to change { Order.count }.by(10)
      end
    end
  end
end
