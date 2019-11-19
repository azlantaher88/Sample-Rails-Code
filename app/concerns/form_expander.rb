class FormExpander
  # == Constants ============================================================

  EXPANDABLE = %w[ if id ].freeze
  TYPE_DEFAULT = 'question'.freeze

  # == Properties ===========================================================

  attr_reader :data

  # == Instance Methods =====================================================

  def initialize(data)
    @data = expand(data)
  end

  def flatten
    @flatten ||= collapsed(@data)
  end

  def keys
    @keys ||= self.flatten.keys
  end

  def required
    @required ||= flatten.values.select do |node|
      node['required']
    end.map do |node|
      node['id']
    end.compact
  end

  def [](key)
    self.flatten[key]
  end

  def targets
    self.flatten.values.collect do |node|
      node['target']
    end.compact.uniq.sort
  end

  def target_fields(target)
    self.flatten.values.select do |node|
      node['target'] == target
    end.collect do |node|
      node['id']
    end
  end

  def to_h
    @data
  end

protected
  def expand(data, key_prefix = nil, target = nil, type = nil)
    case (data)
    when Hash
      data = data.stringify_keys

      EXPANDABLE.each do |key|
        if (data[key])
          data[key] = data[key].sub(/^\-/, '%s-' % key_prefix)
        end
      end
      
      if (data['title'] and !data['id'])
        data['id'] = [
          key_prefix,
          data['title'].gsub(/\W/, ' ').gsub(/\s+/, '_').downcase
        ].compact.join('-')
      end

      data['type'] ||= (type || TYPE_DEFAULT)

      key_prefix = data['id']

      if (target)
        data['target'] ||= target
      elsif (data['target'])
        target ||= data['target']
      end

      subtype =
        case (data['type'])
        when 'select'
          'selection'
        when 'options'
          'option'
        end

      Hash[
        data.collect do |key, value|
          [ key, expand(value, key_prefix, target, subtype) ]
        end
      ].freeze
    when Array
      data.collect do |e|
        expand(e, key_prefix, target, type)
      end.freeze
    else
      data
    end
  end

  def collapsed(data, object = { })
    case (data)
    when Hash
      case (data['type'])
      when 'section'
        # Ignored
      else
        if (data['id'])
          object[data['id']] = data
        end
      end

      if (data['data'])
        collapsed(data['data'], object)
      end
    when Array
      data.each do |item|
        collapsed(item, object)
      end
    end

    object
  end
end
