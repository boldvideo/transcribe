aws_cred = Rails.application.credentials.dig(:aws)

if aws_cred
  Rails.logger.debug "AWS Credentials: #{aws_cred.inspect}"

  Aws.config.update({
    region: 'eu-central-1',
    credentials: Aws::Credentials.new(aws_cred['access_key_id'], aws_cred['secret_access_key'])
  })
else
  Rails.logger.warn "AWS credentials not found. AWS is not configured."
end
