# Vagrant project for Magento 2 developers (optimized for Mac, Windows and \*nix hosts)

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Semver](http://img.shields.io/SemVer/2.0.0.png?color=blue)](http://semver.org/spec/v2.0.0.html)
[![Latest GitHub release](https://img.shields.io/github/release/paliarush/magento2-vagrant-for-developers.svg)](https://github.com/paliarush/magento2-vagrant-for-developers/releases/latest)

 * [What You get](#what-you-get)
 * [How to install](#how-to-install)
   * [Requirements](#requirements)
   * [Installation steps](#installation-steps)
   * [Default credentials and settings](#default-credentials-and-settings)
   * [GitHub limitations](#github-limitations)
 * [Day-to-day development scenarios](#day-to-day-development-scenarios)
   * [Reinstall Magento](#reinstall-magento)
   * [Clear magento cache](#clear-magento-cache)
   * [Debugging with XDebug](#debugging-with-xdebug)

## What You get

It is expected that Magento 2 project source code will be located on the host. 
This is necessary to allow IDE index project files quickly. All other infrastructure is deployed on the guest machine.

Current Vagrant configuration aims to solve performance issues of Magento installed on Virtual Box **for development**.
Custom solution is implemented for Windows hosts. See [explanation of the proposed solution](docs/performance-issue-on-windows-hosts.md).

[Project initialization script](init_project.sh) configures complete development environment:

 1. Adds some missing software on the host
 1. Configures all software necessary for Magento 2 using [custom Ubuntu vagrant box](https://atlas.hashicorp.com/paliarush/boxes/magento2.ubuntu) (Apache 2.4, PHP 7.0 (or 5.5.9), MySQL 5.6, Git, Composer, XDebug, Rabbit MQ)
 1. Installs Magento 2
 1. Configures PHP Storm project (partially at the moment)

## How to install

If you never used Vagrant before, read [Vagrant Docs](https://docs.vagrantup.com/v2)

### Requirements

Software listed below should be available in [PATH](https://en.wikipedia.org/wiki/PATH_\(variable\)) (except for PHP Storm).

- [Vagrant 1.8+](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [PHP](http://php.net/manual/en/install.php) (any version) to allow Magento dependency management with [Composer](https://getcomposer.org/doc/00-intro.md)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). Make sure you have SSH keys generated and associated with your github account, see [manual](https://help.github.com/articles/generating-ssh-keys/).<br />
:information_source: It is possible to use another way of getting codebase instead of cloning, it does not matter for successful installation. Just put Magento 2 codebase inside of `vagrant-magento/magento2ce`.<br />
:information_source: On Windows hosts make sure to set the following options to avoid issues with incorrect line separators:

    ```
    git config --global core.autocrlf false
    git config --global core.eol LF
    git config --global diff.renamelimit 5000
    ```
- [PHP Storm](https://www.jetbrains.com/phpstorm) is optional but recommended.

### Installation steps
 
 1. Open terminal and change directory to the one which you want to contain Magento project. On Windows use Git Bash, which is available after Git installation

 1. Download project with Vagrant configuration:
 
   ```
   git clone git@github.com:paliarush/magento2-vagrant-for-developers.git vagrant-magento
   ```
 
 1. Copy [etc/composer/auth.json.dist](etc/composer/auth.json.dist) to `etc/composer/auth.json` and specify your [GitHub OAuth token](https://github.com/settings/tokens) there. See [API rate limit and OAuth tokens](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens) for more information
 
 1. Optionally, copy [etc/config.yaml.dist](etc/config.yaml.dist) as `etc/config.yaml` and make necessary customizations
 
 1. Initialize project, configure environment, install Magento, configure PHPStorm project:
 
   ```
   cd vagrant-magento
   bash init_project.sh
   ```
   
   :information_source: On OSX and \*nix hosts NFS will be used by default to sync your project files with guest. On some hosts Vagrant cannot configure NFS properly, in this case it is possible to deploy project without NFS by setting `use_nfs` option in [config.yaml](etc/config.yaml.dist) to `0`
   :information_source: On Windows hosts you might face `Composer Install Error: ZipArchive::extractTo(): Full extraction path exceed MAXPATHLEN (260)` exception during `composer install`. This can be fixed in 2 ways: decrease path length to the project directory or set `composer_prefer_source` option in [config.yaml](etc/config.yaml.dist) to `1`

 1. Use `vagrant-magento` directory as project root in PHP Storm (not `vagrant-magento/magento2ce`). This is important, because in this case PHP Storm will be configured automatically by [init_project.sh](init_project.sh). If NFS files sync is disabled in [config](etc/config.yaml.dist) and on Windows hosts [verify deployment configuration in PHP Storm](docs/phpstorm-configuration-windows-hosts.md)

### Default credentials and settings
Some of default settings are available for override. These settings can be found in the file [etc/config.yaml.dist](etc/config.yaml.dist).
To override settings just create a copy of the file under the name 'config.yaml' and put there your custom settings.
When using [init_project.sh](init_project.sh), if not specified manually, random IP address is generated and is used as suffix for host name to prevent collisions, in case when 2 or more instances are running at the same time.
Upon a successful installation, you'll see the location and URL of the newly-installed Magento 2 application in console.

**Web access**:
- Access storefront at `http://magento2.vagrant<random_suffix>`
- Access admin panel at `http://magento2.vagrant<random_suffix>/admin/`
- Magento admin user/password: `admin/123123q`
- Rabbit MQ control panel: `http://magento2.vagrant<random_suffix>:15672`, credentials `guest`/`guest`

**Codebase and DB access**:
- Path to your Magento installation on the VM:
  - Can be retrieved from environment variable: `echo ${MAGENTO_ROOT}`
  - On Windows hosts: `/var/www/magento2ce`
  - On Mac, \*nix hosts: the same as on host
- MySQL DB host: `localhost` (not accessible remotely)
- MySQL DB name: `magento`, `magento_integration_tests`
- MySQL DB user/password: just use `mysql` with no user and password (`root/password` will be used by default)

### GitHub limitations

Be aware that you may encounter GitHub limits on the number of downloads (used by Composer to download Magento dependencies).

These limits may significantly slow down the installation since all of the libraries will be cloned from GitHub repositories instead of downloaded as ZIP archives. In the worst case, these limitations may even terminate the installation.

If you have a GitHub account, you can bypass these limitations by using an OAuth token in the Composer configuration. See [API rate limit and OAuth tokens](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens) for more information.

For the Vagrant configuration you may specify your token in `etc/github.oauth.token` file after cloning the repository. The file is a basic text file and is ignored by Git, so you'll need to create it yourself. Simply write your OAuth token in this file making sure to avoid any empty spaces, and it will be read during deployment.

## Day-to-day development scenarios
    
### Reinstall Magento
To save some time and get clear Magento installation, you can skip installation of software like web server or php.
The following command will clear Magento DB, Magento caches and reinstall Magento instance.

Go to 'vagrant-magento' created earlier and run in command line:

```
vagrant provision --provision-with install_magento
```

### Clear magento cache

Go to 'vagrant-magento' created earlier and run in command line:

```
vagrant ssh -c 'magento_clear_cache'
```

### Debugging with XDebug

XDebug is already configured to connect to the host machine automatically. So just:
 
 1. Set XDEBUG_SESSION=1 cookie (e.g. using 'easy Xdebug' extension for Firefox). See [XDebug documentation](http://xdebug.org/docs/remote) for more details
 1. Start listening for PHP Debug connections in PhpStorm. See how to [integrate XDebug with PhpStorm](https://www.jetbrains.com/phpstorm/help/configuring-xdebug.html#integrationWithProduct)
 1. Set beakpoint or set option in PhpStorm menu 'Run -> Break at first line in PHP scripts'
