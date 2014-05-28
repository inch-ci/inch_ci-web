class CodeObjectPresenter < BasePresenter
  def_delegators :code_object, :fullname, :grade, :priority, :docstring

  def_delegators :code_object, :project, :branch
  # TODO: use_presenters :project, :branch
  use_presenters :code_object_roles

  def bad_code_object_roles
    code_object_roles.select(&:bad?).sort_by do |role|
      [role.potential_score.to_i, role.name]
    end.reverse
  end

  def filename
    location.first
  end

  def line_no
    location.last
  end

  def name
    fullname.split('::').last.split('#').last
  end

  def priority_symbol(priority = @resource.priority)
    ::Inch::Evaluation::PriorityRange.all.each do |range|
      if range.include?(priority)
        return range.to_sym
      end
    end
  end

  def type
    @resource.type.downcase
  end

  private

  def location
    @__location ||= code_object.to_model.location.partition(':')
  end
end