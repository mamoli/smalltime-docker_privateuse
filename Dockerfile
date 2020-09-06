FROM phusion/baseimage:latest-amd64
MAINTAINER Philipp Maechler <philipp.maechler@mamo.li>

ARG DEBIAN_FRONTEND=noninteractive
ARG SMALLTIME_URL=https://github.com/itmastergmbh/SmallTime/archive/master.zip

RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y \
        apache2 \
        php7.3 php7.3-xml  php-apcu \
        curl \
        unzip\
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --set php /usr/bin/php7.3

# Get iTop
RUN rm -rf /var/www/html/* \
    && mkdir -p /tmp/smalltime \
    && curl -SL -o /tmp/smalltime/smalltime.zip $SMALLTIME_URL \
    && unzip /tmp/smalltime/smalltime.zip -d /tmp/smalltime/ \
    && mv /tmp/smalltime/SmallTime-master/* /var/www/html \
    && rm -rf /tmp/smalltime

# Copy services, configs and scripts
COPY service /etc/service/
COPY artifacts/apache2.fqdn.conf /etc/apache2/conf-available/fqdn.conf
COPY run.sh /run.sh
RUN chmod +x -R /etc/service \
    && chmod +x /*.sh \
    && a2enconf fqdn

RUN chown -R www-data:www-data /var/www/html

VOLUME /var/www/html/include/Settings /var/www/html/Data 

EXPOSE 80

HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["/run.sh"]
