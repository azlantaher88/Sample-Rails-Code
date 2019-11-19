class Admin::BaseController < ApplicationController
  layout 'internal'

  before_action :require_admin

  def self.selection(name, **opts)
    @selection_config ||= { }
    name = name.to_sym

    @selection_config[name] = {
      name: name,
      label: name.to_s.titleize,
      path: { selection: name },
      scope: name == :all ? nil : name
    }.merge(opts)
  end

  def self.selection_config
    @selection_config ||= {
      all: {
        name: :all,
        label: 'All',
        path: { },
        scope: false
      }
    }
  end

  def selection_config
    self.class.selection_config
  end
  helper_method :selection_config

  def selection
    self.class.selection_config[self.selection_active]
  end
  helper_method :selection

  def selection_active
    params[:selection] ? params[:selection].to_sym : self.selection_default
  end
  helper_method :selection_active

  def selection_default
    @selection_default ||= begin
      entries = self.class.selection_config.values

      entry = entries.find do |config|
        config[:default]
      end || entries.first

      entry and entry[:name] or :all
    end
  end
  helper_method :selection_default

  def selection_scope
    config = self.selection

    case (_scope = config[:scope])
    when Symbol
      self.scope.send(_scope)
    when Proc
      _scope[self.scope]
    else
      self.scope
    end
  end
  helper_method :selection_scope

  def selection_params(options = nil)
    {
      selection: params[:selection]
    }.merge(options || { })
  end
  helper_method :selection_params
end
