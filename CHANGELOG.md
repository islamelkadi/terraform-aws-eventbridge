## [1.1.0](https://github.com/islamelkadi/terraform-aws-eventbridge/compare/v1.0.2...v1.1.0) (2026-03-15)


### Features

* add manual triggering to release workflow ([59c1af1](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/59c1af1fa1c6228e09812e0fa3958a20443af86b))


### Documentation

* add GitHub Actions workflow status badges ([77a90e2](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/77a90e295efa144ef5a41a10454c68d3287c5595))
* add security scan suppressions section to README ([e6d57b1](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/e6d57b1bf3c0e25c2b051dccf2b4b02c02f90690))

## [1.0.2](https://github.com/islamelkadi/terraform-aws-eventbridge/compare/v1.0.1...v1.0.2) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([8fc3c21](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/8fc3c2170f0f555583a26f32d683cc0f4dc0efdc))
* add skip-path for .external_modules in Checkov config ([78d768c](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/78d768cf6c04a4d660702c7953fbe5dc482ab643))
* address Checkov security findings ([fb74d91](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/fb74d9194c1dd3bd603de64b3bddd5ef1937641c))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([be900c0](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/be900c01a8ffd6814e42952b529257aea22d433f))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([6e31e77](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/6e31e77289b15283327a603a5307c4405fb164bf))
* update workflow path reference to terraform-security.yaml ([2c99e56](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/2c99e56be0ef009a6f73abf806244980c2577108))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-eventbridge/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([e8a2e98](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/e8a2e98c732d9a8aa5637ff4bc684de7cf6dabe2))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - EventBridge Terraform module

### Features

* First publish - EventBridge Terraform module ([a07f782](https://github.com/islamelkadi/terraform-aws-eventbridge/commit/a07f7826e92ba9e1437be67294211e2757aef7bc))
