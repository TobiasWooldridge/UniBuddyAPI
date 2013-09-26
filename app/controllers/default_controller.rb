require 'github/markup'

class DefaultController < ApplicationController
  def index
    @readme = markdown_file(Rails.root.join('README.md').to_s)
  end

  def markdown_file path
    GitHub::Markup.render(path, File.read(path))
  end
end
