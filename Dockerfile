FROM ruby:2.7.2-alpine

# HACK: ビルドのみで必要なツールは、ビルド後に削除する
RUN apk add --no-cache \
    # For build nokogiri.
    #   ref: https://nokogiri.org/tutorials/installing_nokogiri.html#ruby-on-alpine-linux-docker
    build-base \
    # For pg gem.
    postgresql \
    postgresql-dev \
    # For tzinfo gem.
    tzdata

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

# ref: https://github.com/mperham/sidekiq/wiki/Advanced-Options#environment
CMD ["bundle", "exec", "sidekiq", "-e", "production"]
