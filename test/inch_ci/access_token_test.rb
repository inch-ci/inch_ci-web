require 'test_helper'

describe ::InchCI::AccessToken do
  let(:file) { File.join("tmp/access_token.yml") }
  let(:access_token) { ::InchCI::AccessToken.new(file) }

  before { FileUtils.rm_f(file) }

  describe "with contents" do
    before do
      File.open(file, "w") { |fh| fh.write("github: bar\n") }
    end

    it "has access token" do
      assert_equal "bar", access_token["github"]
    end

    it "stringifies key" do
      assert_equal access_token["github"], access_token[:github]
    end
  end

  describe "with empty file" do
    before { FileUtils.touch(file) }

    it "has no access tokens" do
      assert File.exist?(file)
      assert_nil access_token[:github]
    end
  end

  describe "w/o a file" do
    it "has no access tokens" do
      refute File.exist?(file)
      assert_nil access_token[:github]
    end
  end
end
