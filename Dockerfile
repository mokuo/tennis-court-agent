FROM ruby:2.7.2-alpine

# HACK: ビルドのみで必要なツールは、ビルド後に削除する
RUN apk add --no-cache \
    # For build nokogiri.
    #   ref: https://nokogiri.org/tutorials/installing_nokogiri.html#ruby-on-alpine-linux-docker
    build-base \
    # Chrome
    chromium \
    chromium-chromedriver \
    # ref: https://qiita.com/at-946/items/a7dbac4a46802d7b5376
    less \
    # For wabpacker
    nodejs \
    # For pg gem.
    postgresql \
    postgresql-dev \
    # For tzinfo gem.
    tzdata \
    yarn

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY package.json yarn.lock ./

RUN yarn install

RUN RAILS_ENV=production bundle exec rails assets:precompile && rm -rf node_modules/

COPY . .

# ref: https://github.com/mperham/sidekiq/wiki/Advanced-Options#environment
CMD ["bundle", "exec", "sidekiq", "-e", "production"]
