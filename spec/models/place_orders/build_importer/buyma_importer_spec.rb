require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter do
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
    let(:ordering_org) { create :org, org_type: :ordering_org }
    let(:shop_type) { 3 }

    describe '2件の場合' do
      let(:csv_text) do
        <<~CSV
          商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
          1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          2,XXXXXXXXXXXXXXXXXXXXXX,10000,2,20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        CSV
      end
      context 'Orderレコードについて' do
        context 'CSV内がすべて新規登録の場合' do
          it 'Orderレコードが2個生成されるはず/エラー文がない' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(2)
            expect(importer.errors[:base]).to be_blank
          end
        end
        context 'CSV内が一部が新規登録の場合' do
          context '同じshop_typeで同じ取引IDのレコードがある場合' do
            before do
              create :order, trade_no: '10', ordering_org: ordering_org, shop_type: shop_type, supplier: supplier
            end
            let(:supplier) { create :supplier, org: ordering_org, shop_type: shop_type, item_no: '1' }
            it 'Orderレコードが2個生成されるはず/エラー文がない' do
              expect { subject }.to change { ordering_org.orders_to_order.count }.by(1)
              expect(importer.errors[:base]).to be_blank
            end
          end
          context '違うshop_typeで同じ取引IDのレコードがある場合' do
            before do
              create :order, trade_no: '10',ordering_org: ordering_org, shop_type: :default, supplier: supplier
            end
            let(:supplier) { create :supplier, org: ordering_org, shop_type: :default, item_no: '1' }
            it 'Orderレコードが2個生成されるはず/エラー文がない' do
              expect { subject }.to change { ordering_org.orders_to_order.count }.by(2)
              expect(importer.errors[:base]).to be_blank
            end
          end
        end
        context 'CSV内がすべて登録済の場合' do
          before do
            create :order, trade_no: '10', ordering_org: ordering_org, shop_type: shop_type, supplier: supplier
            create :order, trade_no: '20', ordering_org: ordering_org, shop_type: shop_type, supplier: supplier
          end
          let(:supplier) { create :supplier, org: ordering_org, shop_type: shop_type, item_no: '1' }
          it 'Orderレコードがされない/エラー文がない' do
            expect { subject }.to change { Order.count }.by(0)
            expect(importer.errors[:base]).to include '新しくインポートできる注文はありません。'
          end
        end
      end

      context 'Supplierレコードについて' do
        context '0件登録済の場合' do
          before { create :supplier, org: ordering_org, shop_type: :default, item_no: '1' }
          before { create :supplier, org: ordering_org, shop_type: :default, item_no: '2' }
          it '2件登録されるはず' do
            expect { subject }.to change { ordering_org.suppliers.count }.by(2)
          end
        end
        context '1件登録済の場合' do
          before { create :supplier, org: ordering_org, shop_type: shop_type, item_no: '1' }
          before { create :supplier, org: ordering_org, shop_type: :default, item_no: '2' }
          before { create :supplier, org: other_org, shop_type: :default, item_no: '2' }
          let(:other_org) { create :org }
          it '1件登録されるはず' do
            expect { subject }.to change { ordering_org.suppliers.count }.by(1)
          end
        end
        context '2件登録済の場合' do
          before { create :supplier, org: ordering_org, shop_type: shop_type, item_no: '1' }
          before { create :supplier, org: ordering_org, shop_type: shop_type, item_no: '2' }
          it '登録されないはず' do
            expect { subject }.not_to change(ordering_org.suppliers, :count)
          end
        end
      end
    end

    # describe 'エラーなど' do
    #   let(:csv_text) do
    #     <<~CSV
    #       商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
    #       1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
    #       2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
    #     CSV
    #   end
    #   it 'エラーが返るはず' do
    #     expect(importer.errors[:base]).to be_blank
    #   end
    # end
  end
end
