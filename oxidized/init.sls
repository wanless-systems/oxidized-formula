{% from "oxidized/map.jinja" import oxidized with context %}

oxidized_pkgs_install:
  pkg.installed:
    - names: {{ oxidized.lookup.pkgs }}

{% for gem in oxidized.lookup.gems %}
oxidized_gems_install_{{gem}}:
  cmd.run:
    #- name: /etc/oxidized/.rvm/rubies/default/bin/gem install {{gem}}
    - name: 'su -l {{ oxidized.general.user }} /bin/bash -c "gem install {{gem}}"'
    - require:
      - cmd: rvm
      - cmd: rvm-bashrc
# TODO: Why doesn't this work:      - rvm-ruby: ruby-2.6
#    - unless:

  # gem.installed:
  #   - names: {{ oxidized.lookup.gems }}
  #
{%endfor%}


# Configure user/group
oxidized_user:
  user.present:
    - name: {{ oxidized.general.user }}
    - gid: {{ oxidized.general.group }}
    - home: {{ oxidized.general.home }}
    # The oxidized user MUST have a shell in order to use a local install of
    # Ruby (which gets installed in $HOME and modified the .bashrc for the user)
    - shell: /bin/bash
    - system: True
    - groups:
        - {{ oxidized.general.group }}
        - rvm
    - require:
      - group: oxidized_user
  group.present:
    - name: {{ oxidized.general.group }}
    - system: True

# Log file
oxidized_log:
  file.managed:
    - name: {{ oxidized.config.log }}
    - user: {{ oxidized.general.user }}
    - group: {{ oxidized.general.group }}
    - mode: 0644
    - require:
      - user: {{ oxidized.general.user }}

# Data folder
oxidized_directories:
  file.directory:
    - names:
      - /etc/oxidized
      - /var/lib/oxidized
    - user: {{ oxidized.general.user }}
    - group: {{ oxidized.general.group }}
    - mode: 0755
    - require:
      - user: {{ oxidized.general.user }}
