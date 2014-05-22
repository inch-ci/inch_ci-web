class CodeObjectRole < ActiveRecord::Base
  belongs_to :code_object
  belongs_to :code_object_role_name
end
