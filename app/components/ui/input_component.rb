module Ui
  class InputComponent < ViewComponent::Base
    def initialize(form:, name:, type: :text, **props)
      super()
      @form = form
      @name = name
      @type = type
      @class = props.delete(:class)
      @props = props
    end

    private

    def field(*props)
      case @type
      when :text then @form.text_field(*props)
      when :email then @form.email_field(*props)
      when :password then @form.password_field(*props)
      when :date then @form.date_field(*props)
      else
        raise ArgumentError, "'#{@type}' is invalid type"
      end
    end

    def data_attrs
      return {} if !@form.object || @form.object.errors.blank?

      {
        invalid: @form.object.errors.full_messages_for(@name)
      }
    end
  end
end
