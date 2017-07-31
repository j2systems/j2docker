FROM centos:6
RUN yum -y update \
	&& yum -y install telnet-server httpd which tar hostname net-tools \
	&& yum -y clean all \ 
	&& /usr/sbin/adduser -r cacheusr \
	&& echo cacheusr:$password | /usr/sbin/chpasswd
