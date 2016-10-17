jazzy \
  --clean \
  --author "Yang Liu" \
  --author_url https://herrkaefer.com \
  --github_url https://github.com/herrkaefer/AccelerateWatch \
  --min-acl internal \
  --output ./docs \
  --source-directory ./AccelerateWatchDemoApp \
  --readme ./README.md \
  --root-url http://herrkaefer.github.io/AccelerateWatch/
  # --exclude ./AccelerateWatchDemoApp/Watch\ Extenion/ExtensionDelegate.swift, \
  #           ./AccelerateWatchDemoApp/Watch\ Extenion/InterfaceController.swift

# Publish docs at https://herrkaefer.github.io/AccelerateWatch/
git subtree push --prefix docs origin gh-pages


