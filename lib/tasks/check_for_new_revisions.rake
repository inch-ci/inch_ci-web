task :kill_dead_builds => :environment do
  timestamp = Time.now - 1000

  builds = Build.where('status = ? AND started_at < ?', 'running', timestamp)
  builds.update_all(:status => 'failed:dead')
end

task :check_for_new_revisions => :environment do
  since = 1.hour
  timestamp = Time.now - since
  trigger = 'cron'
  client = InchCI::Worker::Project::UpdateInfo::GitHubInfo.client

  projects = InchCI::Store::FindAllProjects.call()

  projects = projects.select do |project|
    if InchCI::Worker::Project.build_on_inch_ci?(project.language)
      if latest = InchCI::Store::FindLatestBuildInProject.call(project)
        latest.finished_at && latest.finished_at < timestamp
      end
    end
  end

  enqueued_builds = []

  projects.each do |project|
    begin
      if branch = InchCI::Store::FindDefaultBranch.call(project)
        last_commit = client.commits(project.name, branch.name).first
        rev = InchCI::Store::FindRevision.call(branch, last_commit.sha)
        if rev.nil?
          enqueued_builds << InchCI::Worker::Project::Build.enqueue(project.repo_url, branch.name, nil, trigger)
        end
      end
    rescue Octokit::NotFound
      puts "[Octokit::NotFound] #{project.uid}"
    rescue Faraday::ConnectionFailed
      puts "[Faraday::ConnectionFailed] #{project.uid}"
    rescue Errno::ETIMEDOUT
      puts "[Errno::ETIMEDOUT] #{project.uid}"
    end
  end

  puts [
        Time.now,
        "checked #{projects.size} projects",
        "enqueued #{enqueued_builds.size} builds:",
        enqueued_builds.map(&:id).inspect
      ].map(&:to_s).join("\t")
end
