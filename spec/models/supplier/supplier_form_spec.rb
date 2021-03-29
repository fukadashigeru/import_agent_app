require 'rails_helper'

RSpec.describe Supplier::SupplierForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      first_priority_attr: first_priority_attr,
      order_ids: order_ids,
      optional_unit_forms_attrs_arr: optional_unit_forms_attrs_arr
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:order) { create :order, ordering_org: org, supplier: supplier, status: :before_order }
  let(:first_priority_attr) { '0' }
  let(:order_ids) { :all }
  let(:optional_unit_forms_attrs_arr) do
    [
      { optional_unit_id: nil, urls: ['https://example_A.com/', 'https://example_B.com/'] },
      { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
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

  describe 'Validation' do
    before { pending }
    describe 'valid_order_having_no_actual' do
      subject { form.tap(&:valid?).errors[:base] }
      context 'actual_first_priority_attrがあるとき' do
        let(:actual_first_priority_attr) { '1' }
        context 'actual_unitがあるとき' do
          before { create_actual_unit(order, ['https://example_a.com/']) }
          it do
            is_expected.to be_blank
          end
        end
        context 'actual_unitがないとき' do
          it do
            is_expected.to be_blank
          end
        end
      end
      context 'actual_first_priority_attrがないとき' do
        context 'actual_unitがあるとき' do
          before { create_actual_unit(order, ['https://example_a.com/']) }
          it do
            is_expected.to include '不正な注文のため操作が取り消されました。'
          end
        end
        context 'actual_unitがないとき' do
          it do
            is_expected.to be_blank
          end
        end
      end
    end

    describe 'valid_optional_units_belong_to_supplier' do
      subject { form.tap(&:valid?).errors[:base] }
      before do
        @other_optional_unit = create_optional_unit(org, other_supplier, ['https://example_a.com/'])
      end
      let(:other_supplier) { create :supplier, org: org }
      context 'optional_unitがある場合' do
        before do
          @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/'])
        end
        context '異常' do
          let(:optional_unit_forms_attrs_arr) do
            [
              {
                optional_unit_id: @other_optional_unit.id,
                urls: ['https://example_A.com/', 'https://example_B.com/']
              },
              { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] }
            ]
          end
          it do
            is_expected.to include '不正な買付先のため操作が取り消されました。'
          end
        end
        context '正常' do
          let(:optional_unit_forms_attrs_arr) do
            [
              {
                optional_unit_id: @optional_unit.id,
                urls: ['https://example_A.com/', 'https://example_B.com/']
              },
              { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] }
            ]
          end
          it do
            is_expected.to be_blank
          end
        end
      end
      context 'optional_unitがない場合' do
        context '異常' do
          let(:optional_unit_forms_attrs_arr) do
            [
              {
                optional_unit_id: @other_optional_unit.id,
                urls: ['https://example_A.com/', 'https://example_B.com/']
              },
              { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] },
              { optional_unit_id: nil, urls: ['', ''] }
            ]
          end
          it do
            is_expected.to include '不正な買付先のため操作が取り消されました。'
          end
        end
      end
    end
  end

  describe 'Methods' do
    describe 'upsert_or_destroy_units!' do
      subject { form.upsert_or_destroy_units! }
      context 'order_idsが:allの場合' do
        let(:first_priority_attr) { '1' }
        let(:optional_unit_forms_attrs_arr) do
          [
            {
              optional_unit_id: @optional_unit.id.to_s,
              urls: ['https://example_A.com/', 'https://example_B.com/']
            },
            { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
            { optional_unit_id: nil, urls: ['', ''] },
            { optional_unit_id: nil, urls: ['', ''] },
            { optional_unit_id: nil, urls: ['', ''] }
          ]
        end
        before do
          @optional_unit = create_optional_unit(
            org, supplier, ['https://example_a.com/']
          )
          supplier.update(first_priority_unit_id: @optional_unit.id)
        end
        context 'optional_unitの買付先について' do
          it do
            subject
            expect(@optional_unit.supplier_urls.map(&:url)).to eq ['https://example_A.com/', 'https://example_B.com/'] 
            expect(OptionalUnit.last.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/'] 
          end
        end
        context 'actual_unitがないorder' do
          let!(:order1) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          let!(:order2) { create :order, supplier: supplier, status: :ordered, ordering_org: org }
          it do
            subject
            expect(order1.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/']
            # 本来はこうあるべきではないがactual_unitがなければ、status: :orderedであれば買付先が登録される
            expect(order2.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/']
          end
        end
        context 'actual_unitがあるorder' do
          let!(:order1) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          let!(:order2) { create :order, supplier: supplier, status: :ordered, ordering_org: org }
          before do
            create_actual_unit(order1, ['https://example_A.com/', 'https://example_B.com/'])
            create_actual_unit(order2, ['https://example_A.com/', 'https://example_B.com/'])
          end
          it do
            subject
            expect(order1.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_A.com/', 'https://example_B.com/']
            expect(order2.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
      end

      context 'order_idsがidの配列の場合' do
        let(:first_priority_attr) { '1' }
        let(:optional_unit_forms_attrs_arr) do
          [
            {
              optional_unit_id: @optional_unit.id.to_s,
              urls: ['https://example_A.com/', 'https://example_B.com/']
            },
            { optional_unit_id: nil, urls: ['https://example_C.com/', 'https://example_D.com/'] },
            { optional_unit_id: nil, urls: ['', ''] },
            { optional_unit_id: nil, urls: ['', ''] },
            { optional_unit_id: nil, urls: ['', ''] }
          ]
        end
        before do
          @optional_unit = create_optional_unit(
            org, supplier, ['https://example_a.com/']
          )
          supplier.update(first_priority_unit_id: @optional_unit.id)
        end
        context 'optional_unitの買付先について' do
          it do
            # TODO
          end
        end
        context 'actual_unitがないorder' do
          let(:order_ids) { [order1.id, order2.id, order3.id] }
          let!(:order1) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          let!(:order2) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          let!(:order3) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          let!(:order4) { create :order, supplier: supplier, status: :before_order, ordering_org: org }
          before do
            create_actual_unit(order3, ['https://example_A.com/', 'https://example_B.com/'])
            create_actual_unit(order4, ['https://example_A.com/', 'https://example_B.com/'])
          end
          it do
            subject
            expect(order1.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/']
            expect(order2.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/']
            expect(order3.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_C.com/', 'https://example_D.com/']
            expect(order4.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
      end
    end

    # describe 'optional_unit_forms_for_form' do
    #   subject { form.optional_unit_forms_for_form }
    #   context 'レコードがないとき' do
    #     let(:optional_unit_forms_attrs_arr) { [] }
    #     it 'OptionalUnitFromのoptional_urlsがいい感じ' do
    #       subject
    #       expect(subject[0].optional_urls).to eq ['']
    #       expect(subject[1].optional_urls).to eq ['']
    #       expect(subject[2].optional_urls).to eq ['']
    #       expect(subject[3].optional_urls).to eq ['']
    #       expect(subject[4].optional_urls).to eq ['']
    #     end
    #   end

    #   context 'optional_unitsレコードが3個あるとき' do
    #     let(:optional_unit_forms_attrs_arr) { [] }
    #     before do
    #       @optional_unit_a = create_optional_unit(
    #         org, supplier, ['https://example_a1.com', 'https://example_a2.com']
    #       )
    #       @optional_unit_b = create_optional_unit(
    #         org, supplier, ['https://example_b1.com', 'https://example_b2.com']
    #       )
    #       @optional_unit_c = create_optional_unit(
    #         org, supplier, ['https://example_c1.com', 'https://example_c2.com']
    #       )
    #       supplier.update(first_priority_unit_id: @optional_unit_c.id)
    #     end
    #     it 'OptionalUnitFromのoptional_urlsがいい感じ' do
    #       subject
    #       expect(subject[0].optional_urls).to eq ['https://example_a1.com', 'https://example_a2.com']
    #       expect(subject[1].optional_urls).to eq ['https://example_b1.com', 'https://example_b2.com']
    #       expect(subject[2].optional_urls).to eq ['https://example_c1.com', 'https://example_c2.com']
    #       expect(subject[3].optional_urls).to eq ['']
    #       expect(subject[4].optional_urls).to eq ['']
    #     end
    #   end

    #   context 'optional_unitsレコードがMAXの5個あるとき' do
    #     let(:optional_unit_forms_attrs) { [] }
    #     before do
    #       @optional_unit_a = create_optional_unit(
    #         org, supplier, ['https://example_a1.com', 'https://example_a2.com']
    #       )
    #       @optional_unit_b = create_optional_unit(
    #         org, supplier, ['https://example_b1.com', 'https://example_b2.com']
    #       )
    #       @optional_unit_c = create_optional_unit(
    #         org, supplier, ['https://example_c1.com', 'https://example_c2.com']
    #       )
    #       @optional_unit_d = create_optional_unit(
    #         org, supplier, ['https://example_d1.com', 'https://example_d2.com']
    #       )
    #       @optional_unit_e = create_optional_unit(
    #         org, supplier, ['https://example_e1.com', 'https://example_e2.com']
    #       )
    #       supplier.update(first_priority_unit_id: @optional_unit_c.id)
    #     end
    #     it 'OptionalUnitFromのoptional_urlsがいい感じ' do
    #       subject
    #       expect(subject[0].optional_urls).to eq ['https://example_a1.com', 'https://example_a2.com']
    #       expect(subject[1].optional_urls).to eq ['https://example_b1.com', 'https://example_b2.com']
    #       expect(subject[2].optional_urls).to eq ['https://example_c1.com', 'https://example_c2.com']
    #       expect(subject[3].optional_urls).to eq ['https://example_d1.com', 'https://example_d2.com']
    #       expect(subject[4].optional_urls).to eq ['https://example_e1.com', 'https://example_e2.com']
    #     end
    #   end
    # end

    # describe 'optional_unit_forms_for_save' do
    #   subject { form.optional_unit_forms_for_save }
    #   context 'optional_unitsレコードが2個あるとき' do
    #     let(:first_priority_attr) { '2' }
    #     let(:optional_unit_forms_attrs_arr) do
    #       [
    #         {
    #           optional_unit_id: @optional_unit_a.id.to_s,
    #           urls: ['https://example_11.com/', 'https://example_12.com/']
    #         },
    #         {
    #           optional_unit_id: @optional_unit_b.id.to_s,
    #           urls: ['https://example_21.com/', 'https://example_22.com/']
    #         },
    #         {
    #           optional_unit_id: nil,
    #           urls: ['https://example_31.com/', 'https://example_32.com/']
    #         },
    #         { optional_unit_id: nil, urls: ['', ''] },
    #         { optional_unit_id: nil, urls: ['', ''] }
    #       ]
    #     end
    #     before do
    #       @optional_unit_a = create_optional_unit(
    #         org, supplier, ['https://example_a1.com', 'https://example_a2.com']
    #       )
    #       @optional_unit_b = create_optional_unit(
    #         org, supplier, ['https://example_b1.com', 'https://example_b2.com']
    #       )
    #       supplier.update(first_priority_unit_id: @optional_unit_b.id)
    #     end
    #     it 'OptionalUnitFromのoptional_unit_url_id_and_url_arrayがいい感じ' do
    #       subject
    #       expect(subject[0].optional_urls).to eq ['https://example_11.com/', 'https://example_12.com/']
    #       expect(subject[1].optional_urls).to eq ['https://example_21.com/', 'https://example_22.com/']
    #       expect(subject[2].optional_urls).to eq ['https://example_31.com/', 'https://example_32.com/']
    #       expect(subject[3]).to eq nil
    #       expect(subject[4]).to eq nil
    #     end
    #   end
    # end
  end
end
