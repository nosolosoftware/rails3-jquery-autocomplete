module Rails3JQueryAutocomplete
  module Orm
    module Mongoid
      def get_autocomplete_order(method, options, model=nil)
        order = options[:order]
        if order
          order.split(',').collect do |fields|
            sfields = fields.split
            [sfields[0].downcase.to_sym, sfields[1].downcase.to_sym]
          end
        else
          [[method.to_sym, :asc]]
        end
      end

      def get_autocomplete_items(parameters)
        model          = parameters[:model]
        method         = parameters[:method]
        options        = parameters[:options]
        column_name    = Array(options[:column_name])
        scopes         = Array(options[:scopes_with_values])
        is_full_search = options[:full]
        term           = parameters[:term]
        limit          = get_autocomplete_limit(options)
        order          = get_autocomplete_order(method, options)

        if is_full_search
          search = '.*' + Regexp.escape(term) + '.*'
        else
          search = '^' + Regexp.escape(term)
        end

        items = model
        Hash[scopes].each{ |scope, values| items = items.send(scope, *(values||[nil]) ) }

        if column_name.size > 1
          column_name.each{ |column| items = items.or( column.to_sym => /#{search}/i ) }
        else
          items = items.where(method.to_sym => /#{search}/i)
        end

        items.limit(limit).order_by(order)
      end
    end
  end
end
