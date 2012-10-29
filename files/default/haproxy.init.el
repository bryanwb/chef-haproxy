#!/bin/sh
#
# chkconfig: - 85 15
# description: HA-Proxy is a TCP/HTTP reverse proxy which is particularly suited \
#              for high availability environments.
# processname: haproxy
# config: /etc/haproxy/haproxy.cfg
# pidfile: /var/run/haproxy.pid

# Source function library.
if [ -f /etc/init.d/functions ]; then
  . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ] ; then
  . /etc/rc.d/init.d/functions
else
  exit 0
fi


# Source networking configuration.
. /etc/sysconfig/network

# source runtime haproxy configuration
. /etc/default/haproxy

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

[ -f $HAPROXY_CONFIG ] || exit 1

RETVAL=0

start() {
  $HAPROXY_BIN -c -q -f $HAPROXY_CONFIG
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file."
    return 1
  fi

  echo -n "Starting HAproxy: "
  daemon $HAPROXY_BIN -D -f  $HAPROXY_CONFIG -p /var/run/haproxy.pid
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/haproxy
  return $RETVAL
}

stop() {
  echo -n "Shutting down HAproxy: "
  killproc haproxy -USR1
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/haproxy
  [ $RETVAL -eq 0 ] && rm -f /var/run/haproxy.pid
  return $RETVAL
}

restart() {
  $HAPROXY_BIN -c -q -f $HAPROXY_CONFIG
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with 'haproxy check'."
    return 1
  fi
  stop
  sleep 2
  start
}

check() {
  $HAPROXY_BIN -c -q -V -f $HAPROXY_CONFIG
}

rhstatus() {
  status haproxy
}

condrestart() {
  [ -e /var/lock/subsys/haproxy ] && restart || :
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  reload)
    restart
    ;;
  condrestart)
    condrestart
    ;;
  status)
    rhstatus
    ;;
  check)
    check
    ;;
  *)
    echo $"Usage: haproxy {start|stop|restart|reload|condrestart|status|check}"
    RETVAL=1
esac
 
exit $RETVAL
