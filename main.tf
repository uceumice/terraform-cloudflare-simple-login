locals {
  # @ means the root of a zone, therefore the other labels get no suffix in that case
  domain       = replace(var.domain, ".@", "")
  label_suffix = local.domain == "@" ? "" : ".${local.domain}"

  # SimpleLogin MX servers with weights
  mx_weights = {
    "mx1.simplelogin.co." = 10
    "mx2.simplelogin.co." = 20
  }

  dkim_entries = {
    "dkim._domainkey" : "dkim._domainkey.simplelogin.co.",
    "dkim02._domainkey" : "dkim02._domainkey.simplelogin.co.",
    "dkim03._domainkey" : "dkim03._domainkey.simplelogin.co."
  }
}

# Verification
resource "cloudflare_record" "verification" {
  # Knock-off conditional
  # Idea taken from https://stackoverflow.com/a/60231673
  count = var.verification != null ? 1 : 0

  zone_id = var.zone_id
  name    = local.domain
  type    = "TXT"
  value   = "sl-verification=${var.verification}"
}

# MX
resource "cloudflare_record" "mx" {
  for_each = local.mx_weights

  zone_id  = var.zone_id
  name     = local.domain
  type     = "MX"
  value    = each.key
  priority = each.value
}

# SPF
resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = local.domain
  type    = "TXT"
  value   = "v=spf1 include:simplelogin.co -all"
}

# DKIM
resource "cloudflare_record" "dkim" {
  for_each = local.dkim_entries

  zone_id = var.zone_id
  name    = "${each.key}${local.label_suffix}"
  type    = "CNAME"
  value   = each.value
}

# DMARC
resource "cloudflare_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc${local.label_suffix}"
  type    = "TXT"
  value   = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
}
