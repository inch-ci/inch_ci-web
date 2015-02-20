class HelpController < ApplicationController

  layout :determine_layout

  private

  def determine_layout
    case action_name
    when /about/
      'cover'
    else
      'page'
    end
  end

end
