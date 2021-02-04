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
      { optional_unit_url_id: nil, url: 'https://example_1.com/' },
      { optional_unit_url_id: nil, url: 'https://example_2.com/' },
      { optional_unit_url_id: nil, url: 'https://example_3.com/' }
    ]
  end

  describe 'save_units!' do
    subject { form.save_units! }
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

  describe 'optional_unit_forms' do
    subject { form.optional_unit_forms }
    context 'optional_unit_forms_attrsの中身がからのとき' do
      let(:first_priority_attr) { nil }
      let(:optional_unit_forms_attrs) { [] }
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 5
        expect(subject[0]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[1]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[2]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[3]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[4]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[5]).to be nil
      end
    end
    context 'optional_unit_forms_attrsの中身が2個あるとき' do
      let(:first_priority_attr) { '1' }
      let(:optional_unit_forms_attrs) do
        [
          { optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { optional_unit_url_id: nil, url: 'https://example_2.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 5
        expect(subject[0]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[1]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[2]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[3]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[4]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[5]).to be nil
      end
    end
    context 'optional_unit_forms_attrsの中身が3個あるとき' do
      let(:first_priority_attr) { '2' }
      let(:optional_unit_forms_attrs) do
        [
          { optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { optional_unit_url_id: nil, url: 'https://example_3.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 5
        expect(subject[0]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[1]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[2]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[3]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[4]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[5]).to be nil
      end
    end
    context 'optional_unit_forms_attrsの中身が4個あるとき' do
      let(:first_priority_attr) { '3' }
      let(:optional_unit_forms_attrs) do
        [
          { first_priority: true, optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { optional_unit_url_id: nil, url: 'https://example_3.com/' },
          { optional_unit_url_id: nil, url: 'https://example_4.com/' },
          { optional_unit_url_id: nil, url: 'https://example_5.com/' },
          { optional_unit_url_id: nil, url: 'https://example_6.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 6
        expect(subject[0]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[1]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[2]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[3]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[4]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[5]).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject[6]).to be nil
      end
    end
  end
end
