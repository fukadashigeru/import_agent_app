require 'rails_helper'

RSpec.describe Supplier::SupplierForm::OptionalUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      optional_unit_id: optional_unit_id,
      first_priority: first_priority,
      optional_urls: optional_urls
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:supplier_url) { create :supplier_url, url: url, org: org }
  let(:optional_unit_id) { nil }
  let(:first_priority) { false }
  let(:optional_urls) { [''] }

  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end

  describe 'save_optional_unit!' do
    subject { form.save_optional_unit! }
    context 'optional_unitが新規登録の場合' do
      context 'セット商品でない場合' do
        let(:optional_urls) { ['https://example_1.com/'] }
        context 'OptionalUnitを確認' do
          it do
            expect { subject }.to change { OptionalUnit.count }.by(1)
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              optional_unit_last = OptionalUnit.last
              expect(supplier.first_priority_unit_id).not_to eq optional_unit_last.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              optional_unit_last = OptionalUnit.last
              expect(supplier.first_priority_unit_id).to eq optional_unit_last.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.from(0).to(1)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは1個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 1
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが1個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(0).to(1)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 1
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
          end
        end
      end

      context 'セット商品の場合' do
        let(:optional_urls) { ['https://example_1.com/', 'https://example_2.com/'] }
        context 'OptionalUnitを確認' do
          it do
            expect { subject }.to change { OptionalUnit.count }.by(1)
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              optional_unit_last = OptionalUnit.last
              expect(supplier.first_priority_unit_id).not_to eq optional_unit_last.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              optional_unit_last = OptionalUnit.last
              expect(supplier.first_priority_unit_id).to eq optional_unit_last.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.from(0).to(2)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは1個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 2
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(0).to(2)
          end
          it 'このoptional_unitに紐づくsupplier_urlは2個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 2
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url))
              .to eq ['https://example_1.com/', 'https://example_2.com/']
          end
        end
      end
    end

    context 'optional_unitが更新の場合' do
      context 'セット商品でない場合' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { ['https://example_1.com/'] }

        before { @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/']) }
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [@optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              expect(supplier.first_priority_unit_id).not_to eq @optional_unit.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              expect(supplier.first_priority_unit_id).to eq @optional_unit.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(0)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは1個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 1
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが1個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(1).to(2)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 1
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
          end
        end
      end

      context 'セット商品の場合' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { ['https://example_1.com/', 'https://example_2.com/'] }
        before do
          @optional_unit =
            create_optional_unit(org, supplier, ['https://example_a.com/', 'https://example_b.com/'])
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [@optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              expect(supplier.first_priority_unit_id).not_to eq @optional_unit.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              expect(supplier.first_priority_unit_id).to eq @optional_unit.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(0)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは2個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 2
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(2).to(4)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 2
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url))
              .to eq ['https://example_1.com/', 'https://example_2.com/']
          end
        end
      end

      context '単品商品からセット商品の変更です' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { ['https://example_1.com/', 'https://example_2.com/'] }

        before { @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/']) }
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [@optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              expect(supplier.first_priority_unit_id).not_to eq @optional_unit.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              expect(supplier.first_priority_unit_id).to eq @optional_unit.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(1)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは2個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 2
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(1).to(3)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 2
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url))
              .to eq ['https://example_1.com/', 'https://example_2.com/']
          end
        end
      end

      context 'セット商品から単品商品への変更です' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { ['https://example_1.com/'] }

        before do
          @optional_unit =
            create_optional_unit(org, supplier, ['https://example_a.com/', 'https://example_b.com/'])
        end
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えておらず同一である' do
            subject
            expect(supplier.optional_units).to eq [@optional_unit]
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              expect(supplier.first_priority_unit_id).not_to eq @optional_unit.id
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっている' do
              subject
              expect(supplier.first_priority_unit_id).to eq @optional_unit.id
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個減る' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(-1)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは1個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 1
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(2).to(3)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            subject
            expect(supplier.optional_units.last.supplier_urls.count).to eq 1
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
          end
        end
      end
    end

    context 'optional_unit_idはあるがoptional_unitsが空' do
      context '単品商品から削除' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { [''] }

        before do
          @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/'])
          supplier.update(first_priority_unit_id: @optional_unit.id)
        end

        context 'OptionalUnitを確認' do
          it 'OptionalUnitが削除されている' do
            subject
            expect(supplier.optional_units).to eq []
          end
        end
        context 'first_priority周りを確認' do
          context '第一候補でない場合' do
            it '第一候補になっていない' do
              subject
              expect(supplier.first_priority_unit_id).not_to eq nil
            end
          end
          context '第一候補の場合' do
            let(:first_priority) { true }
            it '第一候補になっていない' do
              expect { subject }.to raise_error '第1優先で選択できません。'
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個減る' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(-1)
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.by(0)
          end
        end
      end
    end
  end
end
