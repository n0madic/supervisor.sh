FROM alpine

COPY supervisor.sh /sbin/

ENTRYPOINT [ "supervisor.sh" ]
