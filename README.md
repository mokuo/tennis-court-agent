# Tennis Court Agent

## Requirements

- Docker Desktop

## Setup

```sh
docker-compose build
docker-compose up
docker-compose exec spring bin/rails db:setup
```

## RSpec

```sh
docker-compose exec spring bin/rspec spec/xxx/xxx.rb
```

## Deploy

```sh
git fetch
git checkout master
git pull
git push heroku master
```

## Terraform

ref: https://github.com/tfutils/tfenv

```
cd infra
terraform init
terraform plan
terraform apply
```

## Start Check Availbility

```sh
# Wake up heroku app before.
heroku run bundle exec rails start_availability_check
```

## 動作確認

ReservationJob の `rescue_from(StandardError)`

```ruby
require Rails.root.join("domain/models/yokohama/reservation_frame")
start_date_time = Time.zone.local(2020, 8, 22, 15).to_s
end_date_time = Time.zone.local(2020, 8, 22, 15).to_s

hash = {
  park_name: "三ツ沢公園",
  tennis_court_name: "公園１\nテニスコート１",
  start_date_time: start_date_time,
  end_date_time: end_date_time,
  now: false,
  state: "will_reserve",
  id: 1
}
ReservationJob.perform_now(hash)
```
