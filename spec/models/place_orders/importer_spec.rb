require 'rails_helper'

RSpec.describe PlaceOrders::Importer do
  describe '#call' do
    subject { importer.call }
    let(:importer) do
      described_class.new(
        io: io,
        ordering_org: ordering_org,
        shop_type: shop_type
      )
    end
    # let(:io) { File.open('spec/fixtures/models/place_orders/order_template.csv') }
    let(:io) { StringIO.new(csv_text) }
    let(:ordering_org) { create :org }
    let(:shop_type) { 3 }

    describe 'Orderの生成数で確認' do
      let(:csv_text) do
        <<~CSV
          商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
          19373386,XXXXXXXXXXXXXXXXXXXXXX,10000,1,54905167,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          76896118,XXXXXXXXXXXXXXXXXXXXXX,10000,2,51219194,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        CSV
      end
      context 'CSV内がすべて新規登録の場合' do
        it 'Orderレコードが2個生成されるはず/エラー文がない' do
          expect { subject }.to change { ordering_org.orders_to_order.count }.by(2)
          expect(importer.errors[:base]).to be_blank
        end
      end
      context 'CSV内が一部が新規登録の場合' do
        context '同じshop_typeで同じ取引IDのレコードがある場合' do
          before { create :order, trade_no: '54905167', ordering_org: ordering_org, shop_type: shop_type }
          it 'Orderレコードが2個生成されるはず/エラー文がない' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(1)
            expect(importer.errors[:base]).to be_blank
          end
        end
        context '違うshop_typeで同じ取引IDのレコードがある場合' do
          before { create :order, trade_no: '54905167', ordering_org: ordering_org, shop_type: 1 }
          it 'Orderレコードが2個生成されるはず/エラー文がない' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(2)
            expect(importer.errors[:base]).to be_blank
          end
        end
      end
      context 'CSV内がすべて登録済の場合' do
        before do
          create :order, trade_no: '54905167', ordering_org: ordering_org, shop_type: shop_type
          create :order, trade_no: '51219194', ordering_org: ordering_org, shop_type: shop_type
        end
        it 'Orderレコードがされない/エラー文がない' do
          expect { subject }.to change { Order.count }.by(0)
          expect(importer.errors[:base]).to include '新しくインポートできる注文はありません。'
        end
      end
    end
  end
end
