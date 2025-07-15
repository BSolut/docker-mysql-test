FROM mysql:8

COPY test.cnf /etc/mysql/conf.d/test.cnf

COPY my-entrypoint.sh /usr/local/bin/my-entrypoint.sh
RUN chmod +x /usr/local/bin/my-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/my-entrypoint.sh"]
CMD ["mysqld"]