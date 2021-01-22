require 'rails_helper'

RSpec.describe PlaceOrders::Form do
  let(:form) do
    described_class.new(
      org: org,
      shop_type: shop_type,
      csv_file: csv_file
    )
  end
  let(:importer) { form.importer }
  let(:org) { create :org }
  let(:csv_file) do
    ActionDispatch::Http::UploadedFile.new(
      filename: 'foo.csv',
      type: 'text/csv',
      tempfile: io
    )
  end
  let(:io) { StringIO.new(csv_text) }
  let(:csv_text) do
    <<~CSV
    CSV
  end
  describe 'Validations' do
    describe 'validate :vaildate_csv_header' do
      subject { form.tap(&:valid?).errors[:base] }
      context 'shop_typeが3のとき' do
        let(:shop_type) { 3 }
        context 'ヘッダーの必須項目が全てあるとき' do
          let(:csv_text) do
            <<~CSV
              商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
              19373386,XXXXXXXXXXXXXXXXXXXXXX,10000,1,54905167,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
            CSV
          end
          it { is_expected.to be_blank }
        end
        context 'ヘッダーの必須項目が全てないとき' do
          let(:csv_text) do
            <<~CSV
              商品IDa,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
              19373386,XXXXXXXXXXXXXXXXXXXXXX,10000,1,54905167,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
            CSV
          end
          it { is_expected.to include 'ファイルのヘッダー項目に不足があります。' }
        end
      end
    end
  end
  describe 'Methods' do
    describe '#import!' do
      subject { form.import! }
      let(:shop_type) { 3 }
      let(:io) { StringIO.new(csv_text) }
      let(:csv_text) do
        <<~CSV
          商品ID,商品名,価格,受注数,取引ID,ニックネーム,名前（本名）,郵便番号,住所,電話番号,発送方法,色・サイズ,連絡事項,名前（ローマ字）,住所(ローマ字),受注メモ
          19373386,XXXXXXXXXXXXXXXXXXXXXX,10000,1,54905167,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          76896118,XXXXXXXXXXXXXXXXXXXXXX,10000,2,51219194,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          71494542,XXXXXXXXXXXXXXXXXXXXXX,10000,1,57566497,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          80768950,XXXXXXXXXXXXXXXXXXXXXX,10000,1,50121127,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          12730284,XXXXXXXXXXXXXXXXXXXXXX,10000,1,53549092,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          92153948,XXXXXXXXXXXXXXXXXXXXXX,10000,1,59473252,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          34350843,XXXXXXXXXXXXXXXXXXXXXX,10000,1,52201261,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          48401430,XXXXXXXXXXXXXXXXXXXXXX,10000,1,52726469,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          80643519,XXXXXXXXXXXXXXXXXXXXXX,10000,1,52009216,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
          77180014,XXXXXXXXXXXXXXXXXXXXXX,10000,1,55581353,XXXXXXXXXX,XXXXXXXXXX,XXX-XXX,XXXXXXXXXXXXXXXXXXX,XXX-XXXX-XXXX,XXXXXXXXXXXX,XXXXXX,,XXXXXX XXXXXX,XXXXXXXXXXXXXXXXXXX,
        CSV
      end
      it 'callが一度呼ばれるはず' do
        expect(importer).to receive(:call).once
        subject
      end
    end
  end
end
