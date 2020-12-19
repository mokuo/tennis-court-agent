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
