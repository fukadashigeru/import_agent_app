module PlaceOrders
  class ImportsController < ApplicationController
    before_action :set_org

    # rescue_from ActiveRecord::RecordInvalid do |e|
    #   ErrorUtil.log_and_notify(e)
    #   flash[:danger] = <<~MSG
    #     インポート処理を完了できませんでした。
    #   MSG
    #   redirect_to [@org, :orders, :before_orders]
    # end

    def show
      @form = PlaceOrders::Form.new(ordering_org: @org)
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @form = PlaceOrders::Form.new(ordering_org: @org, **form_params)
      if @form.valid?
        @importer = @form.build_importer
        begin
          if @importer.call
            flash[:success] = 'インポート処理が完了しました。'
          else
            flash[:danger] = @importer.errors.full_messages
          end
        rescue ActiveRecord::RecordInvalid => e
          ErrorUtil.log_and_notify(e)
          flash[:danger] = <<~MSG
            インポート処理を完了できませんでした。
          MSG
        end
        redirect_to [@org, :orders, :before_orders]
      else
        flash[:danger] = @form.errors.full_messages
        render 'show'
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def set_org
      @org = Org.find(params[:org_id])
    end

    def form_params
      normalize_params(
        params.required(:place_orders_form).permit(
          :ec_shop_type,
          :csv_file
        )
      )
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
end
