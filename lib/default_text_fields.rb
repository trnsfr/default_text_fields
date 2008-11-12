module ActionView
  module Helpers
    
    module FormTagHelper
      
      def form_for(record_or_name_or_array, *args, &proc)
        if args.first[:clear_before_submit]
          args.first[:html] ||= {}
          args.first[:html].merge!(:onsubmit => "$$('.blank').each(function(i) { if(navigator.userAgent.match(/Safari/) && i.tagName == 'TEXTAREA') {i.innerHTML = '';} else {i.value = '';}});return true")
        end
        super
      end
      
    end
    
    class FormBuilder
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormTagHelper
      
      def tag_with_default_text(tag_name, object, method, object_name, options={})
        object_value = eval("object.#{method}") rescue nil

        unless options[:default_text].blank?
          options[:onblur] = "if (this.value.match(/^ *$/)) { this.value='#{options[:default_text]}'; $(this).addClassName('blank'); };"
          options[:onfocus] = "if (this.value == '#{options[:default_text]}') { this.value=''; $(this).removeClassName('blank'); };"
          if object_value.blank? || object_value == options[:default_value]
            options.merge!(:value => options[:default_text], :class => [options[:class], "blank"].compact.join(" "))
          elsif options[:value].blank?
            options.merge!(:value => object_value)
          end
        end
        
        value = options[:value] || object_value
        options.delete(:value)
        options.delete(:default_text)

        case tag_name.to_sym
        when :text_field
          options[:size] ||= 30
          text_field_tag("#{object_name}[#{method}]", value, options)
        when :text_area
          options[:cols] ||= 30
          text_area_tag("#{object_name}[#{method}]", value, options)
        end
      end


      def text_field(method, options = {})
        tag_with_default_text(:text_field, @object, method, @object_name, options)
      end


      def text_area(method, options = {})
        tag_with_default_text(:text_area, @object, method, @object_name, options)
      end
      
    end
  end
end
