task :info => :environment do
  project_uid = ENV['REPO'] || "github:rrrene/sparkr"

  project = InchCI::Store::FindProject.call(project_uid)
  #project.branches.size

  puts "Projects: #{Project.count}"
  puts "Builds: #{Build.count}"
  puts "Revisions: #{Revision.count}"
  puts "CodeObjectReferences: #{CodeObjectReference.count}"
  puts "CodeObjects: #{CodeObject.count}"
  puts "CodeObjectRoles: #{CodeObjectRole.count}"
  puts "RevisionDiffs: #{RevisionDiff.count}"
  puts "CodeObjectDiffs: #{CodeObjectDiff.count}"
  puts

  if revision = Revision.last
    puts "Latest revision:"
    puts "  #{revision.branch.project.uid} -- #{revision.uid}"
    puts "  #{revision.code_objects.count} code objects"
  end
end

task :revisions => :environment do
  Revision.all.each do |revision|
    puts "  #{revision.branch.project.uid} -- #{revision.code_objects.count} code objects"
  end
end
