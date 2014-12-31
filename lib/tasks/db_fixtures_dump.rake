# Original from https://gist.github.com/iiska/1527911
#
namespace :db do
  namespace :fixtures do
    desc 'Dumps all models into fixtures.'
    task :dump => :environment do
      # Infer models from existing fixture files
      fixture_path = Rails.root.join('test', 'fixtures').to_s
      existing_fixtures = Dir[File.join(fixture_path, '**', '*.yml')]
      model_names = existing_fixtures.map do |s|
        basename = s.gsub(fixture_path+'/', '').gsub(/\.yml$/, '')
        basename.classify
      end

      active_record_models = model_names.map do |name|
        model = name.constantize rescue nil
        if model && model.ancestors.include?(ActiveRecord::Base)
          model
        else
          nil
        end
      end.compact

      active_record_models.each do |model|
        basename = "#{model.to_s.tableize}.yml"
        fixture_filename = File.join(fixture_path, basename)

        puts "Dumping #{basename}"
        records = model.order('id ASC')
        prefix = model.to_s.underscore.gsub('/', '_')

        File.open(fixture_filename.to_s, 'w') do |f|
          data = {}
          records.each do |r|
            data["#{prefix}_#{r.id}"] = r.attributes.reject { |k,v| v.blank? }
          end
          f.puts data.to_yaml
        end
      end
    end
  end
end
