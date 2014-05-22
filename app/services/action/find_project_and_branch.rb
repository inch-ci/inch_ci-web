require 'inch_ci/action'

module Action
  module FindProjectAndBranch
    def find_project(params)
      uid = "#{params[:service]}:#{params[:user]}/#{params[:repo]}"
      InchCI::Store::FindProject.call(uid)
    end

    def find_branch(project, params)
      return if project.nil?
      if branch_name = params[:branch]
        InchCI::Store::FindBranch.call(project, branch_name)
      else
        InchCI::Store::FindDefaultBranch.call(project)
      end
    end
  end
end
