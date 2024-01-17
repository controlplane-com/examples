FROM python:3.9-slim

WORKDIR /usr/src/app

COPY health.py ./

RUN apt-get update && apt-get install curl net-tools procps postgresql-client -y

EXPOSE 8091

CMD ["python", "./health.py"]
