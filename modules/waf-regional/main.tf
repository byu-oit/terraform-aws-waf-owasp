#
# This is our WAF ACL with each rule defined and prioritized accordingly.
#
resource "aws_wafregional_web_acl" "wafregional_acl" {
  name        = "${var.waf_prefix}-generic-owasp-acl"
  metric_name = "${var.waf_prefix}genericowaspacl"

  default_action {
    type = "ALLOW"
  }

  #
  # Note: we are using this but we are not applying body size restrictions because
  #  uploads could be affected by that.
  #
  rule {
    count = "${var.rule_size_restriction_action_type_enable == true ? 1 : 0}"

    action {
      type = "${var.rule_size_restriction_action_type}"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rule.restrict_sizes.id}"
    type     = "REGULAR"
  }

  #
  # Reason: we are not implementing an IP blacklist yet.
  #
  # rule {
  #   action {
  #     type = "${var.rule_blacklisted_ips_action_type}"
  #   }
  # 
  #   priority = 20
  #   rule_id  = "${aws_wafregional_rule.detect_blacklisted_ips.id}"
  #   type     = "REGULAR"
  # }


  #
  # Reason: the apps do not use auth tokens yet.
  #
  # rule {
  #   action {
  #     type = "${var.rule_auth_tokens_action}"
  #   }
  # 
  #   priority = 30
  #   rule_id  = "${aws_wafregional_rule.detect_bad_auth_tokens.id}"
  #   type     = "REGULAR"
  # }

  rule {
    action {
      type = "${var.rule_sqli_action}"
    }

    priority = 40
    rule_id  = "${aws_wafregional_rule.mitigate_sqli.id}"
    type     = "REGULAR"
  }
  rule {
    action {
      type = "${var.rule_xss_action}"
    }

    priority = 50
    rule_id  = "${aws_wafregional_rule.mitigate_xss.id}"
    type     = "REGULAR"
  }
  rule {
    action {
      type = "${var.rule_lfi_rfi_action}"
    }

    priority = 60
    rule_id  = "${aws_wafregional_rule.detect_rfi_lfi_traversal.id}"
    type     = "REGULAR"
  }

  #
  # Reason: we don't have PHP stacks on this project.
  #
  # rule {
  #   action {
  #     type = "${var.rule_php_insecurities_action_type}"
  #   }
  # 
  #   priority = 70
  #   rule_id  = "${aws_wafregional_rule.detect_php_insecure.id}"
  #   type     = "REGULAR"
  # }


  #
  # Reason: the apps do not use CSRF tokens.
  #
  # rule {
  #   action {
  #     type = "${var.rule_csrf_action_type}"
  #   }
  # 
  #   priority = 80
  #   rule_id  = "${aws_wafregional_rule.enforce_csrf.id}"
  #   type     = "REGULAR"
  # }

  #
  # Reason: this should cover any config files in our web root folder.
  #
  rule {
    action {
      type = "${var.rule_ssi_action_type}"
    }

    priority = 90
    rule_id  = "${aws_wafregional_rule.detect_ssi.id}"
    type     = "REGULAR"
  }

  #
  # Reason: we do not have IP restriction on admin sections.
  #
  # rule {
  #   action {
  #     type = "${var.rule_admin_access_action_type}"
  #   }
  # 
  #   priority = 100
  #   rule_id  = "${aws_wafregional_rule.detect_admin_access.id}"
  #   type     = "REGULAR"
  # }
}

#
# This is how we link the WAF ACL to one or many ALBs.
#
resource "aws_wafregional_web_acl_association" "acl_alb_association" {
  depends_on   = ["aws_wafregional_web_acl.wafregional_acl"]
  count        = "${length(var.alb_arn)}"
  resource_arn = "${element(var.alb_arn, count.index)}"
  web_acl_id   = "${aws_wafregional_web_acl.wafregional_acl.id}"
}