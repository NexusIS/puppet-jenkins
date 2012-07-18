#
# Class: jenkins
#
# Installs the Jenkins CI server, http://jenkins-ci.org/.
#
# Usage:
#
#   # Install and run jenkins.
#   include jenkins
#
class jenkins(
  $jenkins_user = 'jenkins',
  $jenkins_port = '8181',
  $jenkins_prefix = undef,
  $version = 'present') {

    if $jenkins_prefix != undef {
      $prefix_real = $jenkins_prefix
    }

    $key_url = "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
    $repo_url = "http://pkg.jenkins-ci.org/redhat"
    $yum_repo = "/etc/yum.repos.d/jenkins.repo"

    yumrepo { "jenkins":
        baseurl     => $repo_url,
        descr       => "Jenkins Yum Repo",
        enabled     => 1,
        gpgkey      => $key_url,
        gpgcheck    => 1
    }

    package { "jenkins":
        ensure      => $version,
        provider    => "yum",
        require     => Yumrepo["jenkins"]
    }

    if ! defined(Package['fontconfig'])           { package { 'fontconfig':             ensure => installed } }
    if ! defined(Package['fontconfig-devel'])     { package { 'fontconfig-devel':             ensure => installed } }

    file { "/etc/sysconfig/jenkins":
        owner       => root,
        group       => root,
        mode        => 755,
        content     => template("jenkins/jenkins.erb"),
        require    => Package["jenkins"],
        notify      => Service["jenkins"]
    } 

    service { "jenkins":
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => [Package["jenkins"],File["/etc/sysconfig/jenkins"]]
    }

}
