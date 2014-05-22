class WorkerOutputMock
  MOCKS_FILE = File.join(Rails.root, 'test', 'worker_outputs.yml')
  MOCKS = YAML.load( File.read(MOCKS_FILE) )

  # @return [Hash] a mocked worker output
  def self.[](key)
    if hash = MOCKS[key.to_s]
      hash
    else
      raise "WorkerOutputMock not found: #{key.inspect}"
    end
  end

  # @return [Hash] a mocked worker output
  def self.hash(key)
    self[key.to_s]
  end

  # @return [String] a mocked worker output
  def self.string(key)
    self[key.to_s].to_yaml
  end
end
