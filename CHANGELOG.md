# Changelog

## [v1.3.0](https://github.com/tonobo/hcloud-ruby/tree/v1.3.0) (2024-02-20)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.2.0...v1.3.0)

**Closed issues:**

- \[Enhancement\] Add missing fields / endpoints to Images + Servers [\#30](https://github.com/tonobo/hcloud-ruby/issues/30)

**Merged pull requests:**

- fix activemodel in Gemfile.lock [\#87](https://github.com/tonobo/hcloud-ruby/pull/87) ([skoch-hc](https://github.com/skoch-hc))
- Fix typo for pagination method [\#85](https://github.com/tonobo/hcloud-ruby/pull/85) ([coorasse](https://github.com/coorasse))
- \(\#82\) fix undefined method `.blank?` [\#84](https://github.com/tonobo/hcloud-ruby/pull/84) ([bastelfreak](https://github.com/bastelfreak))
- CI: Run on PRs and pushes to master [\#83](https://github.com/tonobo/hcloud-ruby/pull/83) ([bastelfreak](https://github.com/bastelfreak))
- Dont list activemodel as dev- and runtime dep [\#80](https://github.com/tonobo/hcloud-ruby/pull/80) ([bastelfreak](https://github.com/bastelfreak))
- version: bump to v1.2.0 [\#79](https://github.com/tonobo/hcloud-ruby/pull/79) ([aufziehvogel](https://github.com/aufziehvogel))
- build\(deps\): bump rack from 3.0.1 to 3.0.6.1 [\#75](https://github.com/tonobo/hcloud-ruby/pull/75) ([dependabot[bot]](https://github.com/apps/dependabot))
- add missing features to existing resources [\#60](https://github.com/tonobo/hcloud-ruby/pull/60) ([aufziehvogel](https://github.com/aufziehvogel))

## [v1.2.0](https://github.com/tonobo/hcloud-ruby/tree/v1.2.0) (2023-10-11)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.1.0...v1.2.0)

**Closed issues:**

- question: could you point out the differences to other hcloud gem? [\#71](https://github.com/tonobo/hcloud-ruby/issues/71)
- \[Feature\] Add Primary IPs [\#57](https://github.com/tonobo/hcloud-ruby/issues/57)
- \[Feature\] Add Primary IPs [\#56](https://github.com/tonobo/hcloud-ruby/issues/56)
- \[Bug\] Firewalls do not expose actions [\#54](https://github.com/tonobo/hcloud-ruby/issues/54)
- \[Bug\] IPv6 global address is not parsed correctly [\#49](https://github.com/tonobo/hcloud-ruby/issues/49)
- \[Feature\] Add LoadBalancers and -Types [\#29](https://github.com/tonobo/hcloud-ruby/issues/29)
- \[Feature\] Add PlacementGroups [\#27](https://github.com/tonobo/hcloud-ruby/issues/27)
- \[Feature\] Add Certificates [\#26](https://github.com/tonobo/hcloud-ruby/issues/26)
- \[Feature\] Add Firewalls [\#25](https://github.com/tonobo/hcloud-ruby/issues/25)

**Merged pull requests:**

- version: bump to v1.2.0 [\#78](https://github.com/tonobo/hcloud-ruby/pull/78) ([aufziehvogel](https://github.com/aufziehvogel))
- lib: import active\_support before cherry-picking imports [\#77](https://github.com/tonobo/hcloud-ruby/pull/77) ([aufziehvogel](https://github.com/aufziehvogel))
- Dependencies: Drop rake, as it's unnecessary [\#74](https://github.com/tonobo/hcloud-ruby/pull/74) ([Kjarrigan](https://github.com/Kjarrigan))
- server: return `next_actions` data on create [\#72](https://github.com/tonobo/hcloud-ruby/pull/72) ([aufziehvogel](https://github.com/aufziehvogel))
- lib: implement primary IPs [\#65](https://github.com/tonobo/hcloud-ruby/pull/65) ([aufziehvogel](https://github.com/aufziehvogel))
- lib: implement certificates [\#64](https://github.com/tonobo/hcloud-ruby/pull/64) ([aufziehvogel](https://github.com/aufziehvogel))
- spec: include context doubles for doubles tests [\#63](https://github.com/tonobo/hcloud-ruby/pull/63) ([aufziehvogel](https://github.com/aufziehvogel))
- fix: return actions info on firewall create [\#59](https://github.com/tonobo/hcloud-ruby/pull/59) ([aufziehvogel](https://github.com/aufziehvogel))
- fix: do not interpret leading : in JSON as symbol [\#58](https://github.com/tonobo/hcloud-ruby/pull/58) ([aufziehvogel](https://github.com/aufziehvogel))
- lib: implement load balancer [\#55](https://github.com/tonobo/hcloud-ruby/pull/55) ([aufziehvogel](https://github.com/aufziehvogel))
- implement double tests for existing resources [\#53](https://github.com/tonobo/hcloud-ruby/pull/53) ([aufziehvogel](https://github.com/aufziehvogel))
- Add PlacementGroup [\#52](https://github.com/tonobo/hcloud-ruby/pull/52) ([aufziehvogel](https://github.com/aufziehvogel))
- firewall: please linter [\#51](https://github.com/tonobo/hcloud-ruby/pull/51) ([RaphaelPour](https://github.com/RaphaelPour))

## [v1.1.0](https://github.com/tonobo/hcloud-ruby/tree/v1.1.0) (2022-11-29)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.0.3...v1.1.0)

**Closed issues:**

- Doubles tests failure with seed 50938 [\#46](https://github.com/tonobo/hcloud-ruby/issues/46)
- \[Feature\] Add missing Resources/Endpoints Q1/2022 [\#24](https://github.com/tonobo/hcloud-ruby/issues/24)
- \[Dependencies\] Unpin activesupport [\#23](https://github.com/tonobo/hcloud-ruby/issues/23)

**Merged pull requests:**

- version: bump to v1.1.0 [\#50](https://github.com/tonobo/hcloud-ruby/pull/50) ([aufziehvogel](https://github.com/aufziehvogel))
- handle action array responses for firewall actions [\#48](https://github.com/tonobo/hcloud-ruby/pull/48) ([aufziehvogel](https://github.com/aufziehvogel))
- fix auto pagination test to always use three pages [\#47](https://github.com/tonobo/hcloud-ruby/pull/47) ([aufziehvogel](https://github.com/aufziehvogel))
- label support \(create, update, search\) [\#45](https://github.com/tonobo/hcloud-ruby/pull/45) ([aufziehvogel](https://github.com/aufziehvogel))
- set Github Workflow badge for build status [\#44](https://github.com/tonobo/hcloud-ruby/pull/44) ([aufziehvogel](https://github.com/aufziehvogel))
- fix rubocop linting warnings [\#42](https://github.com/tonobo/hcloud-ruby/pull/42) ([aufziehvogel](https://github.com/aufziehvogel))
- Implement firewall support [\#41](https://github.com/tonobo/hcloud-ruby/pull/41) ([aufziehvogel](https://github.com/aufziehvogel))
- Create unit tests for networks [\#40](https://github.com/tonobo/hcloud-ruby/pull/40) ([aufziehvogel](https://github.com/aufziehvogel))
- fix typo in exception name ResourceUnavailable [\#39](https://github.com/tonobo/hcloud-ruby/pull/39) ([aufziehvogel](https://github.com/aufziehvogel))
- Bump rack from 2.2.3 to 2.2.3.1 [\#38](https://github.com/tonobo/hcloud-ruby/pull/38) ([dependabot[bot]](https://github.com/apps/dependabot))
- dependency: update + unpin activesupport [\#36](https://github.com/tonobo/hcloud-ruby/pull/36) ([RaphaelPour](https://github.com/RaphaelPour))
- Add MIT license to gemspec [\#34](https://github.com/tonobo/hcloud-ruby/pull/34) ([bastelfreak](https://github.com/bastelfreak))
- Create LICENSE [\#33](https://github.com/tonobo/hcloud-ruby/pull/33) ([RaphaelPour](https://github.com/RaphaelPour))
- Update server attributes [\#32](https://github.com/tonobo/hcloud-ruby/pull/32) ([RaphaelPour](https://github.com/RaphaelPour))

## [v1.0.3](https://github.com/tonobo/hcloud-ruby/tree/v1.0.3) (2022-02-17)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.0.2...v1.0.3)

**Closed issues:**

- Support Ruby 3.0+ [\#18](https://github.com/tonobo/hcloud-ruby/issues/18)

**Merged pull requests:**

- bump version to v1.0.3 [\#22](https://github.com/tonobo/hcloud-ruby/pull/22) ([RaphaelPour](https://github.com/RaphaelPour))
- lib: adjust code to work with 3.x ruby versions [\#21](https://github.com/tonobo/hcloud-ruby/pull/21) ([Kjarrigan](https://github.com/Kjarrigan))
- ci: add github workflow [\#20](https://github.com/tonobo/hcloud-ruby/pull/20) ([RaphaelPour](https://github.com/RaphaelPour))

## [v1.0.2](https://github.com/tonobo/hcloud-ruby/tree/v1.0.2) (2020-02-13)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.0.1...v1.0.2)

**Closed issues:**

- Thank you! [\#14](https://github.com/tonobo/hcloud-ruby/issues/14)

## [v1.0.1](https://github.com/tonobo/hcloud-ruby/tree/v1.0.1) (2020-02-12)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/tonobo/hcloud-ruby/tree/v1.0.0) (2019-10-22)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.2...v1.0.0)

**Merged pull requests:**

- Refactor resource handling [\#15](https://github.com/tonobo/hcloud-ruby/pull/15) ([tonobo](https://github.com/tonobo))
- Development [\#13](https://github.com/tonobo/hcloud-ruby/pull/13) ([tonobo](https://github.com/tonobo))
- Mention destroy instead of delete. [\#10](https://github.com/tonobo/hcloud-ruby/pull/10) ([FloHeinle](https://github.com/FloHeinle))

## [v0.1.2](https://github.com/tonobo/hcloud-ruby/tree/v0.1.2) (2018-02-27)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.1...v0.1.2)

**Closed issues:**

- Add rubocop [\#7](https://github.com/tonobo/hcloud-ruby/issues/7)
- Unnecessary pagination calls  [\#6](https://github.com/tonobo/hcloud-ruby/issues/6)

**Merged pull requests:**

- Introduce rubocop [\#8](https://github.com/tonobo/hcloud-ruby/pull/8) ([tonobo](https://github.com/tonobo))
- Enhance test suite [\#5](https://github.com/tonobo/hcloud-ruby/pull/5) ([tonobo](https://github.com/tonobo))

## [v0.1.1](https://github.com/tonobo/hcloud-ruby/tree/v0.1.1) (2018-02-26)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- Floating IP context [\#4](https://github.com/tonobo/hcloud-ruby/pull/4) ([MarkusFreitag](https://github.com/MarkusFreitag))

## [v0.1.0](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0) (2018-02-25)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0.pre.alpha4...v0.1.0)

**Closed issues:**

- Documentation for busy waiting [\#2](https://github.com/tonobo/hcloud-ruby/issues/2)

**Merged pull requests:**

- Pagination proposal [\#3](https://github.com/tonobo/hcloud-ruby/pull/3) ([tonobo](https://github.com/tonobo))

## [v0.1.0.pre.alpha4](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0.pre.alpha4) (2018-01-30)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0.pre.alpha3...v0.1.0.pre.alpha4)

## [v0.1.0.pre.alpha3](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0.pre.alpha3) (2018-01-29)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0.pre.alpha2...v0.1.0.pre.alpha3)

**Merged pull requests:**

- set needed gems to runtime dependency [\#1](https://github.com/tonobo/hcloud-ruby/pull/1) ([bastelfreak](https://github.com/bastelfreak))

## [v0.1.0.pre.alpha2](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0.pre.alpha2) (2018-01-28)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0.pre.alpha1...v0.1.0.pre.alpha2)

## [v0.1.0.pre.alpha1](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0.pre.alpha1) (2018-01-28)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/v0.1.0.pre.alpha0...v0.1.0.pre.alpha1)

## [v0.1.0.pre.alpha0](https://github.com/tonobo/hcloud-ruby/tree/v0.1.0.pre.alpha0) (2018-01-27)

[Full Changelog](https://github.com/tonobo/hcloud-ruby/compare/7f85d9b10b15c275f44f57d1b6fb6f122d95b5aa...v0.1.0.pre.alpha0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
