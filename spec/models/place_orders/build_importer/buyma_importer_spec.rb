require 'rails_helper'

RSpec.describe PlaceOrders::BuildImporter::BuymaImporter do
  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end
  describe '#call' do
    subject { importer.call }
    let(:importer) do
      described_class.new(
        io: io,
        ordering_org: ordering_org,
        ec_shop_type: ec_shop_type
      )
    end
    let(:io) { StringIO.new(csv_text) }
    let(:ordering_org) { create :org, org_type: :ordering_org }
    let(:ec_shop_type) { 3 }

    describe '2件の場合' do
      let(:csv_text) do
        <<~CSV
          商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
          i1,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t10,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t20,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          i2,XXXXXXXXXXXXXXXXXXXXXX,10000,1,t30,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        CSV
      end
      context 'Orderレコードについて' do
        context 'CSV内がすべて新規登録の場合' do
          it 'Orderレコードが2個生成されるはず/エラー文がない' do
            expect { subject }.to change { ordering_org.orders_to_order.count }.by(3)
            expect(importer.errors[:base]).to be_blank
          end
        end
      end
      context 'Supplierレコードについて' do
        context '0件登録済の場合' do
          it '2件登録されるはず' do
            expect { subject }.to change { ordering_org.suppliers.count }.by(2)
          end
        end
      end
    end
  end
end
