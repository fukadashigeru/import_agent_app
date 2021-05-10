class SuppliersController < ApplicationController
  before_action :logged_in_user
  before_action :set_org
  before_action :set_suppliers, only: %i[index]
  before_action :set_supplier, only: %i[show edit update]

  def index
  end

  def show
  end

  def edit
    @supplier_form = Supplier::SupplierForm.new(
      ordering_org: @org,
      supplier: @supplier
    )
    @optional_unit_forms = @supplier_form.forms
    @redirect = params[:redirect]
    @status = params[:status]
  end

  def update
    @supplier_form = Supplier::SupplierForm.new(
      ordering_org: @org,
      supplier: @supplier,
      first_priority_attr: first_priority_attr,
      order_ids: order_ids,
      forms_attrs_array: forms_attrs_array
    )
    if @supplier_form.valid?
      @supplier_form.upsert_or_destroy_units!
    else
      flash[:danger] = '処理が完了できませんでした。'
    end
    case params[:redirect].to_sym
    when :before_orders
      redirect_to [@org, :orders, :before_orders]
    when :suppliers_show
      redirect_to [@org, @supplier]
    end
  end

  private

  def set_org
    @org = Org.find(params[:org_id])
  end

  def set_suppliers
    @suppliers = @org.suppliers.page(params[:page]).per(30)
  end

  def set_supplier
    @supplier =
      @org.suppliers.includes(
        first_priority_unit: :supplier_urls,
        optional_units: :supplier_urls,
        orders: { actual_unit: :supplier_urls }
      ).find(params[:id])
  end

  def first_priority_attr
    normalize_params(
      params
      .permit(:first_priority)
    ).fetch(:first_priority, nil)
  end

  def actual_first_priority_attr
    normalize_params(
      params
      .permit(:actual_first_priority)
    ).fetch(:actual_first_priority, nil)
  end

  def forms_attrs_array
    normalize_params(
      params
      .permit(optional_unit_forms: {})
    ).fetch(:optional_unit_forms, {}).values
  end

  def order_ids
    if normalize_params(params.permit(:order_ids)).present?
      # 'all'
      order_ids_all
    else
      # ['1','2','3']
      order_ids_array
    end
  end

  def order_ids_array
    normalize_params(
      params
      .permit(order_ids: [])
    ).fetch(:order_ids)
  end

  def order_ids_all
    normalize_params(
      params
      .permit(:order_ids)
    ).fetch(:order_ids)
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

  def flash_base_validation_error_msg(record)
    flash.now[:danger] = record.errors.full_messages_for(:base) if record.errors[:base].any?
  end
end
