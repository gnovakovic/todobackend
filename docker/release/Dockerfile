FROM gnovakovic/todobackend-base:latest
MAINTAINER Goran


COPY target /wheelhouse

# Activate virtual environment and install app
RUN . /appenv/bin/activate && \
    pip install --no-index -f /wheelhouse todobackend && \
    rm -rf /wheelhouse	
 