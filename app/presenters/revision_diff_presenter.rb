class RevisionDiffPresenter < BasePresenter
  def code_objects=(objects)
    @code_objects ||= {}
    objects.eah do |object|
      @code_objects[object.id] = object
    end
    @code_objects
  end

  def code_object(id)
    @code_objects ||= {}
    CodeObjectPresenter.new(@code_objects[id] || CodeObject.find(id))
  end

  def revision
    @revision ||= RevisionPresenter.new(@resource.after_revision)
  end

  def change_count
    @change_count ||= [*changes.values].flatten.size
  end

  def changes
    @changes ||= begin
      map = {'added' => [], 'improved' => [], 'degraded' => [], 'removed' => [], }
      @resource.code_object_diffs.each do |diff|
        map[diff.change] ||= []
        map[diff.change] << diff
      end
      map
    end
  end
end
