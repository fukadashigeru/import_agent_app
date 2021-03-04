require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter::OrderImporter do
  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end

  describe 'Methods' do
    describe '#call' do
      subject { order_importer.call }
      let(:order_importer) do
        described_class.new(
          io: io,
          ordering_org: ordering_org,
          shop_type: 3
        )
      end
      let(:io) { StringIO.new(csv_text) }
      let(:ordering_org) { create :org, org_type: :ordering_org }
      let(:csv_text) do
        <<~CSV
          商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
          i1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        CSV
      end
      let!(:ec_shop1) { create :ec_shop, org: ordering_org, ec_shop_type: 3 }
      let!(:ec_shop2) { create :ec_shop, org: ordering_org, ec_shop_type: 3 }
      let!(:supplier1) { create :supplier, ec_shop: ec_shop1, item_number: 'i1' }
      let!(:supplier2) { create :supplier, ec_shop: ec_shop2, item_number: 'i2' }
      before do
        @optional_unit1 = create_optional_unit(ordering_org, supplier1, ['https://example_1.com/'])
        @optional_unit2 = create_optional_unit(ordering_org, supplier2, ['https://example_2.com/'])
        supplier1.update(first_priority_unit: @optional_unit1)
        supplier2.update(first_priority_unit: @optional_unit2)
      end
      context 'Orderの生成数を確認' do
        context 'Orderがない' do
          it 'Orderが3件作られる' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(3)
          end
        end
        context '取引ID=t10のOrderが既にある' do
          let!(:order1) { create :order, ec_shop: ec_shop1, supplier: supplier1, trade_number: 't10' }
          it 'Orderが2件作られる' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(2)
          end
        end
      end

      context '買付先を確認' do
        context 'Orderがない' do
          it 'ActualUnitを確認' do
            subject
            order_a = ordering_org.orders_to_order.find_by(trade_number: 't10')
            order_b = ordering_org.orders_to_order.find_by(trade_number: 't20')
            expect(order_a.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            expect(order_b.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_2.com/']
          end
        end
        context '商品IDがi1の注文の買付先候補がある場合' do
          let!(:order1) { create :order, ec_shop: ec_shop1, supplier: supplier1, trade_number: 't10' }
          it '商品IDがi1の注文のactual_unitが生成される' do
            subject
            order_a = ordering_org.orders_to_order.find_by(trade_number: 't10')
            order_b = ordering_org.orders_to_order.find_by(trade_number: 't20')
            expect(order_a.actual_unit).to be_nil
            expect(order_b.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_2.com/']
          end
        end
      end
    end
  end
end
