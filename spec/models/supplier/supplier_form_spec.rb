require 'rails_helper'

RSpec.describe Supplier::SupplierForm do
  before { skip }
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      order: order,
      first_priority_attr: first_priority_attr,
      optional_unit_forms_attrs_arr: optional_unit_forms_attrs_arr
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:order) { create :order, ordering_org: org, supplier: supplier }
  let(:first_priority_attr) { '0' }
  let(:optional_unit_forms_attrs_arr) do
    [
      { optional_unit_id: nil, urls: ['https://example_11.com/', 'https://example_12.com/'] },
      { optional_unit_id: nil, urls: ['https://example_21.com/', 'https://example_22.com/'] },
      { optional_unit_id: nil, urls: ['', ''] },
      { optional_unit_id: nil, urls: ['', ''] },
      { optional_unit_id: nil, urls: ['', ''] }
    ]
  end

  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end

  def create_actual_unit(order, urls)
    actual_unit = (create :actual_unit, order: order)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :actual_unit_url, supplier_url: supplier_url, actual_unit: actual_unit
    end
    actual_unit
  end

  describe 'save_units!' do
    subject { form.save_units! }
    context '3件とも新規' do
      let(:first_priority_attr) { '0' }
      let(:optional_unit_forms_attrs_arr) do
        [
          { optional_unit_id: nil, urls: ['https://example_11.com/', 'https://example_12.com/'] },
          { optional_unit_id: nil, urls: ['https://example_21.com/', 'https://example_22.com/'] },
          { optional_unit_id: nil, urls: ['https://example_31.com/', 'https://example_32.com/'] },
          { optional_unit_id: nil, urls: ['', ''] },
          { optional_unit_id: nil, urls: ['', ''] }
        ]
      end
      context 'optional_unitを確認する' do
        it 'optional_unitで3個生成される' do
          expect { subject }.to change { supplier.optional_units.count }.by(3)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが3個生成される' do
          expect { subject }.to change {
            supplier.optional_units.map(&:optional_unit_urls).flatten.count
          }.by(6)
        end
      end
      context 'actual_unitを確認する' do
        it 'actual_unitが(1個)生成される' do
          subject
          expect(order.actual_unit).to be_present
        end
      end
      context 'actual_unit_urlを確認する' do
        it 'actual_unit_urlが1個生成される' do
          subject
          expect(order.actual_unit.actual_unit_urls.count).to eq 2
        end
      end
      context 'supplier_urlsを確認する' do
        it 'orderに紐づくsupplier_urlのurlがしかるべきものとなっている' do
          subject
          expect(order.actual_unit.supplier_urls.map(&:url))
            .to eq ['https://example_11.com/', 'https://example_12.com/']
        end
        it 'orderに関連するsupplier_urlsが2個生成される' do
          expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(2)
        end
        it 'orgに紐付いたsupplier_urlsが3個生成される' do
          expect { subject }.to change { org.supplier_urls.count }.by(6)
        end
      end
    end

    context '1件更新で2件新規：新規分が第一候補' do
      let(:first_priority_attr) { '1' }
      let(:optional_unit_forms_attrs_arr) do
        [
          {
            optional_unit_id: @optional_unit.id.to_s,
            urls: ['https://example_11.com/', 'https://example_12.com/']
          },
          { optional_unit_id: nil, urls: ['https://example_21.com/', 'https://example_22.com/'] },
          { optional_unit_id: nil, urls: ['https://example_31.com/', 'https://example_32.com/'] },
          { optional_unit_id: nil, urls: ['', ''] },
          { optional_unit_id: nil, urls: ['', ''] }
        ]
      end
      let!(:supplier) { create :supplier, org: org }

      before do
        @optional_unit = create_optional_unit(
          org, supplier, ['https://example_a.com', 'https://example_a.com']
        )
        supplier.update(first_priority_unit_id: @optional_unit.id)
      end

      context 'optional_unitを確認する' do
        it 'supplierに紐づくoptional_unitが3個ある' do
          expect { subject }.to change { supplier.optional_units.count }.from(1).to(3)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが2個生成される' do
          expect { subject }.to change {
            supplier.optional_units.map(&:optional_unit_urls).flatten.count
          }.from(2).to(6)
        end
      end
      context 'supplier_urlsを確認する' do
        it 'orderに関連するsupplier_urlsが1個生成される' do
          expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(2)
        end
        it 'orgに紐付いたsupplier_urlsが3個生成される' do
          expect { subject }.to change {
            supplier.optional_units.map(&:supplier_urls).flatten.count
          }.from(2).to(6)
        end
      end
      context '実際の買付先周りを確認する' do
        context 'actual_unitがない場合' do
          context 'actual_unitを確認する' do
            it 'actual_unitが(1個)生成される' do
              subject
              expect(order.actual_unit).to be_present
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'orderに紐づくactual_unit_urlが存在する' do
              subject
              expect(order.actual_unit.actual_unit_urls.count).to eq 2
            end
            it 'actual_unit_urlが2個生成される' do
              expect { subject }.to change { ActualUnitUrl.count }.by(2)
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_21.com/', 'https://example_22.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          before { create_actual_unit(order, ['https://example_a.com']) }
          context 'actual_unitを確認する' do
            it 'actual_unitは増えない' do
              expect { subject }.to change { ActualUnit.count }.by(0)
            end
            it 'actual_unitが存在する' do
              subject
              expect(order.actual_unit).to be_present
            end
            it 'actual_unitのidが変わらない' do
              expect { subject }.not_to(change { order.actual_unit.id })
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.from(1).to(2)
            end
            it 'actual_unit_urlのidが変わらない' do
              expect { subject }.to change { order.actual_unit.actual_unit_urls.count }.from(1).to(2)
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_21.com/', 'https://example_22.com/']
            end
          end
        end
      end
    end

    context '1件更新で2件新規：更新分が第一候補' do
      let(:first_priority_attr) { '0' }
      let(:optional_unit_forms_attrs_arr) do
        [
          { optional_unit_id: @optional_unit.id.to_s, urls: ['https://example_1.com/'] },
          { optional_unit_id: nil, urls: ['https://example_2.com/'] },
          { optional_unit_id: nil, urls: ['https://example_3.com/'] },
          { optional_unit_id: nil, urls: ['', ''] },
          { optional_unit_id: nil, urls: ['', ''] }
        ]
      end
      let!(:supplier) { create :supplier, org: org }
      before do
        @optional_unit = create_optional_unit(
          org, supplier, ['https://example_a.com', 'https://example_b.com']
        )
        supplier.update(first_priority_unit_id: @optional_unit.id)
      end

      context 'optional_unitを確認する' do
        it 'optional_unitが1個から3個に増える' do
          expect { subject }.to change { supplier.optional_units.count }.from(1).to(3)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが2個から3個に増える' do
          expect { subject }.to change {
            supplier.reload.optional_units.map(&:optional_unit_urls).flatten.count
          }.from(2).to(3)
        end
      end
      context 'supplier_urlsを確認する' do
        it 'orderに関連するsupplier_urlsが1個生成される' do
          expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(1)
        end
        it 'orgに紐付いたsupplier_urlsが3個生成される' do
          expect { subject }.to change { org.supplier_urls.count }.from(2).to(5)
        end
      end
      context '実際の買付先周りを確認する' do
        context 'actual_unitがない場合' do
          context 'actual_unitを確認する' do
            it 'actual_unitが(1個)生成される' do
              subject
              expect(order.actual_unit).to be_present
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'actual_unit_urlが存在する' do
              subject
              expect(order.actual_unit.actual_unit_urls.count).to eq 1
            end
            it 'actual_unit_urlが1個生成される' do
              expect { subject }.to change { ActualUnit.count }.by(1)
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          before { create_actual_unit(order, ['https://example_1.com/']) }
          context 'actual_unitを確認する' do
            it 'actual_unitは増えない' do
              expect { subject }.to change { ActualUnit.count }.by(0)
            end
            it 'actual_unitが存在する' do
              subject
              expect(order.actual_unit).to be_present
            end
            it 'actual_unitのidが変わらない' do
              expect { subject }.not_to(change { order.actual_unit.id })
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'actual_unit_urlが存在する' do
              subject
              expect(order.actual_unit.actual_unit_urls.count).to eq 1
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end
      end
    end

    context '3件とも更新' do
      let(:first_priority_attr) { '2' }
      let(:optional_unit_forms_attrs_arr) do
        [
          { optional_unit_id: @optional_unit_a.id.to_s, urls: ['https://example_1.com/'] },
          { optional_unit_id: @optional_unit_b.id.to_s, urls: ['https://example_2.com/'] },
          { optional_unit_id: @optional_unit_c.id.to_s, urls: ['https://example_3.com/'] }
        ]
      end
      before do
        @optional_unit_a = create_optional_unit(org, supplier, ['https://example_a.com'])
        @optional_unit_b = create_optional_unit(org, supplier, ['https://example_b.com'])
        @optional_unit_c = create_optional_unit(org, supplier, ['https://example_c.com'])
        supplier.update(first_priority_unit_id: @optional_unit_c.id)
      end
      context 'optional_unitを確認する' do
        it 'optional_unitで生成されない' do
          expect { subject }.to change { supplier.reload.optional_units.count }.by(0)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが生成されない' do
          expect { subject }.to change {
            supplier.optional_units.map(&:optional_unit_urls).flatten.count
          }.by(0)
        end
      end
      context 'supplier_urlsを確認する' do
        it 'orderに関連するsupplier_urlsが1個生成される' do
          expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(1)
        end
        it 'orgに紐付いたsupplier_urlsが3個生成される' do
          expect { subject }.to change { org.supplier_urls.count }.by(3)
        end
      end
      context '実際の買付先周りを確認する' do
        context 'actual_unitがない場合' do
          context 'actual_unitを確認する' do
            it 'actual_unitが(1個)生成される' do
              subject
              expect(order.actual_unit).to be_present
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'actual_unit_urlが存在する' do
              subject
              expect(order.actual_unit.actual_unit_urls.count).to eq 1
            end
            it 'actual_unit_urlが1個生成される' do
              expect { subject }.to change { ActualUnit.count }.by(1)
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_3.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          before { create_actual_unit(order, ['https://example_b.com']) }
          context 'actual_unitを確認する' do
            it 'actual_unitは増えない' do
              expect { subject }.to change { ActualUnit.count }.by(0)
            end
            it 'actual_unitが存在する' do
              subject
              expect(order.actual_unit).to be_present
            end
            it 'actual_unitのidが変わらない' do
              expect { subject }.not_to(change { order.actual_unit.id })
            end
          end
          context 'actual_unit_urlを確認する' do
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'actual_unit_urlが存在する' do
              subject
              expect(order.actual_unit.actual_unit_urls.count).to eq 1
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_3.com/']
            end
          end
        end
      end
    end
  end

  describe 'optional_unit_forms_for_form' do
    subject { form.optional_unit_forms_for_form }
    context 'レコードがないとき' do
      let(:optional_unit_forms_attrs_arr) { [] }
      it 'OptionalUnitFromのoptional_urlsがいい感じ' do
        subject
        expect(subject[0].optional_urls).to eq ['']
        expect(subject[1].optional_urls).to eq ['']
        expect(subject[2].optional_urls).to eq ['']
        expect(subject[3].optional_urls).to eq ['']
        expect(subject[4].optional_urls).to eq ['']
      end
    end

    context 'optional_unitsレコードが3個あるとき' do
      let(:optional_unit_forms_attrs_arr) { [] }
      before do
        @optional_unit_a = create_optional_unit(
          org, supplier, ['https://example_a1.com', 'https://example_a2.com']
        )
        @optional_unit_b = create_optional_unit(
          org, supplier, ['https://example_b1.com', 'https://example_b2.com']
        )
        @optional_unit_c = create_optional_unit(
          org, supplier, ['https://example_c1.com', 'https://example_c2.com']
        )
        supplier.update(first_priority_unit_id: @optional_unit_c.id)
      end
      it 'OptionalUnitFromのoptional_urlsがいい感じ' do
        subject
        expect(subject[0].optional_urls).to eq ['https://example_a1.com', 'https://example_a2.com']
        expect(subject[1].optional_urls).to eq ['https://example_b1.com', 'https://example_b2.com']
        expect(subject[2].optional_urls).to eq ['https://example_c1.com', 'https://example_c2.com']
        expect(subject[3].optional_urls).to eq ['']
        expect(subject[4].optional_urls).to eq ['']
      end
    end

    context 'optional_unitsレコードがMAXの5個あるとき' do
      let(:optional_unit_forms_attrs) { [] }
      before do
        @optional_unit_a = create_optional_unit(
          org, supplier, ['https://example_a1.com', 'https://example_a2.com']
        )
        @optional_unit_b = create_optional_unit(
          org, supplier, ['https://example_b1.com', 'https://example_b2.com']
        )
        @optional_unit_c = create_optional_unit(
          org, supplier, ['https://example_c1.com', 'https://example_c2.com']
        )
        @optional_unit_d = create_optional_unit(
          org, supplier, ['https://example_d1.com', 'https://example_d2.com']
        )
        @optional_unit_e = create_optional_unit(
          org, supplier, ['https://example_e1.com', 'https://example_e2.com']
        )
        supplier.update(first_priority_unit_id: @optional_unit_c.id)
      end
      it 'OptionalUnitFromのoptional_urlsがいい感じ' do
        subject
        expect(subject[0].optional_urls).to eq ['https://example_a1.com', 'https://example_a2.com']
        expect(subject[1].optional_urls).to eq ['https://example_b1.com', 'https://example_b2.com']
        expect(subject[2].optional_urls).to eq ['https://example_c1.com', 'https://example_c2.com']
        expect(subject[3].optional_urls).to eq ['https://example_d1.com', 'https://example_d2.com']
        expect(subject[4].optional_urls).to eq ['https://example_e1.com', 'https://example_e2.com']
      end
    end
  end

  describe 'optional_unit_forms_for_save' do
    subject { form.optional_unit_forms_for_save }
    context 'optional_unitsレコードが2個あるとき' do
      let(:first_priority_attr) { '2' }
      let(:optional_unit_forms_attrs_arr) do
        [
          {
            optional_unit_id: @optional_unit_a.id.to_s,
            urls: ['https://example_11.com/', 'https://example_12.com/']
          },
          {
            optional_unit_id: @optional_unit_b.id.to_s,
            urls: ['https://example_21.com/', 'https://example_22.com/']
          },
          {
            optional_unit_id: nil,
            urls: ['https://example_31.com/', 'https://example_32.com/']
          },
          { optional_unit_id: nil, urls: ['', ''] },
          { optional_unit_id: nil, urls: ['', ''] }
        ]
      end
      before do
        @optional_unit_a = create_optional_unit(
          org, supplier, ['https://example_a1.com', 'https://example_a2.com']
        )
        @optional_unit_b = create_optional_unit(
          org, supplier, ['https://example_b1.com', 'https://example_b2.com']
        )
        supplier.update(first_priority_unit_id: @optional_unit_b.id)
      end
      it 'OptionalUnitFromのoptional_unit_url_id_and_url_arrayがいい感じ' do
        subject
        expect(subject[0].optional_urls).to eq ['https://example_11.com/', 'https://example_12.com/']
        expect(subject[1].optional_urls).to eq ['https://example_21.com/', 'https://example_22.com/']
        expect(subject[2].optional_urls).to eq ['https://example_31.com/', 'https://example_32.com/']
        expect(subject[3]).to eq nil
        expect(subject[4]).to eq nil
      end
    end
  end
end
