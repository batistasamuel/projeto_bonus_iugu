#-------------------------------------------------------------#
#--------------------------Common-- --------------------------#
#-------------------------------------------------------------#
FROM ruby:3.0.1-alpine as common

# Global Arguments
ARG BUNDLER_VERSION=2.2.15
ARG APP_PATH=/projetobonus
ARG APP_USER=rails
ARG APP_GROUP=rails
ARG APP_USER_UID=1000
ARG APP_GROUP_GID=1000
ARG BUILD_PACKAGES="postgresql-dev zlib-dev yaml-dev alpine-sdk"
ARG DEV_PACKAGES="bash wget curl nodejs yarn git nano graphviz"
ARG RUNTIME_PACKAGES="tzdata postgresql-client zlib yaml"

# Common environment
ENV BUNDLER_VERSION=${BUNDLER_VERSION} \
  APP_USER=${APP_USER} \
  APP_GROUP=${APP_GROUP} \
  APP_PATH=${APP_PATH} \
  BUILD_PACKAGES=${BUILD_PACKAGES} \
  DEV_PACKAGES=${DEV_PACKAGES} \
  RUNTIME_PACKAGES=${RUNTIME_PACKAGES}

# Expose server port
EXPOSE 3000

# Update dependencies and add development dependencies.
# Also create and change APP_PATH folder to match the
# user provided in the args section.
RUN apk update && \
  apk upgrade && \
  apk add --update --no-cache ${RUNTIME_PACKAGES} && \
  gem install bundler --no-document -v=${BUNDLER_VERSION} && \
  addgroup -g ${APP_GROUP_GID} -S ${APP_GROUP} && \
  adduser -S -s /sbin/nologin -u ${APP_USER_UID} -G ${APP_GROUP} ${APP_USER} && \
  mkdir ${APP_PATH}/ && \
  chown ${APP_USER}:${APP_GROUP} ${APP_PATH}/

# Change working directory (post ownership transfer to $APP_USER) to app directory
WORKDIR ${APP_PATH}/

#-------------------------------------------------------------#
#------------------------Development--------------------------#
#-------------------------------------------------------------#
FROM common as development

# Development args
ARG BUNDLE_PATH=/bundle
ARG EDITOR=nano

# Change path for bundler user install
ENV PATH=${APP_PATH}/bin:${BUNDLE_PATH}/bin:${BUNDLE_PATH}:${PATH} \
  BUNDLE_PATH=${BUNDLE_PATH} \
  EDITOR=${EDITOR}

# Chown the bundle volume path
RUN mkdir -p ${BUNDLE_PATH} && chown -R ${APP_USER}:${APP_GROUP} ${BUNDLE_PATH}

# Add development and build packages
RUN apk add --update --no-cache ${BUILD_PACKAGES} ${DEV_PACKAGES}

# Add fonts for ERD generation
RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f

# Change user
USER ${APP_USER}

# Copy the node deps files
COPY --chown=${APP_USER}:${APP_GROUP} package.json yarn.lock ${APP_PATH}/

# Install dependencies (Node)
RUN yarn install

# Copy the ruby deps files
COPY --chown=${APP_USER}:${APP_GROUP} Gemfile* ${APP_PATH}/

# Install dependencies (Ruby)
RUN bundle install --no-binstubs --jobs $(nproc) --retry 3

# Expose BUNDLE_PATH as a volume for caching
VOLUME ${BUNDLE_PATH}

# Run rails console by default
CMD ["bundle", "exec", "rails", "console"]

#-------------------------------------------------------------#
#-------------------------Production--------------------------#
#-------------------------------------------------------------#
FROM common as production

ARG RAILS_ENV=staging
ARG RAILS_MASTER_KEY=

# Set RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV} \
  RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Add development and build packages
RUN apk add --update --no-cache --virtual .build_deps ${BUILD_PACKAGES}

# Copy the current Gemfile and lock files
COPY --chown=${APP_USER}:${APP_GROUP} Gemfile* ${APP_PATH}/

# Install production dependencies only
RUN bundle config set deployment 'true' && \
  bundle install --no-binstubs --jobs $(nproc) --retry 3

# Remove build dependencies
RUN apk del .build_deps

# Copy app files
COPY . .

# Change user to app user
USER ${APP_USER}

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]