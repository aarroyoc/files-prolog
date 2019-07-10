FROM arm32v7/swipl:8.1.6

WORKDIR /opt/files-prolog

COPY app.pl ./

RUN useradd prolog

#CMD ["su", "-", "prolog", "-c", "swipl /opt/files-prolog/app.pl --port=2345 --no-fork"]
USER prolog
CMD ["swipl","app.pl"]
