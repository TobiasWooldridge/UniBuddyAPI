set :application, "FlindersAPI2"
set :repository,  "git@github.com:TobiasWooldridge/FlindersAPI2.git"

set :user, 'flindersapi'
set :domain, 'flindersapi.tobias.tw'
set :applicationdir, "appdir"


set :scm, :git
set :git_enable_submodules, 1
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_to, applicationdir
set :deploy_via, :remote_cache

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end



default_run_options[:pty] = true