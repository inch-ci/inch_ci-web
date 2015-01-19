class PageController < ApplicationController
  layout :determine_layout

  private

  def determine_layout
    case action_name
    when /help_/
      'page'
    else
      'cover'
    end
  end

end
