OmniAuth.config.test_mode = true
omniauth_hash = {
  'provider' => 'github',
  'uid' => '12345',
  'info' => {
    'name' => 'marvin',
    'email' => 'hi@marvintherobot.com',
    'nickname' => 'MarvinTheRobot'
  },
  'extra' => {
    'raw_info' => {
      'location' => 'San Francisco',
      'gravatar_id' => '123456789'
    }
  },
  'credentials' => {'token' =>'123456789'}
}

OmniAuth.config.add_mock(:github, omniauth_hash)
