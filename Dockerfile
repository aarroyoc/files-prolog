FROM swipl:8.1.6

WORKDIR /opt/files-prolog

COPY app.pl ./

RUN adduser prolog

CMD ["su", "-", "prolog", "-c", "swipl /opt/files-prolog/app.pl --port=2345 --no-fork"]
