FROM python:3.7
ENV PYTHONUNBUFFERED 1
EXPOSE 8080
EXPOSE 80
EXPOSE 443

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

COPY ./requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

RUN groupadd -r django && useradd -r -g django django
COPY . /app
RUN chown -R django /app

WORKDIR /app

RUN make install

USER django

RUN make build_sandbox

ENV NEW_RELIC_CONFIG_FILE /app/newrelic.ini
ENV NEW_RELIC_APP_NAME Django Commerce

RUN cp --remove-destination /app/src/oscar/static/oscar/img/image_not_found.jpg /app/sandbox/public/media/

WORKDIR /app/sandbox/
CMD newrelic-admin run-program uwsgi --enable-threads --single-interpreter --ini uwsgi.ini
