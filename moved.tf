moved {
  from = aws_route53_record.validation[0]
  to   = aws_route53_record.validation["create"]
}
