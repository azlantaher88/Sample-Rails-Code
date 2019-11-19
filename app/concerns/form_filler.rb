class FormFiller
  # == Constants ============================================================

  STRATEGIES = [
    :all,
    :random,
    :minimum
  ].freeze

  STRATEGY_DEFAULT = STRATEGIES.first

  # == Class Methods ========================================================

  def self.strategies
    STRATEGIES
  end

  # == Instance Methods =====================================================

  def initialize(version, strategy = nil)
    @version = version
    @flat = @version.expander.flatten
    @strategy = strategy
  end

  def fields(&block)
    filter =
      if (block_given?)
        block
      else
        lambda { true }
      end

    @flat.values.select do |node|
      filter[node]
    end.collect do |node|
      node['id']
    end
  end

  def fields_all
    fields do |node|
      case (node['type'])
      when 'selection', 'option'
        false
      else
        true
      end
    end
  end

  def fields_random
    fields do |node|
      case (node['type'])
      when 'selection', 'option'
        false
      else
        node['required'] or SecureRandom.random_number >= 0.5
      end
    end
  end

  def fields_required
    fields do |node|
      node['required']
    end
  end

  def report
    content = { }

    case (@strategy)
    when :all
      fields_all
    when :random
      fields_random
    else
      fields_required
    end.each do |field|
      node = @flat[field]

      case (node['type'])
      when 'select'
        content[node['id']] = node['data'].shuffle.collect do |node|
          node['id']
        end.first
      when 'options'
        # FUTURE: Required options are not properly supported, but at this
        # time the form doesn't have fields like that.
        content[node['id']] = node['data'].shuffle.select do |node|
          randomly_include?
        end.collect do |node|
          if (node['input'])
            content[node['id']] = random_string
          end

          node['id']
        end
      when 'question'
        content[node['id']] = (node['times'] || 1).times.collect do
          random_string + '.'
        end.join(' ')
      end
    end

    Report.new(
      version: @version,
      content: content
    )
  end

  def random_string
    Faker::Lorem.words(random_in_range(1, 20)).join(' ')
  end

  def random_in_range(min, max)
    min + SecureRandom.random_number * (max - min)
  end

  def randomly_include?
    case (@strategy)
    when :all
      true
    when :required
      false
    else
      SecureRandom.random_number >= 0.5
    end
  end
end
