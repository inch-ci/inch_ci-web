class CodeObjectPresenter < BasePresenter
  def_delegators :code_object, :fullname, :grade, :priority

  def filename
    location.first
  end

  def line_no
    location.last
  end

  def priority_symbol

  end

  def priority_symbol(priority = @resource.priority)
    ::Inch::Evaluation::PriorityRange.all.each do |range|
      if range.include?(priority)
        return range.to_sym
      end
    end
  end

  private

  def location
    @__location ||= code_object.to_model.location.partition(':')
  end
end