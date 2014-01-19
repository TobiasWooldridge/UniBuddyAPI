load 'deploy/assets'

set :application, "FlindersAPI2"
set :repository,  "git@github.com:TobiasWooldridge/FlindersAPI2.git"

set :user, 'flindersapi'
set :domain, 'wooldridge.id.au'
set :applicationdir, "/opt/webapps/UnibuddyAPI"


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
ssh_options[:forward_agent] = true


namespace :rake do  
  desc "Run a task on a remote server."  
  # run like: cap staging rake:invoke task=a_certain_task  
  task :invoke do  
    run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")  
  end  
end
