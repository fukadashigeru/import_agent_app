require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter::SupplierImporter do
  describe '#call' do
    subject { supplier_importer.call }
    let(:supplier_importer) do
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
        2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,2,40,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,1,50,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        3,XXXXXXXXXXXXXXXXXXXXXX,10000,2,60,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
      CSV
    end
    context 'Supplierの生成数で確認' do
      context 'Supplierがない' do
        let(:other_org) { create :org, org_type: :ordering_org }
        before do
          create :supplier, org: other_org, shop_type: 3, item_no: '1'
          create :supplier, org: other_org, shop_type: 3, item_no: '2'
          create :supplier, org: other_org, shop_type: 3, item_no: '3'
          create :supplier, org: ordering_org, shop_type: 1, item_no: '1'
          create :supplier, org: ordering_org, shop_type: 1, item_no: '2'
          create :supplier, org: ordering_org, shop_type: 1, item_no: '3'
        end
        it 'Supplierが3件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(3)
        end
      end
      context '商品ID=1のSupplierが既にある' do
        before do
          create :supplier, org: ordering_org, shop_type: 3, item_no: '1'
        end
        it 'Supplierが2件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(2)
        end
      end
      context '商品ID=1,2のSupplierが既にある' do
        before do
          create :supplier, org: ordering_org, shop_type: 3, item_no: '1'
          create :supplier, org: ordering_org, shop_type: 3, item_no: '2'
        end
        it 'Supplierが1件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(1)
        end
      end
      context '商品ID=1,2,3のSupplierが既にある' do
        before do
          create :supplier, org: ordering_org, shop_type: 3, item_no: '1'
          create :supplier, org: ordering_org, shop_type: 3, item_no: '2'
          create :supplier, org: ordering_org, shop_type: 3, item_no: '3'
        end
        it 'Supplierが作られない' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(0)
        end
      end
    end
  end
end
