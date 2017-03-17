# Definition: tomcat::config::context::resources
#
# Configure Resources elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $ensure specifies whether you are trying to add or remove the
#   Resources element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $resources_name is the name of the Resources to be created, relative to
#   the java:comp/env context.
# - $type is the fully qualified Java class name expected by the web application
#   when it performs a lookup for this resources
# - An optional hash of $additional_attributes to add to the Resources. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::context::resources (
  $ensure                = 'present',
  $catalina_base         = $::tomcat::catalina_home,
  $additional_attributes = {},
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  $base_path = "Context/Resources[#attribute/name='${_resources_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    if ! empty($additional_attributes) {
      $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }

    $changes = delete_undef_values(flatten($set_additional_attributes))
  }

  augeas { "context-${catalina_base}-resources-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
