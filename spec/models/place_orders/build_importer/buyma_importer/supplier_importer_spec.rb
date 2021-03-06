require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter::SupplierImporter do
  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end

  describe '#call' do
    subject { supplier_importer.call }
    let(:supplier_importer) do
      described_class.new(
        io: io,
        ordering_org: ordering_org,
        ec_shop: ec_shop
      )
    end
    let(:io) { StringIO.new(csv_text) }
    let(:ordering_org) { create :org, org_type: :ordering_org }
    let(:ec_shop) { create :ec_shop, org: ordering_org, ec_shop_type: :buyma }
    let(:csv_text) do
      <<~CSV
        商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
        i1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
      CSV
    end
    context 'Supplierの生成数で確認' do
      context 'Supplierがない' do
        let(:other_org) { create :org, org_type: :ordering_org }
        it 'Supplierが3件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(2)
        end
      end
      context '商品ID=1のSupplierが既にある' do
        let!(:ec_shop1) { create :ec_shop, org: ordering_org, ec_shop_type: 3 }
        let!(:supplier1) { create :supplier, ec_shop: ec_shop1, item_number: 'i1' }
        before do
          create_optional_unit(ordering_org, supplier1, ['https://example_1.com/'])
        end
        it 'Supplierが1件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(1)
        end
      end
      context '商品ID=1,2のSupplierが既にある' do
        let!(:ec_shop1) { create :ec_shop, org: ordering_org, ec_shop_type: 3 }
        let!(:supplier1) { create :supplier, ec_shop: ec_shop1, item_number: 'i1' }
        before do
          create_optional_unit(ordering_org, supplier1, ['https://example_1.com/'])
        end
        let!(:ec_shop2) { create :ec_shop, org: ordering_org, ec_shop_type: 3 }
        let!(:supplier2) { create :supplier, ec_shop: ec_shop2, item_number: 'i2' }
        before do
          create_optional_unit(ordering_org, supplier1, ['https://example_2.com/'])
        end
        it 'Supplierが1件作られる' do
          expect { subject }.to change { ordering_org.suppliers.count }.by(0)
        end
      end
    end
  end
end
