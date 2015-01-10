module CodeObjectsHelper

  def link_to_code_object(revision, code_object)
    branch = revision.branch
    project = branch.project
    path = code_object_path(project, branch.name, revision.uid, :code_object => code_object)
    link_to code_object.fullname, path, :"data-code_object-id" => code_object.id, :remote => true, :method => :get
  end

  def url_on_github(filename, line_no = nil)
    base = "https://github.com/#{@project.user_name}/#{@project.repo_name}/blob/#{@revision.uid}/#{filename}"
    line_no ? "#{base}#L#{line_no}" : base
  end

  def show_code_object_location?(project = @project)
    %w(javascript nodejs).include?(project.language.to_s.downcase)
  end
end
