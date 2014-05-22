module InchCI
  module Controller
    def expose(view)
      view.exposures.each do |name|
        value = view.send(name)
        instance_variable_set("@#{name}", value)
      end
    end
  end
end
