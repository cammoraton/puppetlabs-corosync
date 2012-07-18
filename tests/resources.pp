cs_property { 'expected-quorum-votes':
  ensure => present,
  value  => '2',
} ->
cs_property { 'no-quorum-policy':
  ensure => present,
  value  => 'ignore',
} ->
cs_property { 'stonith-enabled':
  ensure => present,
  value  => false,
} ->
cs_property { 'placement-strategy':
  ensure => absent,
  value  => 'default',
} ->
cs_primitive { 'bar':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
  operations      => {
    'monitor'  => {
      'interval' => '20'
    }
  },
} ->
cs_primitive { 'blort':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
  promotable      => true,
  operations      => {
    'monitor' => {
      'interval' => '20'
    },
    'start'   => {
      'interval' => '0',
      'timeout'  => '20'
    }
  },
} ->
cs_primitive { 'foo':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
} ->
cs_colocation { 'foo-with-bar':
  ensure     => present,
  primitives => [ 'foo', 'bar' ],
  score      => 'INFINITY',
} ->
cs_colocation { 'bar-with-blort':
  ensure     => present,
  primitives => [ 'bar', 'ms_blort' ],
  score      => 'INFINITY',
} ->
cs_order { 'foo-before-bar':
  ensure => present,
  first  => 'foo',
  second => 'bar',
  score  => 'INFINITY',
} ->
cs_primitive { 'clone':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
} ->
cs_clone { 'clones':
  ensure           => 'present',
  primitive        => 'clone',
  metadata         => {
    clone-max      => "2",
    clone-node-max => "1",
  },
} ->
cs_primitive { 'lucas':
  ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
} ->
cs_clone { 'attackofthe':
  ensure           => 'present',
  primitive        => 'lucas',
  metadata         => {
    clone-max      => "2",
    clone-node-max => "1",
  },
} ->
cs_group { 'prequel':
    ensure          => 'present',
    primitives      => ['attackofthe', 'clones'],
} ->
cs_primitive { 'state':
   ensure          => present,
  primitive_class => 'ocf',
  provided_by     => 'pacemaker',
  primitive_type  => 'Dummy',
} ->
cs_ms { 'multi-states':
    ensure          => present,
    primitive       => 'state',
    metadata        => {
      master-max    => "2",
      clone-max     => "2",
      clone-node-max => "1",
      notify        => "true",
      target-role   => "Master",
      is-managed    => "true",
    }
}
# These are commented out for now and just included to illustrate format
#
#cs_location { 'no-test-on-node1':
#  ensure          => 'present',
#  nodename        => 'node1',
#  primitive       => 'test',
#  score           => '-INFINITY',
#} 
# 
#cs_location { 'test_loc_boolean_rule':
#  operations      => ['#uname eq node1', '#uname eq node2'],
#  primitive       => 'test',
#  ensure          => present,
#  rule            => 'primaryNode-rule',
#  score           => '1000',
#  operator        => 'or',
#}