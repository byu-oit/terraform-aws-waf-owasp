## 5.
## OWASP Top 10 A4
## Privileged Module Access Restrictions
## Restrict access to the admin interface to known source IPs only
## Matches the URI prefix, when the remote IP isn't in the whitelist

resource "aws_wafregional_rule" "detect_admin_access" {
  name        = "${var.waf_prefix}-generic-detect-admin-access"
  metric_name = "${var.waf_prefix}genericdetectadminaccess"

  predicate {
    data_id = "${aws_wafregional_ipset.admin_remote_ipset.id}"
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = "${aws_wafregional_byte_match_set.match_admin_url.id}"
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_ipset" "admin_remote_ipset" {
  name              = "${var.waf_prefix}-generic-match-admin-remote-ip"
  ip_set_descriptor = "${var.admin_remote_ipset}"
}

resource "aws_wafregional_byte_match_set" "match_admin_url" {
  name = "${var.waf_prefix}-generic-match-admin-url"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "/admin"
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}