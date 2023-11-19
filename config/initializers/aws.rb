aws_cred = Rails.application.credentials.dig(:aws)
Rails.logger.debug "AWS Credentials: #{aws_cred.inspect}"

Aws.config.update({
  region: 'eu-central-1',
  credentials: Aws::Credentials.new(aws_cred['access_key_id'], aws_cred['secret_access_key'])
})
