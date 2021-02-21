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
      let!(:supplier_c) { create :supplier, org: ordering_org, shop_type: 3, item_no: '1' }
      let!(:supplier_d) { create :supplier, org: ordering_org, shop_type: 3, item_no: '2' }
      let!(:supplier_e) { create :supplier, org: ordering_org, shop_type: 3, item_no: '3' }
      context 'Orderの生成数を確認' do
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

      context 'ActualUnit,SupplierUrlsを確認' do
        let(:supplier) { create :supplier, org: ordering_org, item_no: '1' }
        let(:urls) { ['https://example_A.com/', 'https://example_B.com/'] }
        let(:csv_text) do
          <<~CSV
            商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
            1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
            2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
            2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          CSV
        end
        before do
          @optional_unit = create_optional_unit(ordering_org, supplier_c, urls)
          supplier_c.update(first_priority_unit: @optional_unit)
        end
        context '商品IDが1の注文の買付先候補がある場合' do
          it '商品IDが1の注文のactual_unitが生成される' do
            subject
            order_a = ordering_org.orders_to_order.find_by(trade_no: '10')
            order_b = ordering_org.orders_to_order.find_by(trade_no: '20')
            expect(order_a.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
            expect(order_b.actual_unit).to be_nil
          end
        end
        context '商品IDが1の注文の買付先候補がある場合' do
          let(:urls_b) { ['https://example_C.com/', 'https://example_D.com/'] }
          before do
            @optional_unit_b = create_optional_unit(ordering_org, supplier_d, urls_b)
            supplier_d.update(first_priority_unit: @optional_unit_b)
          end
          it '商品IDが1の注文のactual_unitが生成される' do
            subject
            order_a = ordering_org.orders_to_order.find_by(trade_no: '10')
            order_b = ordering_org.orders_to_order.find_by(trade_no: '20')
            order_c = ordering_org.orders_to_order.find_by(trade_no: '30')
            expect(order_a.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
            expect(order_b.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_C.com/', 'https://example_D.com/']
            expect(order_c.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_C.com/', 'https://example_D.com/']
          end
        end
      end
    end
  end
end
