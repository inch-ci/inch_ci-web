class CodeObjectRolePresenter < BasePresenter
  def_delegators :code_object_role, :ref_name, :priority, :score, :potential_score, :min_score, :max_score

  def bad?
    potential_score.to_i > 0
  end

  def name
    code_object_role.code_object_role_name.name
  end

  def to_desc(object = nil)
    args = {
      :object_type => object && object.type,
      :ref_name => ref_name || object && object.name
    }
    I18n.t(to_i18n_key, args)
  end

  def to_i18n_key
    to_partial.gsub('/', '.')
  end

  def to_partial
    "shared/code_object_roles/#{name.underscore}"
  end
end