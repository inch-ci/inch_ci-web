class CodeObjectPresenter < BasePresenter
  def_delegators :code_object, :fullname, :grade, :priority

  def priority_symbol

  end

  def priority_symbol(priority = @resource.priority)
    ::Inch::Evaluation::PriorityRange.all.each do |range|
      if range.include?(priority)
        return range.to_sym
      end
    end
  end

end