FROM python:3.9-alpine

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . /microblog

WORKDIR /microblog

RUN chmod a+x boot.sh

ENV FLASK_APP microblog.py

ENTRYPOINT ["./boot.sh"]