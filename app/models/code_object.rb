class CodeObject < ActiveRecord::Base
  self.inheritance_column = 'zoink' # we use the type column ourselve

  belongs_to :project

  has_many :code_object_roles, :dependent => :destroy

  accepts_nested_attributes_for :code_object_roles

  validate :fullname, :presence => true, :uniqueness => {:scope => :revision}
end
