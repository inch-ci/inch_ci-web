class CodeObject < ActiveRecord::Base
  self.inheritance_column = 'zoink' # we use the type column ourselve

  belongs_to :project

  has_many :code_object_roles, :dependent => :destroy

  accepts_nested_attributes_for :code_object_roles

  validate :fullname, :presence => true, :uniqueness => {:scope => :revision}

  before_save :remove_emojis_before_save

  private

  def remove_emojis_before_save
    self.docstring = self.class.remove_emojis(self.docstring)
  end

  def self.remove_emojis(string)
    string.gsub(/[\u{1F600}-\u{1F6FF}]/, "")
  end
end
