require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter::OrderImporter do
  describe '#call' do
    subject { order_importer.call }
    let(:order_importer) do
      described_class.new(
        io: io,
        ordering_org: ordering_org,
        shop_type: shop_type
      )
    end
    let(:io) { StringIO.new(csv_text) }
    let(:ordering_org) { create :org, org_type: :ordering_org }
    let(:shop_type) { 3 }
    let(:csv_text) do
      <<~CSV
        商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
        1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,2,40,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,1,50,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,2,60,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
      CSV
    end
    let(:other_org) { create :org, org_type: :ordering_org }
    let(:supplier_a) { create :supplier, org: other_org }
    let(:supplier_b) { create :supplier, org: ordering_org }
    before do
      create :supplier, org: ordering_org, shop_type: 3, item_no: '1'
      create :supplier, org: ordering_org, shop_type: 3, item_no: '2'
      create :supplier, org: ordering_org, shop_type: 3, item_no: '3'
    end
    context 'Orderの生成数で確認' do
      context 'Orderがない' do
        before do
          create :order, ordering_org: other_org, shop_type: 3, trade_no: '10', supplier: supplier_a
          create :order, ordering_org: other_org, shop_type: 3, trade_no: '20', supplier: supplier_a
          create :order, ordering_org: other_org, shop_type: 3, trade_no: '30', supplier: supplier_a
          create :order, ordering_org: ordering_org, shop_type: 1, trade_no: '10', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 1, trade_no: '20', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 1, trade_no: '30', supplier: supplier_b
        end
        it 'Orderが6件作られる' do
          expect { subject }.to change { ordering_org.orders_to_order.count }.by(6)
        end
      end
      context '取引ID=10のOrderが既にある' do
        before do
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '10', supplier: supplier_b
        end
        it 'Orderが5件作られる' do
          expect { subject }.to change { ordering_org.orders_to_order.count }.by(5)
        end
      end
      context '取引ID=10,20,30,40,50,60のOrderが既にある' do
        before do
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '10', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '20', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '30', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '40', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '50', supplier: supplier_b
          create :order, ordering_org: ordering_org, shop_type: 3, trade_no: '60', supplier: supplier_b
        end
        it 'Orderが5件作られる' do
          expect { subject }.to change { ordering_org.orders_to_order.count }.by(0)
        end
      end
    end
  end
end
