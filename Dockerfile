FROM amazonlinux:2

WORKDIR /home/build

RUN set -e

RUN echo "Prepping ClamAV"

RUN rm -rf bin
RUN rm -rf lib

RUN yum update -y
RUN amazon-linux-extras install epel -y
RUN yum install -y cpio yum-utils tar.x86_64 gzip zip

RUN yumdownloader -x \*i686 --archlist=x86_64 systemd-libs
RUN rpm2cpio systemd-libs*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 lz4
RUN rpm2cpio lz4*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 clamav
RUN rpm2cpio clamav-0*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 clamav-lib
RUN rpm2cpio clamav-lib*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 clamd
RUN rpm2cpio clamd-0*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 clamav-update
RUN rpm2cpio clamav-update*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 json-c
RUN rpm2cpio json-c*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 pcre2
RUN rpm2cpio pcre*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 libtool-ltdl
RUN rpm2cpio libtool-ltdl*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 libxml2
RUN rpm2cpio libxml2*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 bzip2-libs
RUN rpm2cpio bzip2-libs*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 xz-libs
RUN rpm2cpio xz-libs*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 libprelude
RUN rpm2cpio libprelude*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 gnutls
RUN rpm2cpio gnutls*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 nettle
RUN rpm2cpio nettle*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 elfutils-libelf
RUN rpm2cpio elfutils-libelf*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 elfutils-libs
RUN rpm2cpio elfutils-libs*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 libgcrypt
RUN rpm2cpio libgcrypt*.rpm | cpio -vimd

RUN yumdownloader -x \*i686 --archlist=x86_64 libgpg-error
RUN rpm2cpio libgpg-error*.rpm | cpio -vimd

RUN mkdir -p bin
RUN mkdir -p lib
RUN mkdir -p var/lib/clamav
RUN chmod -R 777 var/lib/clamav

RUN cp usr/bin/clamscan usr/bin/freshclam usr/sbin/clamd usr/bin/clamdscan bin/.
RUN cp -r usr/lib64/* lib/.
RUN cp -r lib64/* lib/.

COPY ./conf/freshclam.conf bin/
COPY ./conf/clamd.conf bin/
COPY ./conf/scan.conf bin/

RUN yum install shadow-utils.x86_64 -y

RUN groupadd clamav
RUN useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav
RUN useradd -g clamav -s /bin/false -c "Clam Antivirus" clamupdate

RUN mkdir -p opt/var/lib/clamav
RUN chmod -R 777 opt/var/lib/clamav

RUN LD_LIBRARY_PATH=./lib ./bin/freshclam --config-file=bin/freshclam.conf

RUN zip -r9 clamav_lambda_layer.zip bin
RUN zip -r9 clamav_lambda_layer.zip lib
RUN zip -r9 clamav_lambda_layer.zip var
RUN zip -r9 clamav_lambda_layer.zip etc