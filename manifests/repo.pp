# Add the Varnish repo
class varnish::repo {

  $ver = "${::varnish::version_major}${::varnish::version_minor}"

  case $::osfamily {
    'RedHat': {

      if $ver == '50' {
        if $::operatingsystemmajrelease == '6'  {
          fail('Varnish 5.0 from Packagecloud is not supported on RHEL/CentOS 6')
        } elsif $::operatingsystemmajrelease == '7' {
          # https://github.com/varnishcache/pkg-varnish-cache/issues/42
          fail('Varnish 5.0 on RHEL/CentOS 7 has a known packaging bug in the varnish_reload_vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.')
        }
      }

      if $ver == '60' and $::operatingsystemmajrelease == '7' {
	} else { fail('Varnish 6.0 from Packagecloud is not supported on OS release under 7)')
      }
      if $ver == '61' and $::operatingsystemmajrelease == '7' {
	} else { fail('Varnish 6.1 from Packagecloud is not supported on OS release under 7)')
      }

      $package_require = undef

      # Varnish 4 and above need EPEL for jemalloc
      if $::varnish::version_major != '3' {
        include ::epel
        Yumrepo['varnish-cache','varnish-cache-source'] {
          require => Yumrepo['epel'],
        }
      }

      yumrepo { 'varnish-cache':
        descr           => "varnishcache_varnish${ver}",
        baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${::operatingsystemmajrelease}/\$basearch",
        gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
        metadata_expire => '300',
        repo_gpgcheck   => '1',
        gpgcheck        => '0',
        sslverify       => '1',
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
      }

      yumrepo { 'varnish-cache-source':
        descr           => "varnishcache_varnish${ver}-source",
        baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${::operatingsystemmajrelease}/SRPMS",
        gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
        metadata_expire => '300',
        repo_gpgcheck   => '1',
        gpgcheck        => '0',
        sslverify       => '1',
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
      }
    }


    'Debian': {

      if $ver == '30' and $::lsbdistcodename == 'xenial' {
        fail('Varnish 3 from Packagecloud is not supported on Ubuntu 16.04 (Xenial)')
      }

      if $ver == '50' {
        if $::lsbdistcodename == 'wheezy' {
          fail('Varnish 5.0 from Packagecloud is not supported on Debian 7 (Wheezy)')
        } elsif $::lsbdistcodename == 'trusty' {
          fail('Varnish 5.0 has a known packaging bug in the reload-vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.')
        }
      }

      if $ver == '60' {
        if !($::lsbdistcodename == 'stretch') or !($::lsbdistcodename == 'bionic') or !($::lsbdistcodename == 'xenial') {
      }   else { fail('Varnish 6.0 from Packagecloud is not supported on this Debian version')
        }
      }

      if $ver == '61' {
        if !($::lsbdistcodename == 'stretch') or !($::lsbdistcodename == 'bionic') or !($::lsbdistcodename == 'xenial') {
      }   else { fail('Varnish 6.1 from Packagecloud is not supported on this Debian version')
        }
      }

      ensure_packages('apt-transport-https')

      $os_lower        = downcase($::operatingsystem)
      $package_require = Exec['apt_update']
      $gpg_key_id      = "${::varnish::version_major}.${::varnish::version_minor}" ? {
        '6.1' => '4A066C99B76A0F55A40E3E1E387EF1F5742D76CC',
        '6.0' => '7C5B46721AF00FD57E68E6E8D2605BF74E8B9DBA',
        '5.2' => '91CFD5635A1A5FAC0662BEDD2E9BA3FE86BE909D',
        '5.1' => '54DC32329C37703D8B2819E6414C46826B880524',
        '5.0' => '1487779B0E6C440214F07945632B6ED0FF6A1C76',
        '4.1' => '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E',
        '4.0' => 'B7B16293AE0CC24216E9A83DD4E49AD8DE3FFEA4',
        '3.0' => '246BE381150865E2DC8C6B01FC1318ACEE2C594C',
      }

     ::apt::source { 'varnish-cache':
        comment  => "Apt source for Varnish ${::varnish::version_major}.${::varnish::version_minor}",
        location => "https://packagecloud.io/varnishcache/varnish${ver}/${os_lower}/",
        repos    => 'main',
        require  => Package['apt-transport-https'],
        key      => {
          source => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
          id     => $gpg_key_id,
        },
        include  => {
          'deb' => true,
          'src' => true,
        },
      }
    }

    default: {
      fail("Unsupported repo osfamily: ${::osfamily}")
    }
  }
}
