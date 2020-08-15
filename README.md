# Tennis Court Agent

## Requirements

- Ruby: => .ruby-version
- Redis: 6.0.6+
- MySQL: 8.0.21+

## Setup

```sh
# MySQL
brew list | grep mysql
brew install mysql
brew services start mysql

# Redis
brew list | grep redis
brew install redis
brew services start redis

# 確認
brew services list
mysql --version
redis-server -v

# Setup rails
bin/setup
```

## 実行

```zsh
# Sidekiq
% bundle exec sidekiq -q gush

% bin/rails c
# rails console
[1] pry(main)> flow = Yokohama::AvailableDatesWorkflow.create(["公園の名前"])
[2] pry(main)> flow.start!
[3] pry(main)> flow.reload
[4] pry(main)> flow.status
=> :finished

# 失敗させる
[5] pry(main)> flow.jobs.first.fail!
[6] pry(main)> flow.reload
[7] pry(main)> flow.status
=> :failed
```

## 確認

```zsh
% redis-cli
127.0.0.1:6379> keys *
1) "gush.workflows.b108edfe-a601-49b9-87d6-5168e683f06a"
2) "gush.jobs.601998cb-5540-4849-8d99-3709f65082ab.Yokohama::AvailableDatesJob"
127.0.0.1:6379> get "gush.workflows.b108edfe-a601-49b9-87d6-5168e683f06a"
% bundle exec gush list
+--------------------------------------+---------------------------+----------------------------------+-------------------------------------------------------------------------+
|                  id                  |        started at         |               name               |                                 status                                  |
+--------------------------------------+---------------------------+----------------------------------+-------------------------------------------------------------------------+
| b108edfe-a601-49b9-87d6-5168e683f06a | 2020-08-15 11:20:41 +0900 | Yokohama::AvailableDatesWorkflow |                                 failed                                  |
|                                      |                           |                                  | Yokohama::AvailableDatesJob|8d2698bd-3e40-4454-bc6a-da618da428ec failed |
| 601998cb-5540-4849-8d99-3709f65082ab | 2020-08-15 11:13:31 +0900 | Yokohama::AvailableDatesWorkflow |                                  done                                   |
+--------------------------------------+---------------------------+----------------------------------+-------------------------------------------------------------------------+
```

## 参考

- [macOS Sierra の Rails 開発環境をアップデートする \- Qiita](https://qiita.com/mokuo/items/156c35320ec97237c511)
- [Rails プロジェクトの初期構築 \- Qiita](https://qiita.com/mokuo/items/95bda113cc5095a9f769)
