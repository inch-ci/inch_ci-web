module CodeObjectsHelper

  def link_to_code_object(revision, code_object)
    branch = revision.branch
    project = branch.project
    path = code_object_path(project, branch.name, revision.uid, :code_object => code_object)
    link_to code_object.fullname, path, :"data-code_object-id" => code_object.id, :remote => true, :method => :get
  end
end
