FROM arm32v7/swipl:8.1.6

WORKDIR /opt/files-prolog

COPY app.pl ./
COPY config.pl ./

RUN useradd prolog

USER prolog
CMD ["swipl","app.pl"]
