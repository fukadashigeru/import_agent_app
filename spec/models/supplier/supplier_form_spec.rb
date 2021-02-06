require 'rails_helper'

RSpec.describe Supplier::SupplierForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      order: order,
      first_priority_attr: first_priority_attr,
      optional_unit_forms_attrs: optional_unit_forms_attrs
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:order) { create :order, ordering_org: org, supplier: supplier }
  let(:first_priority_attr) { '0' }
  let(:optional_unit_forms_attrs) do
    [
      { optional_unit_url_id: '', url: 'https://example_1.com/' },
      { optional_unit_url_id: nil, url: 'https://example_2.com/' },
      { optional_unit_url_id: nil, url: 'https://example_3.com/' }
    ]
  end

  describe 'save_units!' do
    subject { form.save_units! }
    context '3件とも新規' do
      context 'optional_unitを確認する' do
        it 'optional_unitで3個生成される' do
          expect { subject }.to change { supplier.optional_units.count }.by(3)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが3個生成される' do
          expect { subject }.to change { supplier.optional_units.map(&:optional_unit_urls).flatten.count }.by(3)
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
          expect(order.actual_unit.actual_unit_urls.count).to eq 1
        end
      end
      context 'supplier_urlsを確認する' do
        it 'supplier関連するsupplier_urlsが3個生成される' do
          subject
          expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).first.url).to eq 'https://example_1.com/'
        end
        it 'orderに関連するsupplier_urlsが1個生成される' do
          expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(1)
        end
        it 'orgに紐付いたsupplier_urlsが3個生成される' do
          expect { subject }.to change { org.supplier_urls.count }.by(3)
        end
      end
    end

    context '1件更新で2件新規：新規分が第一候補' do
      let(:first_priority_attr) { '1' }
      let(:optional_unit_forms_attrs) do
        [
          { optional_unit_url_id: optional_unit_url_a.id.to_s, url: 'https://example_1.com/' },
          { optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { optional_unit_url_id: nil, url: 'https://example_3.com/' }
        ]
      end
      let!(:supplier) { create :supplier, org: org }
      let!(:optional_unit_url_a) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a
      end
      let!(:supplier_url_a) { create :supplier_url, url: 'https://example_a.com', org: org }
      let!(:optional_unit_a) { create :optional_unit, supplier: supplier }
      before { supplier.update(first_priority_unit_id: optional_unit_a.id) }
      context 'optional_unitを確認する' do
        it 'optional_unitで2個生成される' do
          expect { subject }.to change { supplier.optional_units.count }.by(2)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが2個生成される' do
          expect { subject }.to change {
            supplier.optional_units.map(&:optional_unit_urls).flatten.count
          }.by(2)
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
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_2.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          let!(:actual_unit_url) do
            create :actual_unit_url, actual_unit: actual_unit, supplier_url: supplier_url_a
          end
          let(:actual_unit) { create :actual_unit, order: order }
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
            it 'actual_unit_urlのidが変わらない' do
              expect{ subject }.not_to(change { order.actual_unit.actual_unit_urls.map(&:id) })
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_2.com/']
            end
          end
        end
      end
    end

    context '1件更新で2件新規：更新分が第一候補' do
      let(:first_priority_attr) { '0' }
      let(:optional_unit_forms_attrs) do
        [
          { optional_unit_url_id: optional_unit_url_a.id.to_s, url: 'https://example_1.com/' },
          { optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { optional_unit_url_id: nil, url: 'https://example_3.com/' }
        ]
      end
      let!(:supplier) { create :supplier, org: org }
      let!(:optional_unit_url_a) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a
      end
      let!(:supplier_url_a) { create :supplier_url, url: 'https://example_a.com', org: org }
      let!(:optional_unit_a) { create :optional_unit, supplier: supplier }
      before { supplier.update(first_priority_unit_id: optional_unit_a.id) }
      context 'optional_unitを確認する' do
        it 'optional_unitで2個生成される' do
          expect { subject }.to change { supplier.optional_units.count }.by(2)
        end
      end
      context 'optional_unit_urlを確認する' do
        it 'optional_unit_urlが2個生成される' do
          expect { subject }.to change {
            supplier.optional_units.map(&:optional_unit_urls).flatten.count
          }.by(2)
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
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          let!(:actual_unit_url) do
            create :actual_unit_url, actual_unit: actual_unit, supplier_url: supplier_url_a
          end
          let(:actual_unit) { create :actual_unit, order: order }
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
            it 'actual_unit_urlのidが変わらない' do
              expect{ subject }.not_to(change { order.actual_unit.actual_unit_urls.map(&:id) })
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end
      end
    end

    context '3件とも更新' do
      let(:first_priority_attr) { '2' }
      let(:optional_unit_forms_attrs) do
        [
          { optional_unit_url_id: optional_unit_url_a.id.to_s, url: 'https://example_1.com/' },
          { optional_unit_url_id: optional_unit_url_b.id.to_s, url: 'https://example_2.com/' },
          { optional_unit_url_id: optional_unit_url_c.id.to_s, url: 'https://example_3.com/' }
        ]
      end
      let!(:supplier) { create :supplier, org: org }
      let!(:optional_unit_url_a) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a
      end
      let!(:supplier_url_a) { create :supplier_url, url: 'https://example_a.com', org: org }
      let!(:optional_unit_a) { create :optional_unit, supplier: supplier }
      before { supplier.update(first_priority_unit_id: optional_unit_a.id) }

      let!(:optional_unit_url_b) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a
      end
      let!(:supplier_url_b) { create :supplier_url, url: 'https://example_b.com', org: org }
      let!(:optional_unit_b) { create :optional_unit, supplier: supplier }
      before { supplier.update(first_priority_unit_id: optional_unit_b.id) }

      let!(:optional_unit_url_c) do
        create :optional_unit_url, optional_unit: optional_unit_c, supplier_url: supplier_url_c
      end
      let!(:supplier_url_c) { create :supplier_url, url: 'https://example_c.com', org: org }
      let!(:optional_unit_c) { create :optional_unit, supplier: supplier }
      before { supplier.update(first_priority_unit_id: optional_unit_c.id) }

      context 'optional_unitを確認する' do
        it 'optional_unitで生成されない' do
          expect { subject }.to change { supplier.optional_units.count }.by(0)
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
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_3.com/']
            end
          end
        end

        context 'actual_unitがある場合' do
          let!(:actual_unit_url) do
            create :actual_unit_url, actual_unit: actual_unit, supplier_url: supplier_url_a
          end
          let(:actual_unit) { create :actual_unit, order: order }
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
            it 'actual_unit_urlのidが変わらない' do
              expect{ subject }.not_to(change { order.actual_unit.actual_unit_urls.map(&:id) })
            end
          end
          context '実際の買付先URLを確認する' do
            it '実際の買付先のURlが第一候補になっている' do
              subject
              expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).map(&:url)).to eq ['https://example_3.com/']
            end
          end
        end
      end
    end

    # context '不正なパラメーター' do
    #   context 'optional_unitを確認する' do
    #     it 'optional_unitで3個生成される' do
    #       expect { subject }.to change { supplier.optional_units.count }.by(3)
    #     end
    #   end
    #   context 'optional_unit_urlを確認する' do
    #     it 'optional_unit_urlが3個生成される' do
    #       expect { subject }.to change { supplier.optional_units.map(&:optional_unit_urls).flatten.count }.by(3)
    #     end
    #   end
    #   context 'actual_unitを確認する' do
    #     it 'actual_unitが(1個)生成される' do
    #       subject
    #       expect(order.actual_unit).to be_present
    #     end
    #   end
    #   context 'actual_unit_urlを確認する' do
    #     it 'actual_unit_urlが1個生成される' do
    #       subject
    #       expect(order.actual_unit.actual_unit_urls.count).to eq 1
    #     end
    #   end
    #   context 'supplier_urlsを確認する' do
    #     it 'supplier関連するsupplier_urlsが3個生成される' do
    #       subject
    #       expect(order.actual_unit.actual_unit_urls.map(&:supplier_url).first.url).to eq 'https://example_1.com/'
    #     end
    #     it 'orderに関連するsupplier_urlsが1個生成される' do
    #       expect { subject }.to change { ActualUnitUrl.all.map(&:supplier_url).count }.by(1)
    #     end
    #     it 'orgに紐付いたsupplier_urlsが3個生成される' do
    #       expect { subject }.to change { org.supplier_urls.count }.by(3)
    #     end
    #   end
    # end
  end

  describe 'optional_unit_forms_for_form' do
    subject { form.optional_unit_forms_for_form }
    context 'レコードがないとき' do
      let(:optional_unit_forms_attrs) { [] }
      it 'OptionalUnitFromのoptional_unit_url_id_and_url_arrayが全て空配列' do
        subject
        expect(subject[0].optional_unit_url_id_and_url_array).to eq []
        expect(subject[1].optional_unit_url_id_and_url_array).to eq []
        expect(subject[2].optional_unit_url_id_and_url_array).to eq []
        expect(subject[3].optional_unit_url_id_and_url_array).to eq []
        expect(subject[4].optional_unit_url_id_and_url_array).to eq []
      end
    end

    context 'optional_unitsレコードが3個あるとき' do
      let(:optional_unit_forms_attrs) { [] }
      let!(:optional_unit_a) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_a1) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a1
      end
      let!(:optional_unit_url_a2) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a2
      end
      let!(:supplier_url_a1) { create :supplier_url, url: 'https://example_a1.com', org: org }
      let!(:supplier_url_a2) { create :supplier_url, url: 'https://example_a2.com', org: org }
      before { supplier.update(first_priority_unit_id: optional_unit_a.id) }

      let!(:optional_unit_b) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_b1) do
        create :optional_unit_url, optional_unit: optional_unit_b, supplier_url: supplier_url_b1
      end
      let!(:optional_unit_url_b2) do
        create :optional_unit_url, optional_unit: optional_unit_b, supplier_url: supplier_url_b2
      end
      let!(:supplier_url_b1) { create :supplier_url, url: 'https://example_b1.com', org: org }
      let!(:supplier_url_b2) { create :supplier_url, url: 'https://example_b2.com', org: org }

      let!(:optional_unit_c) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_c1) do
        create :optional_unit_url, optional_unit: optional_unit_c, supplier_url: supplier_url_c1
      end
      let!(:optional_unit_url_c2) do
        create :optional_unit_url, optional_unit: optional_unit_c, supplier_url: supplier_url_c2
      end
      let!(:supplier_url_c1) { create :supplier_url, url: 'https://example_c1.com', org: org }
      let!(:supplier_url_c2) { create :supplier_url, url: 'https://example_c2.com', org: org }
      it 'OptionalUnitFromのoptional_unit_url_id_and_url_arrayがいい感じ' do
        subject
        expect(subject[0].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_a1.id, url: 'https://example_a1.com' },
          { optional_unit_url_id: optional_unit_url_a2.id, url: 'https://example_a2.com' }
        ]
        expect(subject[1].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_b1.id, url: 'https://example_b1.com' },
          { optional_unit_url_id: optional_unit_url_b2.id, url: 'https://example_b2.com' }
        ]
        expect(subject[2].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_c1.id, url: 'https://example_c1.com' },
          { optional_unit_url_id: optional_unit_url_c2.id, url: 'https://example_c2.com' }
        ]
        expect(subject[3].optional_unit_url_id_and_url_array).to eq []
        expect(subject[4].optional_unit_url_id_and_url_array).to eq []
      end
    end

    context 'optional_unitsレコードがMAXの5個あるとき' do
      let(:optional_unit_forms_attrs) { [] }
      let!(:optional_unit_a) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_a1) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a1
      end
      let!(:optional_unit_url_a2) do
        create :optional_unit_url, optional_unit: optional_unit_a, supplier_url: supplier_url_a2
      end
      let!(:supplier_url_a1) { create :supplier_url, url: 'https://example_a1.com', org: org }
      let!(:supplier_url_a2) { create :supplier_url, url: 'https://example_a2.com', org: org }
      before { supplier.update(first_priority_unit_id: optional_unit_a.id) }

      let!(:optional_unit_b) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_b1) do
        create :optional_unit_url, optional_unit: optional_unit_b, supplier_url: supplier_url_b1
      end
      let!(:optional_unit_url_b2) do
        create :optional_unit_url, optional_unit: optional_unit_b, supplier_url: supplier_url_b2
      end
      let!(:supplier_url_b1) { create :supplier_url, url: 'https://example_b1.com', org: org }
      let!(:supplier_url_b2) { create :supplier_url, url: 'https://example_b2.com', org: org }

      let!(:optional_unit_c) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_c1) do
        create :optional_unit_url, optional_unit: optional_unit_c, supplier_url: supplier_url_c1
      end
      let!(:optional_unit_url_c2) do
        create :optional_unit_url, optional_unit: optional_unit_c, supplier_url: supplier_url_c2
      end
      let!(:supplier_url_c1) { create :supplier_url, url: 'https://example_c1.com', org: org }
      let!(:supplier_url_c2) { create :supplier_url, url: 'https://example_c2.com', org: org }

      let!(:optional_unit_d) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_d1) do
        create :optional_unit_url, optional_unit: optional_unit_d, supplier_url: supplier_url_d1
      end
      let!(:optional_unit_url_d2) do
        create :optional_unit_url, optional_unit: optional_unit_d, supplier_url: supplier_url_d2
      end
      let!(:supplier_url_d1) { create :supplier_url, url: 'https://example_d1.com', org: org }
      let!(:supplier_url_d2) { create :supplier_url, url: 'https://example_d2.com', org: org }

      let!(:optional_unit_e) { create :optional_unit, supplier: supplier }
      let!(:optional_unit_url_e1) do
        create :optional_unit_url, optional_unit: optional_unit_e, supplier_url: supplier_url_e1
      end
      let!(:optional_unit_url_e2) do
        create :optional_unit_url, optional_unit: optional_unit_e, supplier_url: supplier_url_e2
      end
      let!(:supplier_url_e1) { create :supplier_url, url: 'https://example_e1.com', org: org }
      let!(:supplier_url_e2) { create :supplier_url, url: 'https://example_e2.com', org: org }
      it 'OptionalUnitFromのoptional_unit_url_id_and_url_arrayがいい感じ' do
        subject
        expect(subject[0].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_a1.id, url: 'https://example_a1.com' },
          { optional_unit_url_id: optional_unit_url_a2.id, url: 'https://example_a2.com' }
        ]
        expect(subject[1].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_b1.id, url: 'https://example_b1.com' },
          { optional_unit_url_id: optional_unit_url_b2.id, url: 'https://example_b2.com' }
        ]
        expect(subject[2].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_c1.id, url: 'https://example_c1.com' },
          { optional_unit_url_id: optional_unit_url_c2.id, url: 'https://example_c2.com' }
        ]
        expect(subject[3].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_d1.id, url: 'https://example_d1.com' },
          { optional_unit_url_id: optional_unit_url_d2.id, url: 'https://example_d2.com' }
        ]
        expect(subject[4].optional_unit_url_id_and_url_array).to eq [
          { optional_unit_url_id: optional_unit_url_e1.id, url: 'https://example_e1.com' },
          { optional_unit_url_id: optional_unit_url_e2.id, url: 'https://example_e2.com' }
        ]
      end
    end
  end
end
