name: my_map_app
description: An accessible, reassuring navigation demo for older adults.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.3        # saves sign-up details locally
  flutter_secure_storage: ^9.2.2    # optional: for sensitive data like passwords

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true