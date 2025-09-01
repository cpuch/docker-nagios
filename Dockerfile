#################################
##                             ##
##     DEFAULT BUILD IMAGE     ##
##                             ##
#################################

FROM debian:bookworm-slim AS builder

# Build args
ARG NAGIOS_HOME
ARG NAGIOS_USER
ARG NAGIOS_GROUP

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Create nagios user and group
RUN groupadd "${NAGIOS_GROUP}" && \
    useradd -d "${NAGIOS_HOME}" -M -g "${NAGIOS_GROUP}" "${NAGIOS_USER}"

# Upgrade operating system
RUN sed -i 's,Components: main,Components: main non-free non-free-firmware,g' /etc/apt/sources.list.d/debian.sources && \
    apt update && apt upgrade -y && \
    apt clean && apt autoclean && \
    rm -rf /var/lib/apt/lists/* /var/tmp* /tmp/*

################################
##                            ##
##     NAGIOS BUILD STAGE     ##
##                            ##
################################

# Base image
FROM builder AS nagios-builder

# Build args
ARG NAGIOS_BRANCH

# Install packages dependencies
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
        apache2 \
        apache2-utils \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        gcc \
        libapache2-mod-php \
        libc6 \
        libgd-dev \
        libssl-dev \
        make \
        php \
        php-gd \
        php-mysql \
        unzip \
        wget && \
    apt clean && apt autoclean

# Change working directory
WORKDIR /tmp

# Install Nagios Core
RUN curl -sSL "https://github.com/NagiosEnterprises/nagioscore/releases/download/${NAGIOS_BRANCH}/${NAGIOS_BRANCH}.tar.gz" -o "${NAGIOS_BRANCH}.tar.gz" && \
    tar xzf "${NAGIOS_BRANCH}.tar.gz" && \
    cd "${NAGIOS_BRANCH}" && \
    ./configure \
        --prefix="${NAGIOS_HOME}" \
        --exec-prefix="${NAGIOS_HOME}" \
        --enable-event-broker \
        --with-command-user="${NAGIOS_USER}" \
        --with-command-group="${NAGIOS_GROUP}" \
        --with-nagios-user="${NAGIOS_USER}" \
        --with-nagios-group="${NAGIOS_GROUP}" && \
    make all && \
    make install && \
    make install-config && \
    make install-commandmode && \
    make install-webconf && \
    make clean

# Create htpasswd file
RUN --mount=type=secret,id=NAGIOSADMIN_PASSWORD \
    htpasswd -c -b -s "${NAGIOS_HOME}/etc/htpasswd.users" nagiosadmin "$(cat /run/secrets/NAGIOSADMIN_PASSWORD)"

########################################
##                                    ##
##     NAGIOS PLUGINS BUILD STAGE     ##
##                                    ##
########################################

# Base image
FROM builder AS nagios-plugins-builder

# Build args
ARG NAGIOS_PLUGINS_BRANCH

# Install packages dependencies
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
        autoconf \
        automake \
        bc \
        bind9-utils \
        build-essential \
        curl \
        dc \
        dnsutils \
        fping \
        gawk \
        gcc \
        gettext \
        libc6 \
        libcache-memcached-perl \
        libdbd-mysql-perl \
        libdbd-pg-perl \
        libdbi-dev \
        libdbi-perl \
        libdigest-hmac-perl \
        libfreeradius-dev \
        libjson-perl \
        libldap2-dev \
        libmonitoring-plugin-perl \
        libmariadb-dev \
        libmariadb-dev-compat \
        libmcrypt-dev \
        libnagios-object-perl \
        libnet-snmp-perl \
        libnet-tftp-perl \
        libpq-dev \
        libredis-perl \
        librrds-perl \
        libsnmp-dev \
        libssl-dev \
        libswitch-perl \
        lm-sensors \
        make \
        openssh-client \
        smbclient \
        snmp \
        wget && \
    apt clean && apt autoclean

# Change working directory
WORKDIR /tmp
    
# Install Nagios Plugins
RUN curl -sSL "https://github.com/nagios-plugins/nagios-plugins/releases/download/release-${NAGIOS_PLUGINS_BRANCH}/nagios-plugins-${NAGIOS_PLUGINS_BRANCH}.tar.gz" \
        -o "${NAGIOS_PLUGINS_BRANCH}.tar.gz" && \
    tar zxf "${NAGIOS_PLUGINS_BRANCH}.tar.gz" && \
    cd "nagios-plugins-${NAGIOS_PLUGINS_BRANCH}" && \
    ./configure \
        --prefix="${NAGIOS_HOME}" \
        --with-ipv6 \
        --with-ping-command="/usr/bin/ping -n -U -W %d -c %d %s"  \
        --with-ping6-command="/usr/bin/ping -6 -n -U -W %d -c %d %s" && \
    make && \
    make install && \
    make clean && \
    chown root:root "${NAGIOS_HOME}/libexec/check_icmp" && \
    chmod u+s "${NAGIOS_HOME}/libexec/check_icmp"

##############################
##                          ##
##     NRPE BUILD STAGE     ##
##                          ##
##############################

# Base image
FROM builder AS nrpe-builder

# Build args
ARG NRPE_BRANCH

# Install packages dependencies
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libssl-dev && \
    apt clean && apt autoclean

# Install NRPE
RUN curl -sSL "https://github.com/NagiosEnterprises/nrpe/releases/download/${NRPE_BRANCH}/${NRPE_BRANCH}.tar.gz" \
        -o "${NRPE_BRANCH}.tar.gz" && \
    tar zxf "${NRPE_BRANCH}.tar.gz" && \
    cd "${NRPE_BRANCH}" && \
    ./configure \
        --prefix="${NAGIOS_HOME}" \
        --with-nrpe-user="${NAGIOS_USER}" \
        --with-nrpe-group="${NAGIOS_GROUP}" && \
    make all && \
    make install-daemon && \
    make install-plugin && \
    make install-config

##############################
##                          ##
##     NSCA BUILD STAGE     ##
##                          ##
##############################

# Base image
FROM builder AS nsca-builder

# Build args
ARG NSCA_BRANCH

# Install packages dependencies
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libssl-dev && \
    apt clean && apt autoclean

# Change working directory
WORKDIR /tmp

# Install NSCA
RUN curl -sSL "https://github.com/NagiosEnterprises/nsca/releases/download/${NSCA_BRANCH}/${NSCA_BRANCH}.tar.gz" -o "${NSCA_BRANCH}.tar.gz" && \
    tar zxf "${NSCA_BRANCH}.tar.gz" && \
    cd "${NSCA_BRANCH}" && \
    ./configure \
        --prefix="${NAGIOS_HOME}" \
        --with-nsca-user="${NAGIOS_USER}" \
        --with-nsca-grp="${NAGIOS_GROUP}" && \
    make all && \
    mkdir -p "${NAGIOS_HOME}/bin" "${NAGIOS_HOME}/etc" "${NAGIOS_HOME}/libexec" && \
    cp src/nsca "${NAGIOS_HOME}/bin/nsca" && \
    cp src/send_nsca "${NAGIOS_HOME}/libexec/send_nsca" && \
    cp sample-config/nsca.cfg "${NAGIOS_HOME}/etc/nsca.cfg" && \
    cp sample-config/send_nsca.cfg "${NAGIOS_HOME}/etc/send_nsca.cfg" && \
    sed -i 's,^#server_address.*,server_address=0.0.0.0,' "${NAGIOS_HOME}/etc/nsca.cfg"

# Set password for NSCA
RUN --mount=type=secret,id=NSCA_PASSWORD \
    sed -i "s,^#password=,password=$(cat /run/secrets/NSCA_PASSWORD)," "${NAGIOS_HOME}/etc/nsca.cfg" && \
    sed -i "s,^#password=,password=$(cat /run/secrets/NSCA_PASSWORD)," "${NAGIOS_HOME}/etc/send_nsca.cfg"

###############################
##                           ##
##     FINAL BUILD STAGE     ##
##                           ##
###############################

# Base image
FROM builder

# Environment variables
ENV NAGIOS_HOME="${NAGIOS_HOME}"
ENV NAGIOS_USER="${NAGIOS_USER}"
ENV NAGIOS_GROUP="${NAGIOS_GROUP}"
ENV APACHE_RUN_USER="${NAGIOS_USER}"
ENV APACHE_RUN_GROUP="${NAGIOS_GROUP}"
ENV TZ=UTC

# Install packages dependencies, enable apache2 modules, change document root, redirect logs to stdout and stderr
RUN apt update && \
    apt install -y --no-install-recommends \
        apache2 \
        apache2-utils \
        curl \
        dnsutils \
        libapache2-mod-php \
        iputils-ping \
        net-tools \
        php \
        php-gd \
        php-mysql \
        openssl \
        snmp-mibs-downloader \
        supervisor \
        unzip && \
    a2enmod \
        cgi \
        rewrite && \
    chmod u+s /usr/bin/ping && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log && \
    sed -i 's,APACHE_RUN_USER=www-data,APACHE_RUN_USER=${NAGIOS_USER},' /etc/apache2/envvars && \
    sed -i 's,APACHE_RUN_GROUP=www-data,APACHE_RUN_GROUP=${NAGIOS_USER},' /etc/apache2/envvars && \
    sed -i 's,DocumentRoot \/var\/www\/html,DocumentRoot ${NAGIOS_HOME}/share,' /etc/apache2/sites-enabled/000-default.conf && \
    echo "PassEnv TZ" > /etc/apache2/conf-enabled/timezone.conf

# Change working directory
WORKDIR "${NAGIOS_HOME}"

# Copy Nagios
COPY --from=nagios-builder "${NAGIOS_HOME}" .
COPY --from=nagios-builder /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/nagios.conf
COPY --from=nagios-plugins-builder "${NAGIOS_HOME}" .
COPY --from=nrpe-builder "${NAGIOS_HOME}" .
COPY --from=nsca-builder "${NAGIOS_HOME}" .

# Backup config files
RUN mkdir -p /backup/etc /backup/var && \
    cp -Rp "${NAGIOS_HOME}/etc" /backup && \
    cp -Rp "${NAGIOS_HOME}/var" /backup 

# Copy supervisor config file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set permissions and ownership, clean up
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    chown -R "${NAGIOS_USER}:${NAGIOS_GROUP}" .

# Expose HTTP port and NSCA port
EXPOSE 80/tcp 5667/tcp

# Healthcheck
# curl returns error 22 when the HTTP code is 401
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sSLf http://localhost/ || [ $? -eq 22 ] || exit 1

# Copy entrypoint
COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Runtime command
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]