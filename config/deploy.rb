# capistranoのバージョンを記載。固定のバージョンを利用し続け、バージョン変更によるトラブルを防止する
lock '3.20.1'

# Capistranoのログの表示に利用する
set :application, 'research_log2'

# どのリポジトリからアプリをpullするかを指定する
set :repo_url,  'git@github.com:koharin55/research_log2.git'
set :branch, 'main'

# デプロイ先のディレクトリ
set :deploy_to, '/var/www/research_log2'

# バージョンが変わっても共通で参照するファイルを指定（サーバー上に手動で配置）
set :linked_files, fetch(:linked_files, []).push('.env')

# バージョンが変わっても共通で参照するディレクトリを指定
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'storage')

set :rbenv_type, :user
set :rbenv_ruby, '3.2.0'

# どの公開鍵を利用してデプロイするか
set :ssh_options, auth_methods: ['publickey'],
                                  keys: ['~/.ssh/my-key-pair.pem'] 

# プロセス番号を記載したファイルの場所
set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }

# Unicornの設定ファイルの場所
set :unicorn_config_path, -> { "#{current_path}/config/unicorn.rb" }

# RAILS_ENVをproductionに指定（デフォルトのdeploymentのままだとproduction.rbが読まれない）
set :unicorn_rack_env, 'production'
set :keep_releases, 5

# デプロイ処理が終わった後、Unicornを再起動するための記述
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end