require 'rails_helper'

RSpec.describe Supplier::SupplierForm::OptionalUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      optional_unit: optional_unit,
      first_priority: first_priority,
      optional_unit_url_id_and_url_array: optional_unit_url_id_and_url_array
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:supplier_url) { create :supplier_url, url: url, org: org }
  let(:optional_unit) { nil }
  let(:first_priority) { false }
  let(:optional_unit_url_id_and_url_array) { [] }


  describe 'save_optional_unit!' do
    subject { form.save_optional_unit! }
    context 'optional_unitが新規登録の場合' do
      context 'セット商品でない場合' do
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: nil, url: 'https://example_1.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it do
            expect { subject }.to change { OptionalUnit.count }.by(1)
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            optional_unit_last = OptionalUnit.last
            expect(supplier.first_priority_unit_id).not_to eq optional_unit_last.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { OptionalUnitUrl.count }.by(1)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { SupplierUrl.count }.by(1)
          end
        end
      end
      context 'セット商品の場合' do
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: nil, url: 'https://example_1.com/' },
            { optional_unit_url_id: nil, url: 'https://example_2.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it do
            expect { subject }.to change { OptionalUnit.count }.by(1)
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            optional_unit_last = OptionalUnit.last
            expect(supplier.first_priority_unit_id).not_to eq optional_unit_last.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { OptionalUnitUrl.count }.by(2)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { SupplierUrl.count }.by(2)
          end
        end
      end
    end

    context 'optional_unitが更新の場合' do
      context 'セット商品でない場合' do
        let(:optional_unit) { create :optional_unit, supplier: supplier }
        let!(:optional_unit_url_a) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_a
        end
        let(:supplier_url_a) { create :supplier_url, org: org, url: 'https://example_a.com/' }
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_1.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            expect(supplier.first_priority_unit_id).not_to eq optional_unit.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { optional_unit.optional_unit_urls.count }.by(0)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { org.supplier_urls.count }.by(1)
          end
          it 'optional_unitに紐付いているurlの内容を厳密に確認' do
            subject
            expect(optional_unit.optional_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_1.com/']
          end
        end
      end

      context 'セット商品の場合' do
        let(:optional_unit) { create :optional_unit, supplier: supplier }
        let!(:optional_unit_url_a) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_a
        end
        let(:supplier_url_a) { create :supplier_url, org: org, url: 'https://example_a.com/' }
        let!(:optional_unit_url_b) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_b
        end
        let(:supplier_url_b) { create :supplier_url, org: org, url: 'https://example_b.com/' }
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_1.com/' },
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_2.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            expect(supplier.first_priority_unit_id).not_to eq optional_unit.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { optional_unit.optional_unit_urls.count }.by(0)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { org.supplier_urls.count }.by(2)
          end
          it 'optional_unitに紐付いているurlの内容を厳密に確認' do
            subject
            expect(optional_unit.optional_unit_urls.map(&:supplier_url).map(&:url))
            .to eq ['https://example_1.com/', 'https://example_2.com/']
          end
        end
      end

      context '単品商品からセット商品の変更ですよ' do
        let(:optional_unit) { create :optional_unit, supplier: supplier }
        let!(:optional_unit_url_a) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_a
        end
        let(:supplier_url_a) { create :supplier_url, org: org, url: 'https://example_a.com/' }
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_1.com/' },
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_2.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            expect(supplier.first_priority_unit_id).not_to eq optional_unit.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { optional_unit.optional_unit_urls.count }.by(1)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { org.supplier_urls.count }.by(2)
          end
          it 'optional_unitに紐付いているurlの内容を厳密に確認' do
            subject
            expect(optional_unit.optional_unit_urls.map(&:supplier_url).map(&:url))
            .to eq ['https://example_1.com/', 'https://example_2.com/']
          end
        end
      end

      context 'セット商品から単品商品への変更ですよ' do
        let(:optional_unit) { create :optional_unit, supplier: supplier }
        let!(:optional_unit_url_a) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_a
        end
        let(:supplier_url_a) { create :supplier_url, org: org, url: 'https://example_a.com/' }
        let!(:optional_unit_url_b) do
          create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url_b
        end
        let(:supplier_url_b) { create :supplier_url, org: org, url: 'https://example_b.com/' }
        let(:optional_unit_url_id_and_url_array) do
          [
            { optional_unit_url_id: optional_unit_url_a.id, url: 'https://example_1.com/' }
          ]
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          it do
            subject
            expect(supplier.first_priority_unit_id).not_to eq optional_unit.id
          end
        end
        context 'OptionalUnitUrlを確認' do
          it do
            expect { subject }.to change { optional_unit.optional_unit_urls.count }.by(-1)
          end
        end
        context 'SupplierUrlを確認' do
          it do
            expect { subject }.to change { org.supplier_urls.count }.by(1)
          end
          it 'optional_unitに紐付いているurlの内容を厳密に確認' do
            subject
            expect(optional_unit.optional_unit_urls.map(&:supplier_url).map(&:url))
            .to eq ['https://example_1.com/']
          end
        end
      end
    end

    # context 'optional_unitの生成数を確認する' do
    #   context 'optional_unit_url_idがある場合' do
    #     let(:optional_unit_url_id) { optional_unit_url.id }
    #     let!(:optional_unit_url) { create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url }
    #     let(:optional_unit) { create :optional_unit, supplier: supplier }
    #     let(:url) { 'https://example_1.com/' }
    #     let(:supplier_url) { create :supplier_url, org: other_org, url: url }
    #     let(:other_org) { create :org, org_type: :ordering_org }
    #     it 'optional_unitは増えない' do
    #       expect { subject }.to change { OptionalUnit.count }.by(0)
    #     end
    #     it 'optional_unit_urlは増えない' do
    #       expect { subject }.to change { OptionalUnitUrl.count }.by(0)
    #     end
    #   end
    #   context 'optional_unit_url_idがない場合' do
    #     it 'optional_unitが1つ増える' do
    #       expect { subject }.to change { OptionalUnit.count }.by(1)
    #     end
    #     it 'optional_unit_utlが1つ増える' do
    #       expect { subject }.to change { OptionalUnitUrl.count }.by(1)
    #     end
    #   end
    # end
    # context 'supplier_ulrの生成数を確認する' do
    #   context '同じurlをもつsupplier_urlがない場合' do
    #     before { create :supplier_url, org: other_org, url: url }
    #     let(:other_org) { create :org, org_type: :ordering_org }
    #     it 'supplierが1つ増える' do
    #       expect { subject }.to change { SupplierUrl.count }.by(1)
    #     end
    #   end
    #   context '同じurlをもつsupplier_urlがある場合' do
    #     before { create :supplier_url, org: org, url: url }
    #     it 'supplierが増えない' do
    #       expect { subject }.to change { SupplierUrl.count }.by(0)
    #     end
    #   end
    # end
    # context 'first_priorityを確認する' do
    #   context 'first_priorityがtrueの場合' do
    #     let(:first_priority) { false }
    #     it 'first_priority_unit_idがnil' do
    #       subject
    #       expect(supplier.first_priority_unit_id).to be_nil
    #     end
    #   end
    #   context 'first_priorityがfalseの場合' do
    #     let(:first_priority) { true }
    #     it 'first_priority_unit_idがnilではない' do
    #       subject
    #       expect(supplier.first_priority_unit_id).to be_present
    #     end
    #   end
    # end
  end
end
