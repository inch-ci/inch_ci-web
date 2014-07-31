desc "Regenerates all badges in all styles for all projects"
task :badges => :environment do
  Project.all.each do |project|
    project.branches.each do |branch|
      if revision = branch.latest_revision
        code_objects = revision.code_objects
        InchCI::Worker::Project::Build::GenerateBadge.call(project, branch, code_objects)
      end
    end
  end
end
