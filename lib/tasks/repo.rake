task :repo => :environment do
  InchCI::Worker::Project::Build.enqueue("https://github.com/rrrene/sparkr.git")
  #InchCI::Worker::Project::BuildTags.enqueue("https://github.com/rrrene/sparkr.git")
  InchCI::Worker::Project::UpdateInfo.enqueue("github:rrrene/sparkr")
end
