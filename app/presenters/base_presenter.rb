# A BasePresenter object represents a +resource+ (i.e. data object) in the
# view layer of application delivery.
#
# == Creation
#
# You create a Presenter object by subclassing BasePresenter:
#
#   class ProjectPresenter < BasePresenter
#   end
#
# The constructor takes the +resource+ as its single parameter:
#
#   p = Project.new(:name => "Test project")
#   presenter = ProjectPresenter.new(p)
#
# This presenter is not yet capable of anything:
#
#   presenter.name # => NoMethodError: ...
#
# You can easily create delegates to existing attributes of the represented +resource+:
#
#   class ProjectPresenter < BasePresenter
#     def_delegators :project, :name, :description
#   end
#
# This creates a Presenter class for Project objects and delegates the
# +name+ and +description+ attributes to the original +project+ object.
#
#   presenter.name # => "Test project"
#
# == Exposing presenters through the controller
#
# To use presenter objects in the view layer, we can expose them through
# the controller. This works by defining which instance variables should be
# available as presenter objects in the view layer.
#
#   class ProjectController < ApplicationController
#     expose_presenters :project, :projects
#   end
#
# This defines two (helper-)methods +project+ and +projects+, that look
# up +@project+ and +@projects+ and convert them to presenter objects.
#
# Now, the following view code works:
#
#   <h1><%= project.name %></h1>
#
#
# == Adding custom methods
#
# Adding custom methods enables you to represent information in a
# context-sensitive way:
#
#   class ProjectPresenter < BasePresenter
#     def_delegators :project, :name, :description
#
#     def label
#       if project.active?
#         project.name
#       else
#         "[OLD] " + project.name
#       end
#     end
#   end
#
#   presenter.label # => "Test project"
#   presenter.active = false
#   presenter.label # => "[OLD] Test project"
#
# == Using presenters for associations
#
# To illustrate this suppose we have a model Station that is associated
# with a Project.
#
#   class StationPresenter
#     def_delegators :branch, :project
#   end
#
#   p = BranchPresenter.new(...).project # => Project
#   p.label # => NoMethodError: ...
#
# This is because the project method is delegated to the +resource+ and
# returns such a data object itself. This is were use_presenters helps:
#
#   class BranchPresenter
#     use_presenters :project
#   end
#
#   p = BranchPresenter.new(...).project # => ProjectPresenter
#   p.label # => "[OLD] Test project"
#
class BasePresenter
  extend Forwardable

  def_delegators :@resource, :id, :new_record?, :to_param, :to_json, :to_xml, :to_yaml

  # @param resource [ActiveRecord::Base]
  def initialize(resource)
    @resource = resource
  end

  # Returns the actual resource object the presenter is representing.
  #
  # Example:
  #
  #   p = Project.new
  #   ProjectPresenter.new(p).to_model # => p
  #
  # In this case to_model returns the original Project object.
  #
  # This is called by rails helper methods (e.g. 'dom_id')
  #
  # @return [ActiveRecord::Base,Object] the presented data object
  def to_model
    @resource
  end

  class << self
    # Defines a reader method named according to the presenter that returns
    # the presenters resource, so can refer to your data object in a natural
    # way.
    #
    # Example:
    #
    #   class ProjectPresenter < BasePresenter
    #     def label
    #       if project.active?
    #         project.name
    #       else
    #         "[OLD] " + project.name
    #       end
    #     end
    #   end
    #
    # @return [void]
    def inherited(subclass)
      name = subclass.to_s.gsub(/Presenter$/, '').split("::").last.underscore
      subclass.__send__(:define_method, name) { @resource }
    end

    # Defines associations which should return a Presenter object rather
    # than an ActiveRecord object.
    #
    # Example:
    #
    #   class StationPresenter
    #     def_delegators :station, :project
    #   end
    #
    #   StationPresenter.new(...).project # => Project
    #
    #   class StationPresenter
    #     use_presenters :project
    #   end
    #
    #   StationPresenter.new(...).project # => ProjectPresenter
    #
    # @return [void]
    def use_presenters(*names)
      names.each do |name|
        define_method(name) do
          if var = instance_variable_get("@#{name}")
            var
          else
            var = @resource.__send__(name)
            if var
              if var.respond_to?(:map)
                instance_variable_set "@#{name}", var.map(&:to_presenter)
              else
                instance_variable_set "@#{name}", var.to_presenter
              end
            end
          end
        end
      end
    end
  end

  # Contains methods that can be included into Rails controllers.
  module ControllerMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Exposes data objects to the view layer via their designated presenters.
      #
      # Example:
      #
      #   class StationController < ApplicationController
      #     expose_presenters :station, :stations
      #   end
      #
      # This defines two (helper-)methods +station+ and +stations+, that look
      # up +@station+ and +@stations+ and convert them to presenter objects.
      #
      # @param names [Array<String, Symbol>] names of the to-be-created methods
      # @return [void]
      def expose_presenters(*names)
        if names.empty?
          class_name = to_s.split('::').last.gsub(/Controller$/, '')
          collection_name = class_name.underscore
          resource_name = collection_name.singularize
          names = [resource_name, collection_name]
        end

        names.each do |name|
          define_method name do
            cached = instance_variable_get("@#{name}__presenter")
            if cached
              cached
            else
              obj = instance_variable_get("@#{name}")
              return if obj.nil?
              cached = if obj.is_a?(Array) || obj.is_a?(ActiveRecord::Relation)
                obj.map(&:to_presenter)
              else
                obj.to_presenter
              end
              instance_variable_set("@#{name}__presenter", cached)
            end
          end
          helper_method name
        end
      end
    end
  end
end

class ActiveRecord::Base
  def to_presenter
    Module.const_get(self.class.to_s+'Presenter').new(self)
  end
end
