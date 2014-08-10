task :build_tags => :environment do
  nwo = ENV['REPO'] || 'rrrene/sparkr'
  url = "https://github.com/#{nwo}.git"
  InchCI::Worker::Project::Build.enqueue(url)
  InchCI::Worker::Project::BuildTags.enqueue(url)
  InchCI::Worker::Project::UpdateInfo.enqueue("github:#{nwo}")
end
