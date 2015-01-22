require 'inch'
require 'fileutils'
require 'inch_ci/worker/project/build_json'

module Api
  class BuildsController < ApplicationController
    protect_from_forgery with: :null_session

    def hint
      render_text "> Greetings, Professor Falken.\n\n> _\n"
    end

    def run
      # let's ensure backwards compatibility
      params[:language] = 'javascript' if params[:language] == 'nodejs'

      if valid_params?
        file = dump_request_to_file
        if build = enqueue_build(file.path)
          copy_file(file, build)
          update_project_if_necessary(build.project)

          render_text "Successfully created build ##{build.number}\n" \
                    "URL: #{project_url(build.project)}\n"
        else
          render_text "[ERROR] Build could not be created.\n"
        end
      else
        render_text "[ERROR] #{@param_errors}\n"
      end
    end

    private

    def dump_request_to_file
      write_file filename_with_extension, JSON.pretty_generate(params)
    end

    def enqueue_build(filename)
      InchCI::Worker::Project::BuildJSON.enqueue(filename)
    end

    def filename_for_build(build)
      Rails.root.join('dumps', 'builds', "build-#{build.id}.json")
    end

    def filename_with_extension
      dir = Rails.root.join('dumps', 'builds', language_from_params, Time.now.strftime('%Y%m%d'))
      File.join(dir, request.object_id.to_s + '.json')
    end

    def language_from_params
      params[:language]
    end

    def copy_file(file, build)
      FileUtils.copy file.path, filename_for_build(build)
    end

    def render_text(text)
      render :text => text, :content_type => "text/plain"
    end

    def update_project_if_necessary(project)
      if !project.default_branch # this project is new
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(project.uid)
      end
    end

    def write_file(filename, contents)
      FileUtils.mkdir_p File.dirname(filename)
      file = File.new(filename, 'w')
      file.write contents
      file.close
      file
    end

    def valid_params?
      if language_from_params.to_s.empty?
        @param_errors = "No language defined."
      end
      @param_errors.nil?
    end
  end
end
