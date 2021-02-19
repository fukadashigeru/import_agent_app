class SuppliersController < ApplicationController
  before_action :set_org
  before_action :set_supplier
  before_action :set_order

  def edit
    @form = Supplier::SupplierForm.new(
      ordering_org: @org,
      supplier: @supplier,
      order: @order
    )
    @optional_unit_forms = @form.optional_unit_forms_for_form
  end

  def update
    @form = Supplier::SupplierForm.new(
      ordering_org: @org,
      supplier: @supplier,
      order: @order,
      first_priority_attr: first_priority_attr,
      actual_first_priority_attr: actual_first_priority_attr,
      optional_unit_forms_attrs_arr: optional_unit_forms_attrs_arr
    )
    @form.upsert_or_destroy_units!
    redirect_to [@org, :orders, :before_orders]
  end

  # private

  def set_org
    @org = Org.find(params[:org_id])
  end

  def set_supplier
    @supplier = @org.suppliers.find(params[:id])
  end

  def set_order
    @order = @supplier.orders.find(params[:order_id])
  end

  def first_priority_attr
    normalize_params(
      params
      .permit(:first_priority)
    ).fetch(:first_priority, {})
  end

  def actual_first_priority_attr
  end

  def optional_unit_forms_attrs_arr
    normalize_params(
      params
      .permit(optional_unit_forms: {})
    ).fetch(:optional_unit_forms, {}).values
  end

  def normalize_params(permitted_params)
    p =
      permitted_params
      .to_h
      .deep_symbolize_keys

    deep_hash_filter(p)
  end

  def deep_hash_filter(hash)
    hash.map do |key, val|
      new_val =
        case val
        when Hash then deep_hash_filter(val)
        else val == '' ? nil : val
        end

      [key, new_val]
    end.to_h
  end
end
