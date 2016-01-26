Contributing Guidelines
--------------------------------------------------

This document provides general guidelines about how to contribute to the project. Keep in mind these important things before you start contributing.

### Asking Questions

We do not use github issues for general library support. We think this questions should be posted on stack overflow using [eureka-forms](http://http://stackoverflow.com/questions/tagged/eureka-forms) tag.

### Reporting issues

* Use [github issues](https://github.com/xmartlabs/Eureka/issues) to report a bug.
* Before creating a new issue:
  * Make sure you are using the [latest release](https://github.com/xmartlabs/Eureka/releases).
  * Check if the issue was [already reported or fixed](https://github.com/xmartlabs/Eureka/issues?utf8=%E2%9C%93&q=is%3Aissue). Notice that it may not be released yet.
  * If you found a match add a brief comment "I have the same problem" or "+1". This helps prioritize the issues addressing the most common and critical first. If possible add additional information to help us reproduce and fix the issue. Please use your best judgement.    
* Reporting issues:
  * Please include the following information to help maintainers to fix the problem faster:
    * Xcode version you are using.
    * iOS version you are targeting.
    * Full Xcode console output of stack trace or code compilation error.
    * Any other additional detail you think it would be useful to understand and solve the problem.


### Pull requests

The easiest way to start contributing is searching open issues by `help wanted` tag. We also add a `difficulty` tag (difficulty: easy, difficulty: moderate, difficulty: hard) in order to give an idea of how complex it can be to implement the feature according maintainers project experience.

* Add test coverage to the feature or fix. We only accept new feature pull requests that have related test coverage. This allows us to keep the library stable as we move forward.
* Remember to document the new feature. We do not accept new feature pull requests without its associated documentation.
* In case of a new feature please update the example project showing the feature.
* Please only one fix or feature per pull request. This will increase the chances your feature will be merged.


###### Suggested git workflow to contribute

1. Fork the Eureka repository.
2. Clone your forked project into your developer machine: `git clone git@github.com:<your-github-username>/Eureka.git`
3. Add the original project repo as upstream repository in your forked project: `git remote add upstream git@github.com:xmartlabs/Eureka.git`
4. Before starting a new feature make sure your forked master branch is synchronized upstream master branch. Considering you do not mere your pull request into master you can run: `git checkout master` and then `git pull upstream master`. Optionally `git push origin master`.
5. Create a new branch. Note that the starting point is the upstream master branch HEAD. `git checkout -b my-feature-name`
6. Stage all your changes `git add .` and commit them `git commit -m "Your commit message"`
7. Make sure your branch is up to date with upstream master, `git pull --rebase upstream master`, resolve conflicts if necessary. This will move your commit to the top of git stack.
8. Squash your commits into one commit. `git rebase -i HEAD~6` considering you did 6 commits.
9. Push your branch into your forked remote repository.
10. Create a new pull request adding any useful comment.


###### Code style and conventions

We try to follow our [swift style guide](https://github.com/xmartlabs/Swift-Style-Guide). Following it is not strictly necessary to contribute and to have a pull request accepted but project maintainers try to follow it. We would love to hear your ideas to improve our code style and conventions. Feel free to contribute.


### Feature proposal

We would love to hear your ideas and make a discussions about it.

* Use github issues to make feature proposals.
* We use `type: feature request` label to mark all [feature request issues](https://github.com/xmartlabs/Eureka/labels/type%3A%20feature%20request).
* Before submitting your proposal make sure there is no similar feature request. If you found a match feel free to join the discussion or just add a brief "+1" if you think the feature is worth implementing.
* Be as specific as possible providing a precise explanation of feature request so anyone can understand the problem and the benefits of solving it.
