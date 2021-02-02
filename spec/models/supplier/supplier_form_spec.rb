require 'rails_helper'

RSpec.describe Supplier::SupplierForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      optional_unit_forms_attrs: optional_unit_forms_attrs
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:optional_unit_forms_attrs) do
    [
      { first_priority: true, optional_unit_url_id: nil, url: 'https://example_1.com/' },
      { first_priority: false, optional_unit_url_id: nil, url: 'https://example_2.com/' },
      { first_priority: false, optional_unit_url_id: nil, url: 'https://example_3.com/' }
    ]
  end

  describe 'call!' do
    subject { form.call! }
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
    context 'supplier_urlsを確認する' do
      it 'supplier_urlsが3個生成される' do
        expect { subject }.to change {
          supplier.optional_units.map(&:optional_unit_urls).flatten.map(&:supplier_url).count
        }.by(3)
      end
      it 'orgに紐付いたsupplier_urlsが3個生成される' do
        expect { subject }.to change { org.supplier_urls.count }.by(3)
      end
    end
  end

  describe 'optional_unit_forms' do
    subject { form.optional_unit_forms }
    context 'optional_unit_forms_attrsの中身がからのとき' do
      let(:optional_unit_forms_attrs) { [] }
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 3
        expect(subject.first).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.second).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.third).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.fourth).to be nil
      end
    end
    context 'optional_unit_forms_attrsの中身が2個あるとき' do
      let(:optional_unit_forms_attrs) do
        [
          { first_priority: true, optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_2.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 3
        expect(subject.first).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.second).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.third).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
      end
    end
    context 'optional_unit_forms_attrsの中身が3個あるとき' do
      let(:optional_unit_forms_attrs) do
        [
          { first_priority: true, optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_3.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 3
        expect(subject.first).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.second).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.third).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
      end
    end
    context 'optional_unit_forms_attrsの中身が4個あるとき' do
      let(:optional_unit_forms_attrs) do
        [
          { first_priority: true, optional_unit_url_id: nil, url: 'https://example_1.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_2.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_3.com/' },
          { first_priority: false, optional_unit_url_id: nil, url: 'https://example_4.com/' }
        ]
      end
      it 'OptionalUnitFormが3個つくられる' do
        expect(subject.count).to eq 4
        expect(subject.first).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.second).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.third).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
        expect(subject.fourth).to be_an_instance_of(Supplier::SupplierForm::OptionalUnitForm)
      end
    end
  end
end
