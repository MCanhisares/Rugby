<h3 align="center">
  Rugby 🏈<br>
  <sup>(<ins>like Ruby but with g</ins>)</sup>
</h3>
<p align="center">
    <img src="https://github.com/swiftyfinch/Rugby/blob/main/Demo.gif" width="400"/>
</p>
<p align="center">
    <img src="https://img.shields.io/badge/version-1.0.2-008800.svg" />
    <img src="https://img.shields.io/badge/Language-Swift-orange.svg" />
    <img src="https://img.shields.io/badge/Xcode_CLTool-12+-blue.svg" />
</p>

### `Motivation`

Working on a project with a huge amount of remote pods I had some troubles:\
`-` Slow and unnecessary indexing of remote pods targets, which implementation I rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems CocoaPods hooks or Xcode build system;\
`-` Freezing UI during navigation.

You can read 📖 [full story](https://swiftyfinch.github.io/en/2021-03-09-rugby-story/) on my blog.

### `Description`

`Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all remote pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed remote pods;\
`+` Remove unnecessary sources from a project and reduce project size;\
`+` Drop any unneeded targets with sources and resources by RegEx.

### ✈️ Quick start with [`Homebrew`](https://brew.sh)

```bash
# First install
$ brew tap swiftyfinch/Rugby https://github.com/swiftyfinch/Rugby.git
$ brew install rugby

# Get new version
$ brew upgrade rugby
```

### `How to use`

| Command | Description |
| :----- | :------ |
🏈 [`Cache`](Docs/Cache.md) | Remove remote pods from project, build them and integrate as frameworks and bundles.
⚠️ [`Drop`](Docs/Drop.md) | Remove any targets by RegEx.

### `Maybe Roadmap`

- [x] New command: Drop
- [ ] Stable Drop command ✈️
- [ ] Run-in, stabilisation ✈️
- [ ] Pause for refactoring, tests, pipelines
- [ ] New command
- [ ] Open source

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.