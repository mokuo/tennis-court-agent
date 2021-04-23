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

rf = Yokohama::ReservationFrame.new(
  park_name: "三ツ沢公園",
  tennis_court_name: "三ツ沢公園\nテニスコート１",
  start_date_time: Time.zone.local(2021, 5, 27, 15),
  end_date_time: Time.zone.local(2021, 5, 27, 17),
  now: true,
  state: "will_reserve",
  id: 1
)

ReservationJob.perform_now(rf.to_hash)
```
