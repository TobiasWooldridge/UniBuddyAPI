require 'github/markup'

class DefaultController < ApplicationController
  def index
    @readme = markdown_file('/home/tobias/Projects/FlindersAPI2/README.md')
  end

  def markdown_file path
    GitHub::Markup.render(path, File.read(path))
  end
end
