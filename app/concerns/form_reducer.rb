class FormReducer
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(version)
    @version = version
  end

  def reduced(report)
    return unless (report and report.content)

    reduce_into(report.content, @version, [ ], false)
  end

  def reduce_into(report, node, reduced, parent = nil)
    case (node)
    when Array
      node.each do |_node|
        reduce_into(report, _node, reduced, parent)
      end
    when Hash
      case (node['type'])
      when 'section', 'select', 'options'
        data = [ ]

        reduce_into(report, node['data'], data, node)

        unless (data.empty?)
          reduced << node.merge('data' => data)
        end
      when 'question'
        if (report[node['id']].present?)
          reduced << node
        end
      when 'selection'
        if (report[parent['id']] == node['id'])
          reduced << node
        end
      when 'option'
        values = report[parent['id']]

        if (values and values.include?(node['id']))
          reduced << node
        end
      end
    end

    reduced
  end
end
