FROM ruby:3.2.2

# Set environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Install Elasticsearch dependencies
RUN apt-get install -y curl apt-transport-https && \
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update && apt-get install -y elasticsearch

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Install Bundler and copy files
RUN gem install bundler -v 2.5.18
WORKDIR /app
COPY Gemfile* ./
RUN bundle install

# Copy the application code
COPY . .

EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
