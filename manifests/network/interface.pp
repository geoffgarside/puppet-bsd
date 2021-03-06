# Define: bsd::network::interface
#
# Manage a network interface
#
define bsd::network::interface (
  $ensure        = 'present',
  $description   = undef,
  $values        = undef,
  $options       = undef,
) {

  $if_name        = $name
  $interface_file = "/etc/hostname.${if_name}"
  $if_type        = split($if_name, '\d+')

  $config = {
    name        => $name,
    type        => $if_type[0],
    description => $description,
    values      => $values,
    options     => $options,
  }

  debug("config: ${config}")

  case $::kernel {
    'OpenBSD': {
      $content = get_openbsd_hostname_if_content($config)

      file { "/etc/hostname.${if_name}":
        content => inline_template('<%= content + "\n" %>'),
        notify  => Exec["netstart_${if_name}"],
      }

      exec { "netstart_${if_name}":
        command     => "/bin/sh /etc/netstart ${if_name}",
        refreshonly => true,
      }
    }
    'FreeBSD': {
      $rec_hash = get_freebsd_rc_conf_shellconfig($config)

      Shell_config {
        file => '/etc/rc.conf'
      }

      create_resources('shell_config', $rec_hash)

      exec { "netifstart_${if_name}":
        command     => "/usr/sbin/service netif start ${if_name}",
        refreshonly => true,
      }
    }
    default: {
      fail('unhandled BSD, please help add support')
    }
  }
}
